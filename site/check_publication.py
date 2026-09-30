"""Check candidate files, the Git index and reachable history before publication.

This conservative check reports locations and categories without printing secrets.
It does not perform OCR, parse MATLAB arrays, or establish redistribution rights.
"""
import argparse
import json
from pathlib import Path, PurePosixPath
import re
import subprocess


NOREPLY = re.compile(r'^[^<>\s@]+@users\.noreply\.github\.com$')
BLOCKED_PARTS = {'.validation', '.venv', '.conda', '__pycache__', '.pytest_cache',
                 '.ipynb_checkpoints', 'student-site', 'student-source',
                 'student-results', '.obsidian', '101 Context Database'}
BLOCKED_SUFFIXES = {'.pdf', '.zip', '.doc', '.docx', '.ppt', '.pptx', '.epub',
                    '.log', '.pyc', '.pyo', '.pem', '.key'}
PATTERNS = {
    'private key': re.compile(rb'-----BEGIN (?:[A-Z ]+ )?PRIVATE KEY-----'),
    'GitHub credential': re.compile(rb'(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})'),
    'authenticated URL': re.compile(rb'[?&](?:token|access_token|api_key)=[A-Za-z0-9_\-]{16,}'),
    'AWS access key': re.compile(rb'(?:AKIA|ASIA)[A-Z0-9]{16}'),
    'local path': re.compile(rb'(?:/(?:Users|Volumes|home)/[A-Za-z0-9_.-]+/|[A-Za-z]:\\Users\\[^\\\s]+\\)'),
    'private context': re.compile(rb'(?:Project ID: saar[-]5g|Conversation key[:]|101 Context Database[/])'),
}


def git(root, *args):
    return subprocess.run(['git', *args], cwd=root, check=True, capture_output=True).stdout


def path_issue(name):
    path = PurePosixPath(name)
    if (set(path.parts) & BLOCKED_PARTS or path.suffix.lower() in BLOCKED_SUFFIXES
            or path.name in {'.DS_Store', '.env', 'local-config.json', 'AGENTS.md', 'SKILL.md'}
            or path.name.startswith('.env.')
            or any(p.startswith('build-staging-') for p in path.parts)):
        return 'excluded file'
    return None


def inspect(name, data, location):
    issues = []
    reason = path_issue(name)
    if reason:
        issues.append(f'{location}: {name}: {reason}')
    for label, pattern in PATTERNS.items():
        if pattern.search(data):
            issues.append(f'{location}: {name}: {label}')
    if name.endswith('.ipynb'):
        try:
            notebook = json.loads(data)
            if any(c.get('outputs') or c.get('execution_count') is not None
                   for c in notebook['cells'] if c.get('cell_type') == 'code'):
                issues.append(f'{location}: {name}: notebook output')
        except (ValueError, KeyError, TypeError):
            issues.append(f'{location}: {name}: invalid notebook')
    return issues


def audit(root, check_identity=True):
    root = Path(root).resolve()
    issues = []
    if not (root / 'LICENSE').is_file():
        issues.append('working tree: missing LICENSE')
    if check_identity:
        for role in ('GIT_AUTHOR_IDENT', 'GIT_COMMITTER_IDENT'):
            try:
                ident = git(root, 'var', role).decode()
                address = re.search(r'<([^<>]+)>', ident)
                if not address or not NOREPLY.fullmatch(address[1]):
                    issues.append(f'local identity: {role} must use GitHub noreply')
            except subprocess.CalledProcessError:
                issues.append(f'local identity: configure {role} with GitHub noreply')
    names = git(root, 'ls-files', '-z', '--cached', '--others', '--exclude-standard')
    for name in sorted(set(n.decode() for n in names.split(b'\0') if n)):
        path = root / name
        if path.is_symlink():
            issues.append(f'working tree: {name}: symlink requires review')
        elif path.is_file():
            issues.extend(inspect(name, path.read_bytes(), 'working tree'))
    # Check staged bytes independently from the edited working tree.
    for entry in git(root, 'ls-files', '--stage', '-z').split(b'\0'):
        if not entry:
            continue
        meta, name = entry.split(b'\t', 1)
        mode, oid, stage = meta.decode().split()
        name = name.decode()
        if mode != '100644' and mode != '100755':
            issues.append(f'index: {name}: unsupported mode or symlink')
        if stage != '0':
            issues.append(f'index: {name}: unresolved merge')
        if mode.startswith('100'):
            issues.extend(inspect(name, git(root, 'cat-file', 'blob', oid), 'index'))
    # An unborn repository has no commits. All existing refs are otherwise checked.
    refs = git(root, 'for-each-ref', '--format=%(refname)').strip()
    if refs:
        for row in git(root, 'log', '--all', '--format=%h%x09%ae%x09%ce').decode().splitlines():
            commit, author, committer = row.split('\t')
            if not NOREPLY.fullmatch(author) or not NOREPLY.fullmatch(committer):
                issues.append(f'history: {commit}: commit email must use GitHub noreply')
        seen = set()
        blobs = {}
        for commit in git(root, 'rev-list', '--all').decode().splitlines():
            message = git(root, 'show', '-s', '--format=%B', commit)
            issues.extend(inspect(commit[:12], message, 'history commit message'))
            for entry in git(root, 'ls-tree', '-r', '-z', commit).split(b'\0'):
                if not entry or entry in seen:
                    continue
                seen.add(entry)
                meta, name = entry.split(b'\t', 1)
                mode, kind, oid = meta.decode().split()
                name = name.decode()
                if mode not in {'100644', '100755'}:
                    issues.append(f'history: {name}: unsupported mode or symlink')
                if kind == 'blob':
                    if oid not in blobs:
                        blobs[oid] = git(root, 'cat-file', 'blob', oid)
                    issues.extend(inspect(name, blobs[oid], 'history'))
    return sorted(set(issues))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--ci', action='store_true', help='Check committed identities; skip local author configuration')
    args = parser.parse_args()
    try:
        issues = audit(args.root, check_identity=not args.ci)
    except (OSError, subprocess.CalledProcessError) as exc:
        print(f'Publication check could not complete: {type(exc).__name__}')
        return 2
    if issues:
        print('\n'.join(issues))
        print(f'FAIL: {len(issues)} publication findings; review before committing or pushing.')
        return 1
    print('PASS: candidate files, Git index and reachable history passed the publication rules.')
    print('Review new images, MATLAB arrays and third-party permissions separately.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
