"""Start the course locally with the student's installed MATLAB."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'setup'))
from runtime_environment import python_executable, prepare_environment, prepare_references
from publish_site import needs_rebuild


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--lab', choices=[f'uni{i:02d}' for i in range(1,10)],
                   help='Open a specific experiment instead of Course Index')
    p.add_argument('--port', type=int, default=8891)
    p.add_argument('--matlab', help='MATLAB executable, if it is not on PATH')
    p.add_argument('--no-browser', action='store_true')
    p.add_argument('--rebuild', action='store_true', help='Rebuild reading pages before starting')
    p.add_argument('--check-environment', action='store_true', help='Check installed dependencies and rendering, then exit without downloads or a server')
    args = p.parse_args()
    try:
        python = python_executable(ROOT)
    except (RuntimeError, OSError, ValueError) as error:
        p.exit(1, str(error)+'\n')
    print(f'Using existing Python: {python}', flush=True)
    prepare_environment(python)
    if args.check_environment:
        subprocess.run([str(python), str(ROOT/'setup/check_environment.py')], cwd=ROOT, check=True)
        return
    config = ROOT / 'local-config.json'
    cfg = json.loads(config.read_text()) if config.exists() else {}
    if cfg.get('example_directory'):
        os.environ['NR_CELL_SEARCH_EXAMPLE'] = cfg['example_directory']
    try:
        prepare_references(ROOT, python)
    except (subprocess.CalledProcessError, OSError) as error:
        p.exit(1, f'Protocol preparation failed: {error}. Resolve the error above and rerun python start.py.\n')
    if args.rebuild or needs_rebuild():
        subprocess.run([str(python),str(ROOT/'publish_site.py'),'build'],cwd=ROOT,check=True)
    cmd=[str(python),str(ROOT/'jupyter/runtime/launch.py'),'--port',str(args.port)]
    if args.lab: cmd.extend(['--lab',args.lab])
    matlab=args.matlab or cfg.get('matlab')
    if matlab: cmd.extend(['--matlab',matlab])
    if not args.no_browser: cmd.append('--open')
    os.chdir(ROOT)
    os.execv(str(python),cmd)


if __name__=='__main__':
    main()
