"""Both launch paths prepare the protocol archive before exposing a page."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT/(name+'.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ReferenceStartupTests(unittest.TestCase):
    def test_reading_build_prepares_references_before_rendering(self):
        publisher = load('publish_site')
        commands = []
        def run(command, **kwargs):
            commands.append(command)
            return subprocess.CompletedProcess(command, 0, '', '')
        with patch.object(publisher.subprocess, 'run', side_effect=run), \
             patch.object(publisher, 'build_fingerprint', return_value='same'), \
             patch.object(publisher, 'save_build_state'):
            self.assertTrue(publisher.build(False))
        self.assertEqual(Path(commands[0][1]), ROOT/'references/3gpp/download.py')
        self.assertEqual(Path(commands[1][1]), publisher.BUILD)

    def test_download_failure_stops_before_rendering(self):
        publisher = load('publish_site')
        commands = []
        def run(command, **kwargs):
            commands.append(command)
            if str(command[1]).endswith('download.py'):
                raise subprocess.CalledProcessError(1, command)
            return subprocess.CompletedProcess(command, 0, '', '')
        with patch.object(publisher.subprocess, 'run', side_effect=run), \
             patch.object(publisher, 'build_fingerprint', return_value='same'), \
             patch.object(publisher, 'save_build_state') as save:
            self.assertFalse(publisher.build(False))
            save.assert_not_called()
        self.assertEqual(len(commands), 1)

    def test_failed_initial_build_never_serves_stale_official_link(self):
        publisher = load('publish_site')
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(sys, 'argv', ['publish_site.py','serve','--no-browser','--port','0']), \
                 patch.object(publisher, 'python_executable', return_value=Path(sys.executable)), \
                 patch.object(publisher, 'prepare_environment'), \
                 patch.object(publisher, 'ensure_dependencies'), \
                 patch.object(publisher, 'build', return_value=False), \
                 patch.object(publisher, 'SITE', Path(directory)):
                self.assertEqual(publisher.main(), 1)

    def test_start_retries_references_after_installer_skipped_them(self):
        launcher = load('start')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'local-config.json').write_text(json.dumps({'download_references': False}))
            commands = []
            def run(command, **kwargs):
                commands.append(command)
                return subprocess.CompletedProcess(command, 0, '', '')
            with patch.object(launcher, 'ROOT', root), \
                 patch.object(sys, 'argv', ['start.py','--no-browser']), \
                 patch.object(launcher, 'python_executable', return_value=Path(sys.executable)), \
                 patch.object(launcher, 'prepare_environment'), \
                 patch.object(launcher, 'needs_rebuild', return_value=False), \
                 patch.object(launcher.subprocess, 'run', side_effect=run), \
                 patch.object(launcher.os, 'chdir'), \
                 patch.object(launcher.os, 'execv', side_effect=SystemExit(0)):
                with self.assertRaises(SystemExit):
                    launcher.main()
            self.assertTrue(any(str(c[1]).endswith('references/3gpp/download.py') for c in commands))


if __name__ == '__main__':
    unittest.main()
