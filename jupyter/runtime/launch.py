"""Start the authenticated Uni experiments on the student's computer."""
import argparse
import json
import logging
import os
from pathlib import Path
import secrets
import shutil
import sys
import tempfile
from traitlets.config import Config

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[1]


def server_config(root, port, token, lab=None):
    c = Config()
    c.ServerApp.ip = '127.0.0.1'
    c.ServerApp.port = port
    c.ServerApp.port_retries = 0
    c.ServerApp.root_dir = str(root)
    c.ServerApp.open_browser = False
    c.ServerApp.default_url = '/course/index.html'
    if lab:
        from course_runtime import chapter
        c.ServerApp.default_url = '/course/' + chapter(lab)['page']
    c.ServerApp.allow_origin = ''
    c.ServerApp.disable_check_xsrf = False
    c.IdentityProvider.token = token
    c.KernelSpecManager.allowed_kernelspecs = {'jupyter_matlab_kernel'}
    c.ServerApp.jpserver_extensions = {'jupyter_server_proxy': True, 'jupyter_server_terminals': False}
    if (HERE / 'course_runtime.py').exists():
        c.ServerApp.jpserver_extensions['course_runtime'] = True
    return c


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8891)
    parser.add_argument('--matlab', help='Path to the MATLAB executable')
    parser.add_argument('--open', action='store_true', help='Open the authenticated course in the default browser')
    parser.add_argument('--lab', choices=[f'uni{i:02d}' for i in range(1,10)],
                        help='Open a specific experiment instead of Course Index')
    args = parser.parse_args()
    matlab = args.matlab or shutil.which('matlab')
    if not matlab and sys.platform == 'darwin':
        installed = sorted(Path('/Applications').glob('MATLAB_R*/bin/matlab'))
        matlab = str(installed[-1]) if installed else None
    if not matlab or not Path(matlab).is_file():
        raise SystemExit('MATLAB not found. Supply --matlab /path/to/bin/matlab.')
    os.environ['PATH'] = os.pathsep.join((str(Path(sys.executable).parent), str(Path(matlab).parent), os.environ.get('PATH', '')))
    os.environ['MWI_USE_EXISTING_LICENSE'] = 'True'
    os.chdir(PROJECT)
    token = secrets.token_urlsafe(32)
    private = Path(tempfile.mkdtemp(prefix='5g-uni01-session-'))
    private.chmod(0o700)
    state = private / 'connection.json'
    state.write_text(json.dumps({'url':f'http://127.0.0.1:{args.port}', 'token':token,
                                 'pid':os.getpid(), 'project':str(PROJECT)}))
    state.chmod(0o600)
    # Keep startup URLs containing the token in a private log, not build output.
    log = private / 'jupyter.log'
    print(f'Private connection state: {state}', flush=True)
    config = server_config(PROJECT, args.port, token, args.lab)
    print(f'Local course: http://127.0.0.1:{args.port}{config.ServerApp.default_url}', flush=True)
    from jupyter_server.serverapp import ServerApp
    app = ServerApp.instance(config=config)
    app.initialize([])
    app.open_browser = args.open
    handler = logging.FileHandler(log)
    log.chmod(0o600)
    app.log.handlers = [handler]
    app.log.propagate = False
    app.start()


if __name__ == '__main__':
    main()
