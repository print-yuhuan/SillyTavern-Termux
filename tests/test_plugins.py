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

    def run_menu(self, stdin, setup=CLONE_OK, menu="plugin_install_menu", scope=1):
        if scope is not None:
            stdin = f"{scope}\n" + stdin
        result = self.harness.run_bash(setup + "\n" + menu, stdin)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def user_root(self, username):
        user = self.harness.tavern / "data" / username
        user.mkdir(exist_ok=True)
        return user / "extensions"

    def assert_no_temporary_plugins(self):
        self.assertEqual(list(self.harness.tavern.rglob(".plugin-install.*")), [])

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

    def test_all_seven_plugins_can_be_installed_for_a_private_user(self):
        selected = self.user_root("default-user")
        self.run_menu("".join(f"{choice}y" for choice in range(1, 8)) + "0", scope=2)
        self.assertFalse(self.plugin_root.exists())
        self.assertEqual((self.home / "clones").read_text().splitlines(), [p[2] for p in PLUGINS])
        for folder, _, _ in PLUGINS:
            self.assertEqual((selected / folder / "manifest.json").read_text(), "test plugin\n")
        self.assert_no_temporary_plugins()

    def test_scope_list_filters_system_directories_files_and_symlink_users(self):
        data = self.harness.tavern / "data"
        for name in ("_cache", "_css", "_errors", "_storage", "_uploads", "_webpack", ".hidden"):
            (data / name).mkdir()
        test_safety.put(data / "not-a-user", "regular file")
        elsewhere = self.home / "other-user"
        elsewhere.mkdir()
        (data / "aaa-linked-user").symlink_to(elsewhere, target_is_directory=True)
        selected = self.user_root("default-user")

        listing = self.run_menu("0\n", scope=None)
        self.assertIn("default-user", listing.stdout)
        for name in ("_cache", "_css", "_errors", "_storage", "_uploads", "_webpack",
                     ".hidden", "not-a-user", "aaa-linked-user"):
            self.assertNotIn(name, listing.stdout)
        self.assertFalse(selected.exists(), "Listing users must not create private extension directories")

        self.run_menu("4y0", scope=2)
        self.assertTrue((selected / "LittleWhiteBox/manifest.json").is_file())
        self.assertEqual(list(elsewhere.iterdir()), [])

    def test_scope_numbers_support_multiple_digits_and_stable_username_order(self):
        roots = {f"user-{index:02}": self.user_root(f"user-{index:02}") for index in range(11, 0, -1)}
        self.run_menu("4y0", scope=12)
        for username, root in roots.items():
            self.assertEqual((root / "LittleWhiteBox/manifest.json").exists(), username == "user-11")
        self.assertFalse(self.plugin_root.exists())

    def test_uninstall_accepts_multiple_digit_scope_and_plugin_numbers(self):
        roots = [self.user_root(f"user-{index:02}") for index in range(1, 12)]
        for index in range(1, 13):
            test_safety.put(roots[-1] / f"plugin-{index:02}/user.txt", "selected user")
        result = self.run_menu("9" * 200 + "\n12\ny0\n", setup="",
                               menu="plugin_uninstall_menu", scope=12)
        self.assertIn("插件 plugin-12 已卸载。", result.stdout)
        self.assertFalse((roots[-1] / "plugin-12").exists())
        for index in range(1, 12):
            self.assertEqual((roots[-1] / f"plugin-{index:02}/user.txt").read_text(), "selected user")
        self.assertTrue(all(not root.exists() for root in roots[:-1]))
        self.assertFalse(self.plugin_root.exists())

    def test_username_spaces_and_non_ascii_characters_are_preserved(self):
        first = self.user_root("Alice Example")
        second = self.user_root("用户甲")
        self.run_menu("7y0", scope=3)
        self.assertTrue((second / "shujuku/manifest.json").is_file())
        self.assertFalse(first.exists())
        self.assertFalse(self.plugin_root.exists())

    def test_invalid_scope_numbers_and_eof_never_select_public_implicitly(self):
        self.user_root("alice")
        for menu in ("plugin_install_menu", "plugin_uninstall_menu"):
            for stdin in ("", "0\n", "99\n", "-1\n01\n0\n", "9" * 200 + "\n0\n"):
                with self.subTest(menu=menu, stdin=stdin):
                    self.run_menu(stdin, setup="", menu=menu, scope=None)
                    self.assertFalse(self.plugin_root.exists())
                    self.assertFalse((self.home / "clones").exists())

    def test_same_plugin_can_exist_in_public_and_multiple_private_scopes(self):
        alice = self.user_root("alice")
        bob = self.user_root("bob")
        for scope in (1, 2, 3):
            self.run_menu("4y0", scope=scope)
        for root in (self.plugin_root, alice, bob):
            self.assertEqual((root / "LittleWhiteBox/manifest.json").read_text(), "test plugin\n")
        self.assertEqual(len((self.home / "clones").read_text().splitlines()), 3)

    def test_uninstall_only_lists_and_removes_the_selected_user_plugins(self):
        alice = self.user_root("alice")
        bob = self.user_root("bob")
        for root, marker in ((self.plugin_root, "public"), (alice, "alice"), (bob, "bob")):
            test_safety.put(root / "LittleWhiteBox/user.txt", marker)
        test_safety.put(self.plugin_root / "shujuku/user.txt", "public-only")
        test_safety.put(bob / "JS-Slash-Runner/user.txt", "bob-only")
        listing = self.run_menu("0\n", setup="", menu="plugin_uninstall_menu", scope=2)
        self.assertIn("小白X", listing.stdout)
        self.assertNotIn("龙血玄黄·数据库", listing.stdout)
        self.assertNotIn("酒馆助手", listing.stdout)

        result = self.run_menu("1\ny0\n", setup="", menu="plugin_uninstall_menu", scope=2)
        self.assertIn("插件 小白X 已卸载。", result.stdout)
        self.assertFalse((alice / "LittleWhiteBox").exists())
        for root, marker in ((self.plugin_root, "public"), (bob, "bob")):
            self.assertEqual((root / "LittleWhiteBox/user.txt").read_text(), marker)
        self.assertTrue((self.plugin_root / "shujuku/user.txt").is_file())
        self.assertTrue((bob / "JS-Slash-Runner/user.txt").is_file())

    def test_public_is_option_one_even_when_private_users_exist(self):
        alice = self.user_root("alice")
        self.run_menu("7y0", scope=1)
        self.assertTrue((self.plugin_root / "shujuku/manifest.json").is_file())
        self.assertFalse(alice.exists())
        result = self.run_menu("1\ny0\n", setup="", menu="plugin_uninstall_menu", scope=1)
        self.assertIn("已卸载", result.stdout)
        self.assertFalse((self.plugin_root / "shujuku").exists())

    def test_empty_private_scope_returns_without_creating_extensions(self):
        alice = self.user_root("alice")
        result = self.run_menu("0\n", setup="", menu="plugin_uninstall_menu", scope=2)
        self.assertFalse(alice.exists())
        self.assertNotIn("已卸载", result.stdout)
        self.assertFalse(self.plugin_root.exists())

    def test_returning_to_scope_list_allows_switching_install_target(self):
        alice = self.user_root("alice")
        self.run_menu("1\n4y02\n7y00\n", scope=None)
        self.assertTrue((self.plugin_root / "LittleWhiteBox/manifest.json").is_file())
        self.assertTrue((alice / "shujuku/manifest.json").is_file())
        self.assertFalse((self.plugin_root / "shujuku").exists())
        self.assertFalse((alice / "LittleWhiteBox").exists())

    def test_private_extensions_symlink_is_rejected_for_install_and_uninstall(self):
        alice = self.user_root("alice")
        elsewhere = self.home / "other-extensions"
        test_safety.put(elsewhere / "LittleWhiteBox/user.txt", "must survive")
        alice.symlink_to(elsewhere, target_is_directory=True)
        self.run_menu("4y0", scope=2)
        result = self.run_menu("1\ny0\n", setup="", menu="plugin_uninstall_menu", scope=2)
        self.assertEqual((elsewhere / "LittleWhiteBox/user.txt").read_text(), "must survive")
        self.assertFalse((self.home / "clones").exists())
        self.assertNotIn("已卸载", result.stdout)
        self.assertFalse(self.plugin_root.exists())

    def test_public_extensions_symlink_is_rejected_for_install_and_uninstall(self):
        elsewhere = self.home / "other-extensions"
        test_safety.put(elsewhere / "LittleWhiteBox/user.txt", "must survive")
        self.plugin_root.parent.mkdir(parents=True)
        self.plugin_root.symlink_to(elsewhere, target_is_directory=True)
        self.run_menu("4y0")
        result = self.run_menu("1\ny0\n", setup="", menu="plugin_uninstall_menu")
        self.assertEqual((elsewhere / "LittleWhiteBox/user.txt").read_text(), "must survive")
        self.assertFalse((self.home / "clones").exists())
        self.assertNotIn("已卸载", result.stdout)

    def test_existing_plugin_symlink_never_overwrites_another_user(self):
        alice = self.user_root("alice")
        bob = self.user_root("bob")
        test_safety.put(bob / "LittleWhiteBox/user.txt", "bob")
        alice.mkdir()
        (alice / "LittleWhiteBox").symlink_to(bob / "LittleWhiteBox", target_is_directory=True)
        self.run_menu("4y0", scope=2)
        self.assertEqual((bob / "LittleWhiteBox/user.txt").read_text(), "bob")
        self.assertFalse((self.home / "clones").exists())

    def test_uninstall_ignores_staging_directories_and_plugin_symlinks(self):
        alice = self.user_root("alice")
        bob = self.user_root("bob")
        test_safety.put(alice / "LittleWhiteBox/user.txt", "alice")
        test_safety.put(alice / ".plugin-install.in-progress/download.txt", "partial")
        test_safety.put(bob / "shujuku/user.txt", "bob")
        (alice / "000-linked-plugin").symlink_to(bob / "shujuku", target_is_directory=True)
        listing = self.run_menu("0\n", setup="", menu="plugin_uninstall_menu", scope=2)
        self.assertNotIn(".plugin-install.in-progress", listing.stdout)
        self.assertNotIn("000-linked-plugin", listing.stdout)
        self.run_menu("1\ny0\n", setup="", menu="plugin_uninstall_menu", scope=2)
        self.assertFalse((alice / "LittleWhiteBox").exists())
        self.assertEqual((alice / ".plugin-install.in-progress/download.txt").read_text(), "partial")
        self.assertEqual((bob / "shujuku/user.txt").read_text(), "bob")

    def test_user_removed_after_selection_is_not_recreated_during_install(self):
        alice = self.user_root("alice")
        result = self.run_menu("4y0", CLONE_OK + r'''
show_community_plugin_details() {
    rm -rf -- "$TEST_HOME/SillyTavern/data/alice"
}
''', scope=2)
        self.assertFalse(alice.parent.exists())
        self.assertFalse((self.home / "clones").exists())
        self.assertNotIn("安装成功。", result.stdout)
        self.assertFalse(self.plugin_root.exists())

    def test_failed_uninstall_reports_failure_and_preserves_the_plugin(self):
        test_safety.put(self.plugin_root / "LittleWhiteBox/user.txt", "keep")
        result = self.run_menu("1\ny0\n", setup="rm() { return 1; }", menu="plugin_uninstall_menu")
        self.assertEqual((self.plugin_root / "LittleWhiteBox/user.txt").read_text(), "keep")
        self.assertIn("卸载失败", result.stdout)
        self.assertNotIn("已卸载", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
