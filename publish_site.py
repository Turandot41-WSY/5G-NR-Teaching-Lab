#!/usr/bin/env python3
"""Build the Saarland University 5G NR Teaching Knowledge Base website from the notes, serve it, and
rebuild it whenever a note, figure, manifest or theme file changes.

    python3 publish_site.py            build, serve on http://localhost:8765, watch for changes
    python3 publish_site.py build      build once (add --validate to run the full validator)
    python3 publish_site.py export     build a portable reading ZIP (optional --validate)
    python3 publish_site.py serve      build, serve and watch (options: --port, --no-watch, --no-browser, --validate)

Requirements: a compatible environment selected by python setup/install.py.
Every page is generated from the Markdown notes in this folder, so editing a note
in Obsidian and saving it is enough: the watcher rebuilds the site and you reload the browser.
"""
from __future__ import annotations

import argparse
import errno
import functools
import hashlib
import http.server
import json
import os
import shutil
import subprocess
import sys
import threading
import time
import webbrowser
from pathlib import Path
from urllib.parse import unquote, urlsplit
from urllib.request import build_opener, ProxyHandler

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'setup'))
from runtime_environment import python_executable, prepare_environment, prepare_references
EXPORT = ROOT / "site"
sys.path.insert(0, str(EXPORT))
from local_assets import resolve_asset
SITE = EXPORT / "student-site"
BUILD = EXPORT / "build_student_export.py"
VALIDATE = ROOT / "site/validate_distribution.py"
WATCHED = [
    ROOT / "LICENSE",
    ROOT / "notes" / "05 Knowledge Syntheses",
    ROOT / "notes" / "Course Index.md",
    ROOT / "notes" / "Uni Engineering Index.md",
    ROOT / "notes" / "09 Abbreviation Database",
    ROOT / "notes" / "01 Source Collections",
    ROOT / "references/3gpp",
    ROOT / "notes" / "99 Attachments",
    EXPORT / "tokens.css",
    EXPORT / "export_theme.py",
    EXPORT / "note_annotations.py",
    EXPORT / "approved-design.css",
    EXPORT / "build_student_export.py",
    EXPORT / "local_assets.py",
    ROOT / "jupyter/runtime/course_runtime.py",
    VALIDATE,
    ROOT / "publish_site.py",
    ROOT / "setup/runtime_environment.py",
    ROOT / "setup/environment_selection.py",
]
WATCH_SUFFIXES = {".md", ".yml", ".yaml", ".json", ".css", ".py", ".png", ".pdf", ".zip"}


def say(message: str) -> None:
    print(time.strftime("%H:%M:%S"), message, flush=True)


def ensure_dependencies() -> None:
    try:
        import yaml  # noqa: F401
    except ImportError:
        sys.exit('PyYAML is missing. Select a compatible environment with python setup/install.py. No packages were installed.')
    if shutil.which("quarto") is None:
        sys.exit("Quarto was not found on the PATH. Install it from https://quarto.org and run this script again.")


def snapshot() -> dict[str, tuple[int, int, int]]:
    state: dict[str, tuple[int, int, int]] = {}
    for target in WATCHED:
        paths = target.rglob("*") if target.is_dir() else (target,)
        for path in paths:
            try:
                if path.is_file() and (path.suffix.lower() in WATCH_SUFFIXES or path.name == 'LICENSE'):
                    stat = path.stat()
                    state[str(path)] = (stat.st_mtime_ns, stat.st_ctime_ns, stat.st_size)
            except FileNotFoundError:
                # Editors can replace or remove a file between discovery and stat.
                continue
    return state


def build_fingerprint() -> str:
    state = {Path(path).relative_to(ROOT).as_posix(): values for path, values in snapshot().items()}
    return hashlib.sha256(json.dumps(state, sort_keys=True).encode()).hexdigest()


def needs_rebuild() -> bool:
    try:
        state = json.loads((SITE/'manifests/build-inputs.json').read_text())
    except (FileNotFoundError, ValueError):
        return True
    return not (SITE/'index.html').is_file() or state.get('fingerprint') != build_fingerprint()


def save_build_state() -> None:
    path = SITE/'manifests/build-inputs.json'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({'fingerprint': build_fingerprint()}) + '\n')


def build(validate: bool, archive: bool = False) -> bool:
    try:
        prepare_references(ROOT, sys.executable)
    except (subprocess.CalledProcessError, OSError) as error:
        say(f'PROTOCOL PREPARATION FAILED: {error}. Resolve the error above and rerun the same command.')
        return False
    say("building the site from the notes ...")
    started = time.time()
    input_state = build_fingerprint()
    command = [sys.executable, str(BUILD)]
    if archive:
        command.append('--archive')
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        tail = (result.stdout + result.stderr).strip().splitlines()[-25:]
        print("\n".join(tail))
        say("BUILD FAILED: fix the message above and save again")
        return False
    say(f"site built in {time.time() - started:.0f} s")
    if validate:
        say("validating ...")
        result = subprocess.run([sys.executable, str(VALIDATE)], cwd=ROOT)
        if result.returncode != 0:
            say("VALIDATION FAILED: fix the message above and save again")
            return False
    if input_state != build_fingerprint():
        say('Source changed during the build; rebuild again before starting')
        return False
    save_build_state()
    return True


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        relative = unquote(urlsplit(path).path).lstrip('/')
        original = resolve_asset(ROOT, Path(self.directory), relative)
        return str(original) if original else super().translate_path(path)

    def log_message(self, format: str, *args) -> None:  # noqa: A002
        pass

    def do_GET(self) -> None:
        if urlsplit(self.path).path == '/__course_status':
            data = json.dumps({'service': '5g-reading', 'version': 1,
                               'project': self.server.project_key,
                               'ready': self.server.ready}).encode()
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            self.wfile.write(data)
            return
        if not self.server.ready:
            self.send_error(503, 'The course is being prepared. Refresh after the terminal reports ready.')
            return
        super().do_GET()

    def do_HEAD(self) -> None:
        if not self.server.ready:
            self.send_error(503, 'The course is being prepared.')
            return
        super().do_HEAD()


