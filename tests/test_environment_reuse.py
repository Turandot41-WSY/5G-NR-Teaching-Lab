"""A fresh clone reuses dependencies without installing another environment."""
import builtins
import contextlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import venv
from unittest.mock import patch

from test_reference_startup import load, ROOT

sys.path.insert(0, str(ROOT/'setup'))


class EnvironmentReuseTests(unittest.TestCase):
    def test_matlab_locator_reads_explicit_interpreter(self):
        source = (ROOT/'matlab/course_python.m').read_text()
        self.assertIn("isfield(c,'python')", source)
        self.assertIn('python=c.python;', source)

    def test_installer_missing_dependencies_never_calls_conda(self):
        installer = load('setup/install')
        with patch.object(sys, 'argv', ['install.py']), \
             patch.object(installer, 'select_python', side_effect=RuntimeError('jupyterlab: missing')), \
             patch.object(installer.subprocess, 'run') as run, contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as stopped:
                installer.main()
            self.assertEqual(stopped.exception.code, 1)
            run.assert_not_called()

    def test_windows_conda_and_venv_paths(self):
        module = self.selection()
        self.assertEqual(module.prefix_python(Path('course-env'), windows=True), Path('course-env/python.exe'))
        self.assertEqual(module.prefix_python(Path('.venv'), windows=True), Path('.venv/Scripts/python.exe'))

    def test_registered_old_course_environment_is_considered(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            old = root/'old course'
            for name in ('setup/requirements.txt', 'jupyter/runtime/launch.py', '.conda/bin/python'):
                path = old/name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.touch()
            new = root/'new course'
            new.mkdir()
            python = old/'.conda/bin/python'
            with patch.object(module, 'registered_environments', return_value=[old/'.conda']), \
                 patch.object(module, 'probe_environment', side_effect=lambda p, r: [] if p == python else ['missing']):
                self.assertEqual(module.select_python(new, windows=False), python)

    def selection(self):
        self.assertTrue((ROOT/'setup/environment_selection.py').is_file(),
                        'Environment discovery and dependency checks are missing')
        return load('setup/environment_selection')

    def test_fresh_clone_uses_current_compatible_python(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory, \
             patch.object(module, 'registered_environments', return_value=[]), \
             patch.object(module, 'probe_environment', return_value=[]) as probe:
            self.assertEqual(module.select_python(Path(directory)), Path(sys.executable).absolute())
            self.assertEqual(probe.call_args.args[0], Path(sys.executable).absolute())
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_explicit_python_is_saved_without_resolving_venv_symlink(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            python = root/'old clone/.venv/bin/python'
            python.parent.mkdir(parents=True)
            python.symlink_to(sys.executable)
            (root/'local-config.json').write_text(json.dumps({'python': str(python)}))
            with patch.object(module, 'probe_environment', return_value=[]):
                self.assertEqual(module.select_python(root), python)

    def test_broken_explicit_choice_does_not_silently_switch(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'local-config.json').write_text(json.dumps({'python': str(root/'missing')}))
            with self.assertRaisesRegex(RuntimeError, 'configured|selected'):
                module.select_python(root)

    def test_missing_packages_report_no_automatic_install(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory, \
             patch.object(module, 'registered_environments', return_value=[]), \
             patch.object(module, 'probe_environment', return_value=['jupyterlab: missing']):
            with self.assertRaisesRegex(RuntimeError, 'jupyterlab: missing') as error:
                module.select_python(Path(directory))
            self.assertIn('--create', str(error.exception))
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_shared_environment_reused_across_two_clones(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            python = base/'envs/fiveg-notebooks/bin/python'
            python.parent.mkdir(parents=True)
            python.touch()
            with patch.object(module, 'registered_environments', return_value=[python.parent.parent]), \
                 patch.object(module, 'probe_environment', side_effect=lambda p, r: [] if p == python else ['missing']):
                for clone in ('one', 'two'):
                    root = base/clone
                    root.mkdir()
                    self.assertEqual(module.select_python(root, windows=False), python)
                    self.assertEqual(list(root.iterdir()), [])

    def test_real_probe_reports_incomplete_python(self):
        module = self.selection()
        with tempfile.TemporaryDirectory() as directory:
            venv.EnvBuilder(with_pip=False).create(directory)
            issues = module.probe_environment(module.prefix_python(Path(directory)), ROOT)
        self.assertTrue(any('jupyter-matlab-proxy' in item for item in issues), issues)

    def test_installer_default_reuses_and_preserves_config_without_installing(self):
        installer = load('setup/install')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'local-config.json').write_text(json.dumps({'matlab': 'keep-this-setting'}))
            self.assertTrue(hasattr(installer, 'select_python'), 'Installer always installs a new environment')
            with patch.object(installer, 'ROOT', root), \
                 patch.object(sys, 'argv', ['install.py', '--skip-references']), \
                 patch.object(installer, 'select_python', return_value=Path(sys.executable)), \
                 patch.object(installer.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0)) as run:
                installer.main()
            commands = [call.args[0] for call in run.call_args_list]
            self.assertFalse(any('install' in c or 'create' in c or 'update' in c for c in commands), commands)
            self.assertFalse((root/'.conda').exists())
            config = json.loads((root/'local-config.json').read_text())
            self.assertEqual(config['python'], str(Path(sys.executable).absolute()))
            self.assertEqual(config['matlab'], 'keep-this-setting')

    def test_create_targets_shared_conda_name_not_checkout(self):
        installer = load('setup/install')
        self.assertTrue(hasattr(installer, 'install_shared'), 'Shared installation is missing')
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory)/'envs/fiveg-notebooks'
            python = prefix/'bin/python'
            with patch.object(installer, 'find_conda', return_value='conda'), \
                 patch.object(installer, 'shared_prefix', side_effect=[None, prefix]), \
                 patch.object(installer.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0)) as run:
                self.assertEqual(installer.install_shared(update=False), python)
            first = run.call_args_list[0].args[0]
            self.assertEqual(first[:5], ['conda', 'env', 'create', '--name', 'fiveg-notebooks'])
            self.assertNotIn('--prefix', first)

    def test_create_does_not_overwrite_existing_shared_environment(self):
        installer = load('setup/install')
        self.assertTrue(hasattr(installer, 'install_shared'))
        with patch.object(installer, 'find_conda', return_value='conda'), \
             patch.object(installer, 'shared_prefix', return_value=Path('/existing/fiveg-notebooks')), \
             patch.object(installer.subprocess, 'run') as run:
            with self.assertRaisesRegex(RuntimeError, '--update'):
                installer.install_shared(update=False)
            run.assert_not_called()

    def test_publisher_does_not_pip_install_missing_yaml(self):
        publisher = load('publish_site')
        original_import = builtins.__import__
        def importing(name, *args, **kwargs):
            if name == 'yaml':
                raise ImportError('test missing PyYAML')
            return original_import(name, *args, **kwargs)
        with patch('builtins.__import__', side_effect=importing), \
             patch.object(publisher.subprocess, 'check_call') as install, \
             patch.object(publisher.shutil, 'which', return_value='quarto'):
            with self.assertRaises(SystemExit):
                publisher.ensure_dependencies()
            install.assert_not_called()

    def test_start_check_only_does_not_download_build_or_launch(self):
        launcher = load('start')
        with patch.object(sys, 'argv', ['start.py', '--check-environment']), \
             patch.object(launcher, 'python_executable', return_value=Path(sys.executable)), \
             patch.object(launcher, 'prepare_environment'), \
             patch.object(launcher, 'prepare_references') as refs, \
             patch.object(launcher.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0)), \
             patch.object(launcher.os, 'execv') as execute:
            try:
                launcher.main()
            except SystemExit as error:
                self.fail(f'Check-only startup is missing: {error}')
            refs.assert_not_called()
            execute.assert_not_called()


if __name__ == '__main__':
    unittest.main()
