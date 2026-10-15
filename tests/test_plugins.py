"""Plugin menu regressions. Run with: python3 tests/test_plugins.py (Linux/WSL).

Use the private HOME and guarded file operations from test_safety. Git cloning is
stubbed; no network requests, browser actions or real plugin installs occur.
"""
import re
import unittest

import test_safety


PLUGINS = [
    ("JS-Slash-Runner", "酒馆助手", "https://github.com/N0VI028/JS-Slash-Runner"),
    ("st-memory-enhancement", "记忆表格", "https://github.com/muyoou/st-memory-enhancement"),
    ("SillyTavern-CustomModels", "自定义模型", "https://github.com/LenAnderson/SillyTavern-CustomModels"),
    ("LittleWhiteBox", "小白X", "https://github.com/RT15548/LittleWhiteBox"),
    ("ST-BaiBai-Book", "柏宝书", "https://github.com/baibai-git/ST-BaiBai-Book"),
    ("ST-Prompt-Template", "提示词模板", "https://github.com/zonde306/ST-Prompt-Template"),
    ("shujuku", "龙血玄黄·数据库", "https://github.com/AlbusKen/shujuku"),
]

CLONE_OK = r'''
git() {
    [[ "$1" == 'clone' ]] || return 1
    printf '%s\n' "$2" >> "$TEST_HOME/clones"
    mkdir -p -- "$3" || return 1
    printf 'test plugin\n' > "$3/manifest.json"
}
'''


class PluginTests(unittest.TestCase):
    def setUp(self):
        self.harness = test_safety.SafetyTests()
        self.harness.setUp()
        self.addCleanup(self.harness.doCleanups)
        self.home = self.harness.home
        self.plugin_root = self.harness.tavern / "public/scripts/extensions/third-party"

    def run_menu(self, stdin, setup=CLONE_OK, menu="plugin_install_menu"):
        result = self.harness.run_bash(setup + "\n" + menu, stdin)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def assert_no_temporary_plugins(self):
        self.assertEqual(list(self.plugin_root.glob(".plugin-install.*")), [])

    def test_all_seven_choices_install_the_requested_repositories(self):
        self.run_menu("".join(f"{choice}y" for choice in range(1, 8)) + "0")
        self.assertEqual((self.home / "clones").read_text().splitlines(), [p[2] for p in PLUGINS])
        for folder, _, _ in PLUGINS:
            self.assertEqual((self.plugin_root / folder / "manifest.json").read_text(), "test plugin\n")
        self.assert_no_temporary_plugins()

    def test_cancel_and_eof_do_not_clone_or_create_plugin_directories(self):
        for stdin in ("4n5n6n7n0", "7", ""):
            with self.subTest(stdin=stdin):
                self.run_menu(stdin)
                self.assertFalse((self.home / "clones").exists())
                self.assertFalse(self.plugin_root.exists())

    def test_repeated_install_preserves_existing_plugin_files(self):
        self.run_menu("4y5y6y7y0")
        for folder, _, _ in PLUGINS[3:]:
            test_safety.put(self.plugin_root / folder / "user.txt", "keep this")
        result = self.run_menu("4y5y6y7y0")
        self.assertEqual(len((self.home / "clones").read_text().splitlines()), 4)
        self.assertEqual(result.stdout.count("插件已存在，无需重复安装。"), 4)
        for folder, _, _ in PLUGINS[3:]:
            self.assertEqual((self.plugin_root / folder / "user.txt").read_text(), "keep this")
        self.assert_no_temporary_plugins()

    def test_partial_clone_failure_can_be_retried(self):
        result = self.run_menu("4y4y0", r'''
attempt=0
git() {
    attempt=$((attempt+1))
    mkdir -p -- "$3" || return 1
    if (( attempt==1 )); then
        printf 'partial\n' > "$3/partial.txt"
        return 128
    fi
    printf 'complete\n' > "$3/manifest.json"
}
''')
        self.assertIn("\x1b[1;31m\x1b[1m>> 安装失败", result.stdout)
        self.assertEqual(result.stdout.count("\x1b[1;32m\x1b[1m>> 安装成功。"), 1)
        final = self.plugin_root / "LittleWhiteBox"
        self.assertEqual((final / "manifest.json").read_text(), "complete\n")
        self.assertFalse((final / "partial.txt").exists())
        self.assert_no_temporary_plugins()

    def test_move_failure_cleans_download_and_reports_failure(self):
        result = self.run_menu("5y0", CLONE_OK + "\nmv() { return 1; }\n")
        self.assertIn("\x1b[1;31m\x1b[1m>> 安装失败", result.stdout)
        self.assertNotIn("安装成功。", result.stdout)
        self.assertFalse((self.plugin_root / "ST-BaiBai-Book").exists())
        self.assert_no_temporary_plugins()

    def test_missing_tavern_does_not_create_a_fake_installation(self):
        self.harness.tavern.rename(self.home / "saved-tavern")
        result = self.run_menu("6y0")
        self.assertIn("未检测到 SillyTavern 目录，请先安装酒馆。", result.stdout)
        self.assertFalse(self.harness.tavern.exists())
        self.assertFalse((self.home / "clones").exists())

    def test_database_details_distinguish_plugin_and_author(self):
        result = self.run_menu("7n0")
        text = re.sub(r"\x1b\[[0-9;]*m", "", result.stdout)
        self.assertIn("插件名称：龙血玄黄·数据库", text)
        self.assertIn("开发作者：Albus", text)
        self.assertIn("https://github.com/AlbusKen/shujuku", text)
        self.assertIn("酒馆助手为可选依赖", text)
        self.assertNotIn("开发作者：阿不思", text)

    def test_uninstall_names_and_selected_directory_match(self):
        for folder, _, _ in PLUGINS:
            test_safety.put(self.plugin_root / folder / "user.txt", "keep until selected")
        listing = self.run_menu("0\n", setup="", menu="plugin_uninstall_menu")
        for _, name, _ in PLUGINS:
            self.assertIn(name, listing.stdout)
        self.assertNotIn("自定模型", listing.stdout)
        for folder, name, _ in PLUGINS[2:]:
            directories = sorted(self.plugin_root.iterdir())
            index = directories.index(self.plugin_root / folder) + 1
            result = self.run_menu(f"{index}\ny0\n", setup="", menu="plugin_uninstall_menu")
            self.assertIn(f"插件 {name} 已卸载。", result.stdout)
            self.assertFalse((self.plugin_root / folder).exists())
            for other in directories:
                if other.name != folder:
                    self.assertEqual((other / "user.txt").read_text(), "keep until selected")


if __name__ == "__main__":
    unittest.main(verbosity=2)
