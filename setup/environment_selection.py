"""Find and check installed course runtimes without installing packages."""
import contextlib
import importlib
import importlib.metadata
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

SHARED_NAME = 'fiveg-notebooks'
MODULES = ('jupyterlab', 'jupyter_server', 'jupyter_server_proxy', 'matlab_proxy',
           'nbformat', 'requests', 'websocket', 'yaml', 'pycrate_asn1dir.RRCNR')


def prefix_python(prefix, windows=None):
    windows = os.name == 'nt' if windows is None else windows
    prefix = Path(prefix)
    if windows:
        return prefix/('Scripts/python.exe' if (prefix/'pyvenv.cfg').exists() or prefix.name == '.venv'
                       else 'python.exe')
    return prefix/'bin/python'


def find_conda():
    candidates = [os.environ.get('CONDA_EXE'), shutil.which('conda'),
                  str(Path(sys.prefix)/('Scripts/conda.exe' if os.name == 'nt' else 'bin/conda'))]
    return next((c for c in candidates if c and Path(c).is_file()), None)


def registered_environments():
    """Read Conda's registry; never search arbitrary user directories."""
    prefixes = []
    conda = find_conda()
    if conda:
        try:
            result = subprocess.run([conda, 'env', 'list', '--json'], capture_output=True,
                                    text=True, check=True, timeout=15)
            prefixes.extend(json.loads(result.stdout).get('envs', []))
        except (OSError, ValueError, subprocess.SubprocessError):
            pass
    try:
        prefixes.extend((Path.home()/'.conda/environments.txt').read_text().splitlines())
    except OSError:
        pass
    return list(dict.fromkeys(Path(p).expanduser().absolute() for p in prefixes if p))


def shared_prefix():
    matches = [p for p in registered_environments() if p.name == SHARED_NAME and p.is_dir()]
    if len(matches) > 1:
        raise RuntimeError('Several fiveg-notebooks environments exist. Select one with --python PATH.')
    return matches[0] if matches else None


def check_current(root):
    """Return version/import/tool failures for the interpreter running this probe."""
    from runtime_environment import prepare_environment
    prepare_environment(Path(sys.executable))
    issues = []
    if sys.version_info[:2] != (3, 12):
        issues.append(f'Python: expected 3.12, found {sys.version_info.major}.{sys.version_info.minor}')
    for line in (Path(root)/'setup/requirements.txt').read_text().splitlines():
        if not line.strip() or line.startswith('#'):
            continue
        name, expected = line.strip().split('==', 1)
        try:
            actual = importlib.metadata.version(name)
            if actual != expected:
                issues.append(f'{name}: expected {expected}, found {actual}')
        except importlib.metadata.PackageNotFoundError:
            issues.append(f'{name}: missing (expected {expected})')
    for name in MODULES:
        try:
            importlib.import_module(name)
        except Exception as error:
            issues.append(f'{name}: import failed ({type(error).__name__})')
    try:
        from jupyter_client.kernelspec import KernelSpecManager
        if 'jupyter_matlab_kernel' not in KernelSpecManager().find_kernel_specs():
            issues.append('MATLAB kernel: jupyter_matlab_kernel is missing')
    except Exception as error:
        issues.append(f'MATLAB kernel: cannot check registration ({type(error).__name__})')
    quarto = shutil.which('quarto')
    if not quarto:
        issues.append('Quarto: missing (expected 1.8.27)')
    else:
        try:
            version = subprocess.check_output([quarto, '--version'], text=True,
                                              stderr=subprocess.PIPE, timeout=10).strip()
            if version != '1.8.27':
                issues.append(f'Quarto: expected 1.8.27, found {version}')
        except (OSError, subprocess.SubprocessError):
            issues.append('Quarto: version check failed')
    return issues


def probe_environment(python, root):
    python = Path(python).expanduser().absolute()  # Preserve venv symlinks.
    if not python.is_file():
        return ['Python executable does not exist']
    environment = dict(os.environ, PYTHONNOUSERSITE='1', PYTHONDONTWRITEBYTECODE='1')
    environment.pop('PYTHONPATH', None)
    environment.pop('PYTHONHOME', None)
    try:
        result = subprocess.run([str(python), '-s', str(Path(__file__).absolute()), '--probe', str(root)],
                                capture_output=True, text=True, timeout=45, env=environment)
        if result.returncode:
            return [f'Environment check exited with code {result.returncode}']
        report = json.loads(result.stdout)
        if not isinstance(report, list) or any(not isinstance(item, str) for item in report):
            return ['Environment check returned an invalid report']
        return report
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        return [f'Cannot check environment ({type(error).__name__})']


def select_python(root, explicit=None, windows=None):
    root = Path(root)
    config_path = root/'local-config.json'
    config = json.loads(config_path.read_text()) if config_path.is_file() else {}
    configured = explicit or config.get('python')
    if configured:
        path = Path(configured).expanduser().absolute()
        problems = probe_environment(path, root)
        if problems:
            raise RuntimeError(f'The configured or selected environment is unavailable: {path}\n'
                               + '\n'.join(f'  - {p}' for p in problems)
                               + '\nSelect a compatible interpreter with python setup/install.py --python PATH. '
                               'No packages were installed.')
        return path
    legacy = config.get('environment')
    if legacy and legacy not in ('.conda', '.venv'):
        raise RuntimeError('Unknown course environment in local-config.json')
    folders = [legacy] if legacy else ['.venv', '.conda']
    candidates = [prefix_python(root/folder, windows) for folder in folders]
    candidates.append(Path(sys.executable).absolute())
    failures = []
    seen = set()

    def inspect(paths):
        for path in paths:
            path = Path(path).absolute()
            if str(path) in seen or not path.is_file():
                continue
            seen.add(str(path))
            issues = probe_environment(path, root)
            if not issues:
                return path
            failures.append(f'{path}\n' + '\n'.join(f'  - {issue}' for issue in issues))
        return None

    selected = inspect(candidates)
    if selected:
        return selected
    registered = registered_environments()
    shared = [p for p in registered if p.name == SHARED_NAME]
    old_courses = [p for p in registered if p.name in ('.conda', '.venv')
                   and (p.parent/'setup/requirements.txt').is_file()
                   and (p.parent/'jupyter/runtime/launch.py').is_file()]
    selected = inspect(prefix_python(p, windows) for p in [*shared, *old_courses])
    if selected:
        return selected
    raise RuntimeError('No compatible course environment was found. No packages were installed.\n'
                       + '\n'.join(failures)
                       + '\nReuse one: python setup/install.py --python PATH\n'
                         'Create one shared course environment: python setup/install.py --create\n'
                         'A first installation downloads Python, Jupyter and Quarto and can use 1–2 GB or more. '
                         'Future clones reuse that environment.')


if __name__ == '__main__':
    if len(sys.argv) != 3 or sys.argv[1] != '--probe':
        raise SystemExit('This module is used by the course launchers.')
    with contextlib.redirect_stdout(io.StringIO()):
        report = check_current(Path(sys.argv[2]))
    print(json.dumps(report))
