"""Review fixes exercised with Linux locks, local Git, and real offline npm."""
import fcntl
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import unittest

import test_safety


class MaintenanceReviewTests(unittest.TestCase):
    def setUp(self):
        self.harness = test_safety.SafetyTests()
        self.harness.setUp()
        self.addCleanup(self.harness.doCleanups)
        self.home = self.harness.home
        self.tavern = self.harness.tavern

    def git(self, *args):
        return subprocess.check_output([
            'git', '-c', 'core.hooksPath=/dev/null', '-c', 'commit.gpgsign=false',
            '-c', 'user.name=Review Fixture', '-c', 'user.email=review@example.invalid',
            *args], cwd=self.tavern, text=True, stderr=subprocess.STDOUT).strip()

    def versions(self, requirement):
        self.git('-c', 'init.templateDir=', 'init', '--initial-branch=release')
        test_safety.put(self.tavern / '.gitignore', 'data/\npublic/\nnode_modules/\n')
        self.git('add', 'package.json', 'server.js', '.gitignore')
        self.git('commit', '-m', 'original')
        original = self.git('rev-parse', 'HEAD')
        test_safety.put(self.tavern / 'package.json', json.dumps({
            'name': 'sillytavern', 'version': '1.0.0', 'engines': {'node': requirement}}))
        self.git('add', 'package.json')
        self.git('commit', '-m', 'target')
        target = self.git('rev-parse', 'HEAD')
        self.git('tag', 'v-target')
        self.git('reset', '--hard', original)
        test_safety.put(self.tavern / 'node_modules/working-dependency/index.js', 'preserve')
        return original, target

    def npm_override(self):
        if test_safety.NODE.endswith('.exe'):
            cli = Path(test_safety.NODE).parent / 'node_modules/npm/bin/npm-cli.js'
            cli_arg = subprocess.check_output(['wslpath', '-w', str(cli)], text=True).strip()
        else:
            cli_arg = str(Path(shutil.which('npm')).resolve())
        return 'review_npm_cli=' + shlex.quote(cli_arg) + r'''
npm() {
    node -e 'const cli=process.argv[1]; process.argv=[process.argv[0],cli,...process.argv.slice(2)]; require(cli)' \
        -- "$review_npm_cli" "$@" --offline --ignore-scripts \
        --package-lock=false --cache "$TEST_HOME/.npm"
}
git() {
    [[ "$1" != fetch ]] || return 0
    command git -c core.hooksPath=/dev/null -c commit.gpgsign=false "$@"
}
'''

    def test_restore_rejects_running_session_and_preserves_open_file(self):
        self.harness.data_archive()
        with (self.home / '.st_run.flock').open('a') as lock, \
                (self.tavern / 'data/old.txt').open('a+') as writer:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = self.harness.run_bash('import_tavern_data', '1\ny')
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('恢复成功', result.stdout)
            self.assertEqual(os.fstat(writer.fileno()).st_nlink, 1)
            writer.write(' still saved')
            writer.flush()
        self.assertEqual((self.tavern / 'data/old.txt').read_text(), 'old data still saved')

    def test_full_restore_and_other_maintenance_reject_running_session(self):
        self.harness.full_archive()
        test_safety.put(self.tavern / 'node_modules/example/index.js', 'keep')
        for body, stdin in [('import_tavern_full', '1\ny'), ('update_tavern', ''),
                            ('fix_dependencies', ''), ('switch_tavern_version', ''),
                            ('uninstall_all', 'y')]:
            with self.subTest(operation=body), (self.home / '.st_run.flock').open('a') as lock:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                result = self.harness.run_bash(body, stdin)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual((self.tavern / 'node_modules/example/index.js').read_text(), 'keep')
                self.assertFalse((self.home / 'calls').exists())

    def test_maintenance_lock_is_released_after_failure(self):
        result = self.harness.run_bash('pkg() { return 1; }; fix_dependencies')
        self.assertNotEqual(result.returncode, 0)
        with (self.home / '.st_run.flock').open('a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)

    def test_incompatible_tag_preserves_head_and_dependencies_with_real_semver(self):
        original, _ = self.versions('>=999')
        result = self.harness.run_bash(self.npm_override() + '\nswitch_tavern_version',
                                       '1\ny', timeout=30)
        self.assertNotEqual(result.returncode, 0, result.stderr)
        self.assertIn('不满足目标版本要求 >=999', result.stderr)
        self.assertEqual(self.git('rev-parse', 'HEAD'), original)
        self.assertEqual((self.tavern / 'node_modules/working-dependency/index.js').read_text(), 'preserve')
        self.assertNotIn('EBADENGINE', result.stderr)

    def test_compatible_tag_can_switch_and_install_with_real_offline_npm(self):
        _, target = self.versions('>=1')
        shutil.rmtree(self.tavern / 'node_modules')
        result = self.harness.run_bash(self.npm_override() + '\nswitch_tavern_version',
                                       '1\ny', timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git('rev-parse', 'HEAD'), target)
        self.assertIn('版本切换完成', result.stdout)

    def test_failed_dependency_install_returns_failure(self):
        self.versions('>=1')
        result = self.harness.run_bash(self.npm_override() + r'''
check_tag_node_compatibility() { return 0; }
npm() { return 1; }
switch_tavern_version
''', '1\ny')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('版本切换完成', result.stdout)


if __name__ == '__main__':
    unittest.main(verbosity=2)
