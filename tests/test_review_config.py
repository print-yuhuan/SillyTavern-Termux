"""Configuration and EOF regressions, using isolated Linux/WSL fixtures.

Run: python3 tests/test_review_config.py
For YAML coverage, set ST_REVIEW_YAML_DIR to an existing yaml package directory.
The package is copied into the private fixture; these tests never install packages
or contact a network. YAML cases explicitly skip if no package is available.
"""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import unittest

import test_safety


class ReviewConfigTests(unittest.TestCase):
    def setUp(self):
        self.harness = test_safety.SafetyTests()
        self.harness.setUp()
        self.addCleanup(self.harness.doCleanups)
        self.home = self.harness.home
        self.tavern = self.harness.tavern
        self.setting = self.home / ".st-memory-limit"
        self.start = self.tavern / "start.sh"
        self.config = self.tavern / "config.yaml"

    @staticmethod
    def linux_path(value):
        if re.match(r"^[A-Za-z]:[\\/]", value):
            value = subprocess.check_output(["wslpath", "-u", value], text=True).strip()
        return Path(value)

    def install_yaml_fixture(self):
        configured = os.environ.get("ST_REVIEW_YAML_DIR")
        if configured:
            package = self.linux_path(configured)
            if (package / "node_modules/yaml/package.json").is_file():
                package /= "node_modules/yaml"
            self.assertTrue((package / "package.json").is_file(),
                            "ST_REVIEW_YAML_DIR must identify an existing yaml package")
        else:
            result = self.harness.run_bash('node -p \'require.resolve("yaml/package.json")\'')
            if result.returncode:
                self.skipTest("YAML package unavailable; set ST_REVIEW_YAML_DIR for YAML coverage")
            package = self.linux_path(result.stdout.strip()).parent
        self.assertEqual(json.loads((package / "package.json").read_text())["name"], "yaml")
        shutil.copytree(package, self.tavern / "node_modules/yaml")

    def read_config(self):
        result = self.harness.run_bash(r'''
cd "$TEST_HOME/SillyTavern" || exit 1
node -p 'JSON.stringify(require("yaml").parse(require("fs").readFileSync("config.yaml", "utf8")))'
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout)

    def test_closing_listener_preserves_authentication_and_custom_yaml(self):
        self.install_yaml_fixture()
        test_safety.put(self.config, '''listen: true # LAN listener
whitelistMode: true
enableUserAccounts: true
enableDiscreetLogin: true
basicAuthMode: true
basicAuthUser:
  username: "fixture-owner"
  password: "fixture-password"
whitelist:
  - "0.0.0.0/0"
custom:
  listen: true
''')
        before = self.read_config()
        result = self.harness.run_bash("set_lan_listen false")
        self.assertEqual(result.returncode, 0, result.stderr)
        before["listen"] = False
        self.assertEqual(self.read_config(), before)
        self.assertFalse(list(self.tavern.glob("config.yaml.lan.*")))

    def test_enabling_listener_keeps_custom_whitelist_entries(self):
        self.install_yaml_fixture()
        test_safety.put(self.config, '''listen: false # standard local configuration
enableUserAccounts: false
enableDiscreetLogin: false
whitelistMode: true
whitelist: ["::1", "127.0.0.1", "192.168.0.20"]
custom: {listen: false}
''')
        result = self.harness.run_bash("set_lan_listen true")
        self.assertEqual(result.returncode, 0, result.stderr)
        changed = self.read_config()
        self.assertIs(changed["listen"], True)
        self.assertIs(changed["enableUserAccounts"], True)
        self.assertIs(changed["enableDiscreetLogin"], True)
        self.assertEqual(changed["whitelist"], ["::1", "0.0.0.0/0", "192.168.0.20"])
        self.assertEqual(changed["custom"], {"listen": False})

    def test_invalid_yaml_is_not_overwritten(self):
        self.install_yaml_fixture()
        for original in ("listen: [true\n", "- true\n- false\n"):
            with self.subTest(original=original):
                test_safety.put(self.config, original)
                result = self.harness.run_bash("set_lan_listen false")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.config.read_text(), original)
                self.assertFalse(list(self.tavern.glob("config.yaml.lan.*")))

    def test_failed_atomic_lan_replace_preserves_original_config(self):
        self.install_yaml_fixture()
        original = "listen: true # must remain intact\nenableUserAccounts: true\n"
        test_safety.put(self.config, original)
        result = self.harness.run_bash("mv() { return 1; }; set_lan_listen false")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), original)
        self.assertFalse(list(self.tavern.glob("config.yaml.lan.*")))

    def test_symlink_config_is_rejected_without_modifying_target(self):
        target = self.home / "other-config.yaml"
        test_safety.put(target, "listen: true\n")
        self.config.symlink_to(target)
        result = self.harness.run_bash("set_lan_listen false")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(target.read_text(), "listen: true\n")
        self.assertTrue(self.config.is_symlink())

    def test_invalid_mode_is_rejected_without_modifying_config(self):
        test_safety.put(self.config, "listen: true\n")
        result = self.harness.run_bash("set_lan_listen invalid")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.read_text(), "listen: true\n")

    def test_memory_validation_enforces_bounds_without_integer_overflow(self):
        for value, valid in (("1024", True), ("2048", True), ("8192", True),
                             ("1023", False), ("8193", False), ("0000", False),
                             ("9" * 38, False), ("2048.0", False), ("", False)):
            with self.subTest(value=value):
                result = self.harness.run_bash(f"memory_limit_is_valid '{value}'")
                self.assertEqual(result.returncode == 0, valid, result.stderr)
                self.assertNotIn("integer expected", result.stderr)
                self.assertNotIn("integer expression expected", result.stderr)

    def test_invalid_memory_write_preserves_existing_setting_and_start_file(self):
        original_start = '#!/bin/bash\nnode --max-old-space-size=4096 "server.js" "$@"\n'
        test_safety.put(self.start, original_start)
        test_safety.put(self.setting, "2048\n")
        result = self.harness.run_bash("set_memory_limit " + "9" * 38)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.setting.read_text(), "2048\n")
        self.assertEqual(self.start.read_text(), original_start)
        self.assertFalse(list(self.home.glob(".st-memory.*")))

    def test_failed_atomic_memory_replace_preserves_previous_setting(self):
        test_safety.put(self.setting, "2048\n")
        result = self.harness.run_bash("mv() { return 1; }; set_memory_limit 4096")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.setting.read_text(), "2048\n")
        self.assertFalse(list(self.home.glob(".st-memory.*")))

    def test_legacy_memory_is_migrated_and_command_override_removed(self):
        test_safety.put(self.start, '#!/bin/bash\n# user customization\nnode --max-old-space-size=3072 "server.js" "$@"\n')
        result = self.harness.run_bash("migrate_memory_limit && apply_memory_limit; status=$?; printf '%s\\n' \"$NODE_OPTIONS\"; exit \"$status\"")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.setting.read_text(), "3072\n")
        self.assertNotIn("--max-old-space-size", self.start.read_text())
        self.assertIn("# user customization", self.start.read_text())
        self.assertIn('node "server.js" "$@"', self.start.read_text())
        self.assertIn("--max-old-space-size=3072", result.stdout)

    def test_new_setting_wins_over_legacy_command_override(self):
        test_safety.put(self.start, '#!/bin/bash\nnode --max-old-space-size=4096 "server.js" "$@"\n')
        result = self.harness.run_bash("set_memory_limit 2048 && migrate_memory_limit && apply_memory_limit; status=$?; printf '%s\\n' \"$NODE_OPTIONS\"; exit \"$status\"")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.setting.read_text(), "2048\n")
        self.assertNotIn("--max-old-space-size", self.start.read_text())
        self.assertIn("--max-old-space-size=2048", result.stdout)
        self.assertNotIn("--max-old-space-size=4096", result.stdout)

    def test_invalid_persisted_memory_does_not_modify_node_options(self):
        test_safety.put(self.setting, "9" * 38 + "\n")
        result = self.harness.run_bash(r'''
NODE_OPTIONS=--trace-warnings
apply_memory_limit
status=$?
printf 'OPTIONS=%s\n' "$NODE_OPTIONS"
exit "$status"
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("OPTIONS=--trace-warnings", result.stdout)

    def test_node_uses_persisted_memory_and_preserves_other_options(self):
        test_safety.put(self.setting, "2048\n")
        result = self.harness.run_bash(r'''
NODE_OPTIONS=--trace-warnings
apply_memory_limit || exit 1
[[ "$NODE_OPTIONS" == *--trace-warnings* ]] || exit 2
# Existing test harness can bridge Windows Node from WSL.
export WSLENV="${WSLENV:+$WSLENV:}NODE_OPTIONS"
node -p 'require("v8").getHeapStatistics().heap_size_limit'
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        heap = int(result.stdout.splitlines()[-1])
        self.assertGreaterEqual(heap, 2048 * 1024 * 1024)
        self.assertLess(heap, 2300 * 1024 * 1024)

    def test_update_retains_legacy_memory_setting_across_git_reset(self):
        def git(*arguments):
            return subprocess.check_output(["git", "-C", str(self.tavern), *arguments],
                                           stderr=subprocess.STDOUT, text=True).strip()

        test_safety.put(self.start, '#!/bin/bash\nnode --max-old-space-size=3072 "server.js" "$@"\n')
        git("init", "--initial-branch=main")
        git("config", "user.name", "Review Fixture")
        git("config", "user.email", "fixture@example.invalid")
        git("add", "start.sh", "package.json", "server.js")
        git("commit", "-m", "local base")
        original = git("rev-parse", "HEAD")
        test_safety.put(self.start, '#!/bin/bash\nnode "server.js" "$@"\n')
        test_safety.put(self.tavern / "server.js", "// upstream update\n")
        git("add", "start.sh", "server.js")
        git("commit", "-m", "local upstream")
        git("branch", "release")
        git("reset", "--hard", original)
        git("remote", "add", "origin", str(self.tavern))
        result = self.harness.run_bash("update_tavern")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.setting.read_text(), "3072\n")
        self.assertNotIn("--max-old-space-size", self.start.read_text())
        self.assertEqual((self.tavern / "server.js").read_text(), "// upstream update\n")

    def test_android_ifconfig_prefix_is_removed(self):
        result = self.harness.run_bash(r'''
command() {
    if [[ "$1" == '-v' && "$2" == ip ]]; then return 1; fi
    builtin command "$@"
}
ifconfig() {
    printf '%s\n' 'wlan0 Link encap:Ethernet HWaddr 00:11:22:33:44:55' \
        '          inet addr:192.168.1.8 Bcast:192.168.1.255 Mask:255.255.255.0'
}
get_lan_ipv4
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "192.168.1.8")

    def test_menu_loops_return_when_input_reaches_eof(self):
        (self.tavern / "public/scripts/extensions/third-party/fixture").mkdir(parents=True)
        for menu in ("tavern_config_menu", "lan_config_menu", "startup_association_menu",
                     "plugin_install_menu", "plugin_uninstall_menu", "plugin_menu",
                     "version_switch_menu", "maintenance_menu", "script_manage_menu",
                     "about_script_menu", "qq_groups_menu", "resource_links_menu",
                     "install_app_menu", "community_links_menu", "open_link_menu"):
            with self.subTest(menu=menu):
                result = self.harness.run_bash(menu, timeout=1)
                self.assertLessEqual(result.stdout.count("无效"), 1, result.stdout[:1000])

    def test_memory_prompt_eof_keeps_start_file_and_does_not_write_setting(self):
        original = '#!/bin/bash\nnode "server.js" "$@"\n'
        test_safety.put(self.start, original)
        result = self.harness.run_bash("tavern_config_menu", "2", timeout=1)
        self.assertEqual(self.start.read_text(), original)
        self.assertFalse(self.setting.exists())
        self.assertNotIn("内存限制已设置", result.stdout)

    def test_main_menu_returns_when_input_reaches_eof(self):
        result = self.harness.run_bash("", source="clear() { :; }\n" + test_safety.MENU,
                                       timeout=1)
        self.assertLessEqual(result.stdout.count("无效"), 1, result.stdout[:1000])


if __name__ == "__main__":
    unittest.main(verbosity=2)
