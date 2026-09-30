"""Reuse approved repository assets in local servers without copying their bytes."""
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil
import sys
import tempfile

MANIFEST = 'manifests/local-assets.json'


def read_assets(site):
    try:
        data = json.loads((Path(site)/MANIFEST).read_text())
        if data.get('version') == 1 and isinstance(data.get('assets'), dict):
            return data['assets']
    except (OSError, ValueError, AttributeError):
        pass
    return {}


def source_path(root, relative, record):
    """Allow exact image/protocol mappings only, including after symlink resolution."""
    root = Path(root).resolve()
    parts = PurePosixPath(relative).parts
    if not parts or relative.startswith('/') or '\\' in relative or '..' in parts:
        return None
    if relative.startswith('images/') and relative.endswith('.png'):
        anchor = root/'notes/99 Attachments/5G'
        expected = anchor/relative.removeprefix('images/')
    elif (relative.startswith('references/3gpp/') and len(parts) == 3
          and PurePosixPath(relative).suffix in {'.pdf', '.zip'}):
        anchor = root/'references/3gpp'
        expected = root/relative
    else:
        return None
    if not isinstance(record, dict) or record.get('source') != expected.relative_to(root).as_posix():
        return None
    resolved = expected.resolve()
    if not anchor.resolve().is_relative_to(root) or not resolved.is_relative_to(anchor.resolve()):
        return None
    return resolved if resolved.is_file() else None


def resolve_asset(root, site, relative):
    record = read_assets(site).get(relative)
    return source_path(root, relative, record) if record else None


def compact_assets(root, site, assets):
    """Validate all copies before replacing them with a relative source manifest."""
    root, site = Path(root).resolve(), Path(site).resolve()
    manifest = {}
    for relative, original in assets.items():
        original = Path(original).resolve()
        record = {'source': original.relative_to(root).as_posix(),
                  'sha256': hashlib.sha256(original.read_bytes()).hexdigest()}
        if source_path(root, relative, record) != original:
            raise ValueError(f'Unapproved local resource: {relative}')
        copy = site/relative
        if not copy.resolve().is_relative_to(site) or copy.is_symlink():
            raise ValueError(f'Invalid generated resource: {relative}')
        if not copy.is_file() or hashlib.sha256(copy.read_bytes()).hexdigest() != record['sha256']:
            raise ValueError(f'Generated resource differs from its original: {relative}')
        manifest[relative] = record
    path = site/MANIFEST
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({'version': 1, 'assets': manifest}, indent=2)+'\n')
    for relative in manifest:
        (site/relative).unlink()


def reading_export(root, site, destination):
    """Materialize a portable reading package only for an explicit export."""
    root, site = Path(root).resolve(), Path(site).resolve()
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'references/3gpp'))
    from specifications import reading_archive
    # The temporary copy is needed only while producing a portable ZIP.
    with tempfile.TemporaryDirectory(prefix='fiveg-reading-export-') as directory:
        portable = Path(directory)/'site'
        shutil.copytree(site, portable, ignore=shutil.ignore_patterns('local-assets.json', 'build-inputs.json'))
        for relative, record in read_assets(site).items():
            original = source_path(root, relative, record)
            if original is None:
                raise ValueError(f'Missing original resource; rebuild before export: {relative}')
            data = original.read_bytes()
            if hashlib.sha256(data).hexdigest() != record['sha256']:
                raise ValueError(f'Original resource changed; rebuild before export: {relative}')
            if relative.startswith('images/'):
                target = portable/relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
        reading_archive(root, portable, destination)
