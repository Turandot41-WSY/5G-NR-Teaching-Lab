"""Install the course with Miniconda, download its PDFs, and prepare notebooks."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import shutil

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--matlab', help='Installed MATLAB executable')
    parser.add_argument('--example-directory', help='Installed MathWorks cell search example folder')
    parser.add_argument('--skip-references', '--skip-documents', dest='skip_references', action='store_true', help='Use official links without downloading PDFs or building the protocol ZIP')
    args = parser.parse_args()
    conda = os.environ.get('CONDA_EXE') or shutil.which('conda')
    if not conda:
        for candidate in (Path(sys.prefix)/'bin/conda', Path(sys.prefix)/'Scripts/conda.exe'):
            if candidate.is_file():
                conda = str(candidate)
                break
    if not conda:
        parser.error('Install Miniconda and run this command from its terminal. See README.md.')
    config = ROOT/'local-config.json'
    data = json.loads(config.read_text()) if config.exists() else {}
    for key in ('matlab', 'example_directory'):
        value = getattr(args, key)
        if value:
            path = Path(value).expanduser().resolve()
            if not path.exists():
                parser.error(f'Path does not exist: {path}')
            data[key] = str(path)
    prefix = ROOT/'.conda'
    if prefix.exists() and not (prefix/'conda-meta').is_dir():
        parser.error('.conda exists but is not a Conda environment; inspect it before continuing.')
    action = 'update' if (prefix/'conda-meta').is_dir() else 'create'
    command = [conda, 'env', action, '--prefix', str(prefix), '--file', str(ROOT/'environment.yml')]
    if action == 'create':
        command.append('--yes')
    subprocess.run(command, cwd=ROOT, check=True)
    python = prefix/('python.exe' if os.name == 'nt' else 'bin/python')
    def run(*command):
        subprocess.run([conda, 'run', '--no-capture-output', '--prefix', str(prefix), *map(str, command)], cwd=ROOT, check=True)
    run(python, '-m', 'pip', 'install', '-r', ROOT/'setup/requirements.txt')
    run(python, '-m', 'pip', 'check')
    run(python, ROOT/'setup/check_environment.py')
    run(python, ROOT/'jupyter/export_notebooks.py')
    run(python, '-c', "from jupyter_client.kernelspec import KernelSpecManager; assert 'jupyter_matlab_kernel' in KernelSpecManager().find_kernel_specs(); print('MATLAB kernel registered')")
    if not args.skip_references:
        run(python, ROOT/'references/3gpp/download.py')
    data['environment'] = '.conda'
    data['download_references'] = not args.skip_references
    config.write_text(json.dumps(data,indent=2)+'\n')
    print('Setup complete. Run: python start.py')
    print('MATLAB and its toolboxes must already be installed and licensed; see README.md.')


if __name__=='__main__':
    main()
