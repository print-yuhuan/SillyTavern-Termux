"""Verify real npm engine enforcement offline, without installing packages."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class EngineTests(unittest.TestCase):
    def test_npm_engine_strict(self):
        node = shutil.which('node')
        self.assertIsNotNone(node)
        if os.name == 'nt':
            cli = Path(node).parent / 'node_modules/npm/bin/npm-cli.js'
            command = [node, str(cli)]
        else:
            npm = shutil.which('npm')
            self.assertIsNotNone(npm)
            command = [npm]
        for engine, expected in [('>=1', True), ('>=999', False)]:
            with self.subTest(engine=engine), tempfile.TemporaryDirectory(prefix='st-engine-test-') as temporary:
                root = Path(temporary)
                (root / 'package.json').write_text(json.dumps({
                    'name': 'st-engine-regression', 'version': '1.0.0', 'engines': {'node': engine}
                }), encoding='utf-8')
                result = subprocess.run(command + ['install', '--engine-strict', '--offline', '--ignore-scripts',
                    '--no-audit', '--no-fund'], cwd=root, env=dict(os.environ, NPM_CONFIG_CACHE=str(root / 'cache')),
                    capture_output=True, text=True, timeout=20)
                self.assertEqual(result.returncode == 0, expected, result.stderr)
                if not expected:
                    self.assertIn('EBADENGINE', result.stderr)


if __name__ == '__main__':
    unittest.main(verbosity=2)
