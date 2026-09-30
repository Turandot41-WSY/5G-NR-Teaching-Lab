"""Verify local official PDFs and resolve reading links without redistributing them."""
import hashlib
import json
import os
import posixpath
from pathlib import Path
import shutil
import zipfile
import tempfile

PROTOCOL_ZIP = 'references/3gpp/3GPP-Rel-18-Core-Specifications.zip'
OFFICIAL_INDEX = 'https://www.3gpp.org/dynareport/38-series.htm'


def records(root):
    return json.loads((Path(root)/'references/3gpp/specifications.json').read_text())


def verify_pdf(data, record):
    if not data.startswith(b'%PDF-') or hashlib.sha256(data).hexdigest() != record['sha256']:
        raise ValueError(f"PDF content or SHA-256 mismatch: {record['filename']}")


def migrate_legacy_downloads(root):
    """Move only known, verified PDFs left by the previous repository layout."""
    old = Path(root)/'documents/3gpp'
    folder = Path(root)/'references/3gpp'
    for record in records(root):
        filename = record['filename']
        if Path(filename).name != filename or not filename.endswith('.pdf'):
            raise ValueError('Invalid specification filename')
        source, target = old/filename, folder/filename
        if source.is_file():
            verify_pdf(source.read_bytes(), record)
            if target.exists():
                verify_pdf(target.read_bytes(), record)
                source.unlink()
            else:
                source.rename(target)
    for directory in (old, old.parent):
        if directory.is_dir() and not any(directory.iterdir()):
            directory.rmdir()


def verified_documents(root):
    found = []
    for record in records(root):
        filename = record['filename']
        if Path(filename).name != filename or not filename.endswith('.pdf'):
            raise ValueError('Invalid specification filename')
        path = Path(root)/'references/3gpp'/filename
        if path.is_file():
            verify_pdf(path.read_bytes(), record)
            found.append((record, path))
    return found


def localize_links(text, root, output_rel):
    for record, path in verified_documents(root):
        target = posixpath.relpath('references/3gpp/'+path.name, posixpath.dirname(output_rel) or '.')
        for url in (record['url'], record['archive_url']):
            text = text.replace(url, target)
    return text


def copy_documents(root, destination):
    copied = set()
    for record, path in verified_documents(root):
        target = Path(destination)/'references/3gpp'/path.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
        verify_pdf(target.read_bytes(), record)
        copied.add(target)
    return copied


def protocol_archive(root):
    """Create a complete, reproducible ZIP of the verified core PDFs for local use."""
    documents = verified_documents(root)
    if not documents or len(documents) != len(records(root)):
        raise ValueError('Core PDFs are incomplete. Run python references/3gpp/download.py.')
    target = Path(root)/PROTOCOL_ZIP
    with tempfile.NamedTemporaryFile(dir=target.parent, suffix='.download', delete=False) as output:
        temporary = Path(output.name)
    try:
        with zipfile.ZipFile(temporary, 'w', zipfile.ZIP_DEFLATED) as archive:
            for record, path in sorted(documents, key=lambda item: item[1].name):
                data = path.read_bytes()
                verify_pdf(data, record)
                entry = zipfile.ZipInfo(path.name, date_time=(1980, 1, 1, 0, 0, 0))
                entry.compress_type = zipfile.ZIP_DEFLATED
                entry.external_attr = 0o100644 << 16
                archive.writestr(entry, data)
        # Avoid changing the file on every build and triggering unnecessary refreshes.
        if not target.is_file() or target.read_bytes() != temporary.read_bytes():
            os.replace(temporary, target)
        return target
    finally:
        temporary.unlink(missing_ok=True)


def copy_protocol_archive(root, destination):
    source = protocol_archive(root)
    target = Path(destination)/PROTOCOL_ZIP
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    if target.read_bytes() != source.read_bytes():
        raise ValueError('Protocol archive changed while copying')
    return target


def reading_archive(root, site, destination):
    """ZIP readers follow official PDFs; the local website can keep local PDF links."""
    site = Path(site)
    license_bytes = (Path(root) / 'LICENSE').read_bytes()
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
        archive.writestr('LICENSE', license_bytes)
        for path in sorted(site.rglob('*')):
            if not path.is_file() or path.suffix.lower() in {'.pdf', '.zip'}:
                continue
            relative = path.relative_to(site).as_posix()
            if relative == 'LICENSE':
                continue
            data = path.read_bytes()
            if path.suffix == '.html':
                text = data.decode('utf-8')
                for record in records(root):
                    target = posixpath.relpath('references/3gpp/'+record['filename'], posixpath.dirname(relative) or '.')
                    text = text.replace('"./'+target, '"'+record['url'])
                    text = text.replace(target, record['url'])
                target = posixpath.relpath(PROTOCOL_ZIP, posixpath.dirname(relative) or '.')
                text = text.replace('"./'+target, '"'+OFFICIAL_INDEX)
                text = text.replace(target, OFFICIAL_INDEX)
                text = text.replace('3GPP protocols (ZIP)', '3GPP official specifications')
                text = text.replace(' download=""', '').replace(' download="3GPP-Rel-18-Core-Specifications.zip"', '')
                data = text.encode('utf-8')
            archive.writestr(relative, data)