def project_key() -> str:
    return hashlib.sha256(str(ROOT.resolve()).encode()).hexdigest()


def existing_reading_server(port: int) -> dict | None:
    """Verify a listener belongs to this checkout before reusing its URL."""
    try:
        opener = build_opener(ProxyHandler({}))
        with opener.open(f'http://127.0.0.1:{port}/__course_status', timeout=1) as response:
            state = json.loads(response.read(4096))
        if (isinstance(state, dict) and state.get('service') == '5g-reading'
                and state.get('version') == 1 and state.get('project') == project_key()
                and isinstance(state.get('ready'), bool)):
            return state
    except (OSError, ValueError):
        pass
    return None


def serve(port: int) -> http.server.ThreadingHTTPServer:
    handler = functools.partial(QuietHandler, directory=str(SITE))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)
    server.project_key = project_key()
    server.ready = False
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def watch(validate: bool, initial_state: dict[str, tuple[int, int, int]] | None = None) -> None:
    say("watching the notes; save a note in Obsidian and the site rebuilds (Ctrl+C stops)")
    last = snapshot() if initial_state is None else initial_state
    while True:
        time.sleep(2)
        current = snapshot()
        if current == last:
            continue
        # wait until the editor has finished writing
        while True:
            time.sleep(1.5)
            again = snapshot()
            if again == current:
                break
            current = again
        changed = [Path(k).name for k in current if last.get(k) != current[k]] + [Path(k).name for k in last if k not in current]
        say("changed: " + ", ".join(changed[:6]) + (" ..." if len(changed) > 6 else ""))
        if build(validate):
            say("site updated; reload the browser")
        last = current


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command")
    b = sub.add_parser("build", help="build the site once")
    b.add_argument("--validate", action="store_true", help="run the full validator after building")
    e = sub.add_parser("export", help="build and export a portable reading ZIP")
    e.add_argument("--validate", action="store_true", help="run the full validator after building")
    s = sub.add_parser("serve", help="build, serve and watch")
    s.add_argument("--port", type=int, default=8765)
    s.add_argument("--validate", action="store_true", help="run the full validator after every build")
    s.add_argument("--no-watch", action="store_true", help="serve without rebuilding on changes")
    s.add_argument("--no-browser", action="store_true", help="do not open the browser")
    argv = sys.argv[1:]
    if not argv or argv[0].startswith('--') and argv[0] not in ('--help', '-h'):
        argv = ['serve', *argv]
    args = parser.parse_args(argv)
    try:
        python = python_executable(ROOT)
    except (RuntimeError, OSError, ValueError) as error:
        say(str(error))
        return 1
    prepare_environment(python)
    # Resolving a venv symlink would compare equal to its base interpreter.
    if Path(sys.executable).absolute() != python.absolute():
        os.execv(str(python), [str(python), str(Path(__file__).resolve()), *sys.argv[1:]])
    command = args.command or "serve"
    if command in {"build", "export"}:
        ensure_dependencies()
        if command == 'export':
            return 0 if build(args.validate, archive=True) else 1
        return 0 if build(args.validate) else 1
    port = getattr(args, "port", 8765)
    try:
        server = serve(port)
    except OSError as error:
        if error.errno == errno.EADDRINUSE:
            state = existing_reading_server(port)
            if state is not None:
                url = f'http://localhost:{port}/'
                if state['ready']:
                    say(f'This course is already running at {url}; reusing the existing server.')
                    if not getattr(args, 'no_browser', False):
                        webbrowser.open(url)
                else:
                    say(f'This course is already preparing at {url}; wait for its terminal to report ready.')
                return 0
            say(f'Port {port} is occupied by another service or an older course server. '
                f'Stop that service in its terminal with Ctrl+C, or choose an unused port: '
                f'python publish_site.py --port {port + 1}. No build was started.')
        else:
            say(f'Cannot start the reading server on port {port}: {error}')
        return 1
    try:
        ensure_dependencies()
        if not build(getattr(args, 'validate', False)):
            return 1
        initial_state = snapshot()
        server.ready = True
        url = f'http://localhost:{server.server_port}/'
        say(f'serving {url}')
        if not getattr(args, 'no_browser', False):
            webbrowser.open(url)
        if getattr(args, "no_watch", False):
            while True:
                time.sleep(3600)
        watch(getattr(args, "validate", False), initial_state=initial_state)
    except KeyboardInterrupt:
        say("stopping")
    finally:
        server.shutdown()
        server.server_close()
    return 0


if __name__ == "__main__":
    os.chdir(ROOT)
    raise SystemExit(main())
