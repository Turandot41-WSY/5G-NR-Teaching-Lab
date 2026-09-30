"""Default startup opens the course home; an explicit lab opens that lab."""
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

from test_reference_startup import load
from course_test_data import course_site

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'jupyter/runtime'))


class CourseHomeStartupTests(unittest.TestCase):
    def launch_command(self, arguments):
        launcher = load('start')
        with patch.object(sys, 'argv', ['start.py', *arguments]), \
             patch.object(launcher, 'python_executable', return_value=Path(sys.executable)), \
             patch.object(launcher, 'prepare_environment'), \
             patch.object(launcher, 'prepare_references'), \
             patch.object(launcher, 'needs_rebuild', return_value=False), \
             patch.object(launcher.os, 'chdir'), \
             patch.object(launcher.os, 'execv') as execute:
            launcher.main()
        return execute.call_args.args[1]

    def test_default_launcher_does_not_select_a_lab(self):
        self.assertNotIn('--lab', self.launch_command(['--no-browser']))

    def test_explicit_lab_is_forwarded(self):
        command = self.launch_command(['--lab', 'uni09', '--no-browser'])
        self.assertEqual(command[command.index('--lab')+1], 'uni09')

    def test_server_default_is_course_index(self):
        launcher = load('jupyter/runtime/launch')
        config = launcher.server_config(ROOT, 8895, 'test-only')
        self.assertEqual(config.ServerApp.default_url, '/course/index.html')

    def test_explicit_lab_sets_server_destination(self):
        launcher = load('jupyter/runtime/launch')
        import course_runtime
        with course_site() as site, patch.object(course_runtime, 'SITE', site):
            config = launcher.server_config(ROOT, 8895, 'test-only', lab='uni09')
        self.assertEqual(config.ServerApp.default_url,
                         '/course/uni/uni-09-connected-multiuser-tdd-cell.html')


if __name__ == '__main__':
    unittest.main()
