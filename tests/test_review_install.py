"""Installer regressions; run with python3 tests/test_review_install.py (Linux/WSL).

All installs run against test_safety's private HOME with package/network stubs.
"""
import unittest

import test_safety


EXISTING_REPOSITORY = r'''
git() {
    [[ "$1" == '-C' && "$3" == 'rev-parse' ]]
}
'''


class InstallerReviewTests(unittest.TestCase):
    def setUp(self):
        self.harness = test_safety.SafetyTests()
        self.harness.setUp()
        self.addCleanup(self.harness.doCleanups)
        self.home = self.harness.home
        (self.harness.tavern / ".git").mkdir()
        test_safety.put(self.home / "Menu.sh", r'''MENU_VERSION=1
printf 'entered\n' > "$TEST_HOME/menu-entered"
''')

    def install(self, extra_setup=""):
        return self.harness.run_bash(EXISTING_REPOSITORY + extra_setup, "x",
                                     source=test_safety.INSTALL, installer=True)

    def assert_stopped_before_dependencies(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout)
        calls = (self.home / "calls").read_text()
        self.assertNotIn("npm install", calls)
        self.assertNotIn("安装完成！", result.stdout)
        self.harness.assert_old_data()

    def test_missing_server_preserves_existing_repository_and_data(self):
        (self.harness.tavern / "server.js").unlink()
        result = self.install()
        self.assert_stopped_before_dependencies(result)
        self.assertIn("本体校验失败", result.stdout)
        self.assertTrue((self.harness.tavern / ".git").is_dir())
        self.assertFalse((self.home / ".bashrc").exists())

    def test_unrelated_or_malformed_package_is_not_installed(self):
        for package in ('{"name":"unrelated-repo"}', '{"name":"sillytavern"'):
            with self.subTest(package=package):
                test_safety.put(self.harness.tavern / "package.json", package)
                result = self.install()
                self.assert_stopped_before_dependencies(result)
                self.assertIn("本体校验失败", result.stdout)
                self.assertEqual((self.harness.tavern / "package.json").read_text(), package)

    def test_commented_autostart_is_enabled_and_repeat_install_is_idempotent(self):
        # The harness replaces HOME references with TEST_HOME before execution.
        profile = self.home / ".bashrc"
        test_safety.put(profile, "# bash $TEST_HOME/Menu.sh\n")
        first = self.install()
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertIn("安装完成！", first.stdout)
        self.assertIn("npm install", (self.home / "calls").read_text())
        self.assertEqual(profile.read_text().splitlines().count("bash $TEST_HOME/Menu.sh"), 1)

        second = self.install()
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(profile.read_text().splitlines().count("bash $TEST_HOME/Menu.sh"), 1)
        (self.home / "menu-entered").unlink()
        sourced = self.harness.run_bash('source "$TEST_HOME/.bashrc"')
        self.assertEqual(sourced.returncode, 0, sourced.stderr)
        self.assertTrue((self.home / "menu-entered").is_file())

    def test_profile_touch_failure_stops_before_module_install(self):
        result = self.install("\ntouch() { return 1; }\n")
        self.assert_stopped_before_dependencies(result)
        self.assertIn("无法创建或访问启动配置文件", result.stdout)
        self.assertNotIn("已配置菜单自启动", result.stdout)

    def test_profile_append_failure_is_reported(self):
        result = self.install(r'''
touch() { command touch "$@" || return; append_failure=1; }
printf() {
    [[ "${append_failure:-0}" == 1 ]] && return 1
    builtin printf "$@"
}
''')
        self.assert_stopped_before_dependencies(result)
        self.assertIn("写入菜单自启动失败", result.stdout)
        self.assertNotIn("已配置菜单自启动", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
