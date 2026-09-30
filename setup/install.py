"""Reuse installed dependencies, or explicitly create one shared course environment."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'setup'))
from environment_selection import (SHARED_NAME, find_conda, prefix_python,
                                   select_python, shared_prefix)
from runtime_environment import prepare_environment


def install_shared(update=False):
    conda = find_conda()
    if not conda:
        raise RuntimeError('Miniconda is required to create the shared course environment. See README.md.')
    existing = shared_prefix()
    if existing and not update:
        raise RuntimeError('The shared course environment already exists. Run setup without --create to reuse it; '
                           'use --update explicitly if its dependencies need updating.')
    if update and not existing:
        raise RuntimeError('No shared course environment exists. Use --create for the first installation.')
    command = [conda, 'env', 'update' if update else 'create']
    command += ['--prefix', str(existing)] if update else ['--name', SHARED_NAME]
    command += ['--file', str(ROOT/'environment.yml')]
    if not update:
        command.append('--yes')
    print('Installing the shared course runtime (Python, Jupyter and Quarto). '
          'This can use 1–2 GB or more, plus Conda package caches. Other clones will reuse it.', flush=True)
    subprocess.run(command, cwd=ROOT, check=True)
    prefix = existing or shared_prefix()
    if prefix is None:
        raise RuntimeError('Conda did not register the course environment; check its installation output.')
    python = prefix_python(prefix)
    subprocess.run([conda, 'run', '--no-capture-output', '--prefix', str(prefix),
                    str(python), '-m', 'pip', 'install', '-r', str(ROOT/'setup/requirements.txt')],
                   cwd=ROOT, check=True)
    return python


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--python', help='Reuse this existing Python executable; do not install packages')
    action.add_argument('--create', action='store_true', help='Install one shared Conda environment named fiveg-notebooks')
    action.add_argument('--update', action='store_true', help='Update that shared environment explicitly')
    parser.add_argument('--matlab', help='Installed MATLAB executable')
    parser.add_argument('--example-directory', help='Installed MathWorks cell search example folder')
    parser.add_argument('--skip-references', '--skip-documents', dest='skip_references', action='store_true', help='Defer PDFs and the protocol ZIP until startup')
    args = parser.parse_args()
    config = ROOT/'local-config.json'
    data = json.loads(config.read_text()) if config.exists() else {}
    for key in ('matlab', 'example_directory'):
        value = getattr(args, key)
        if value:
            path = Path(value).expanduser().resolve()
            if not path.exists():
                parser.error(f'Path does not exist: {path}')
            data[key] = str(path)
    try:
        explicit = install_shared(update=args.update) if args.create or args.update else args.python
        python = select_python(ROOT, explicit=explicit)
    except (RuntimeError, OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, str(error)+'\n')
    print(f'Using existing Python: {python}', flush=True)
    prepare_environment(python)
    def run(*command):
        subprocess.run([str(python), *map(str, command)], cwd=ROOT, check=True)
    run('-m', 'pip', 'check')
    run(ROOT/'setup/check_environment.py')
    run(ROOT/'jupyter/export_notebooks.py')
    if not args.skip_references:
        run(ROOT/'references/3gpp/download.py')
    data['python'] = str(python.absolute())
    data.pop('environment', None)
    data['download_references'] = not args.skip_references
    config.write_text(json.dumps(data,indent=2)+'\n')
    print('Setup complete. Run: python start.py')
    print('MATLAB and its toolboxes must already be installed and licensed; see README.md.')


if __name__=='__main__':
    main()
