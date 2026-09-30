"""Readers receive protocol bytes, and a pull invalidates the old rendered site."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def load(relative):
    spec = importlib.util.spec_from_file_location(Path(relative).stem, ROOT / relative)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ProtocolArchiveTests(unittest.TestCase):
    def test_license_changes_invalidate_the_build(self):
        publisher = load('publish_site.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            license_path = root/'LICENSE'
            license_path.write_text('Version one')
            with patch.multiple(publisher, ROOT=root, WATCHED=[license_path]):
                before = publisher.build_fingerprint()
                license_path.write_text('Version two with a clarification')
                self.assertNotEqual(before, publisher.build_fingerprint())

    def test_reading_zip_carries_the_license(self):
        module = load('references/3gpp/specifications.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            site = root/'site'
            site.mkdir()
            (root/'LICENSE').write_text('Course license')
            (site/'index.html').write_text('Course')
            with patch.object(module, 'records', return_value=[]):
                module.reading_archive(root, site, root/'reading.zip')
            with zipfile.ZipFile(root/'reading.zip') as archive:
                self.assertIn('LICENSE', archive.namelist())
                self.assertEqual(archive.read('LICENSE'), b'Course license')

    def test_one_reference_owner(self):
        self.assertTrue((ROOT/'references/3gpp/specifications.py').is_file())
        self.assertFalse((ROOT/'documents/specifications.py').exists())
        self.assertTrue((ROOT/'site/validate_distribution.py').is_file())

    def test_sidebar_downloads_archive(self):
        builder = load('site/build_student_export.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            folder = root/'references/3gpp'
            folder.mkdir(parents=True)
            content = b'%PDF-test'
            (folder/'test.pdf').write_bytes(content)
            (folder/'specifications.json').write_text(json.dumps([
                {'filename':'test.pdf', 'sha256': hashlib.sha256(content).hexdigest()}]))
            with patch.multiple(builder, SOURCE=root, REPOSITORY=root):
                builder.write_project([], {p.stem: builder.output_for(p) for p in builder.uni_notes()})
                data = (root/'_quarto.yml').read_text()
        self.assertIn('3GPP protocols (ZIP)', data)
        self.assertIn('references/3gpp/3GPP-Rel-18-Core-Specifications.zip', data)
        self.assertNotIn('href: manifests/spec-manifest.yml', data)
        self.assertNotIn('Source Manifests', data)

    def test_distributable_reading_zip_omits_local_protocol_bundle(self):
        module = load('references/3gpp/specifications.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'references/3gpp').mkdir(parents=True)
            (root/'references/3gpp/specifications.json').write_text('[]')
            (root/'LICENSE').write_text('Course license')
            site = root/'site'
            (site/'references/3gpp').mkdir(parents=True)
            (site/module.PROTOCOL_ZIP).write_bytes(b'local protocol archive')
            (site/'index.html').write_text(f'<a href="./{module.PROTOCOL_ZIP}">3GPP protocols (ZIP)</a>')
            module.reading_archive(root, site, root/'reading.zip')
            with zipfile.ZipFile(root/'reading.zip') as archive:
                self.assertEqual(archive.namelist(), ['LICENSE', 'index.html'])
                self.assertIn(f'href="{module.OFFICIAL_INDEX}"', archive.read('index.html').decode())
                self.assertNotIn('(ZIP)', archive.read('index.html').decode())

    def test_archive_contains_verified_pdfs_and_rejects_partial_set(self):
        path = ROOT/'references/3gpp/specifications.py'
        self.assertTrue(path.is_file(), 'protocol handling belongs in references/3gpp')
        module = load(path.relative_to(ROOT))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            folder = root/'references/3gpp'
            folder.mkdir(parents=True)
            records = []
            for number in range(2):
                data = b'%PDF-1.7\n' + str(number).encode()
                record = {'filename':f'TS-{number}.pdf', 'sha256':hashlib.sha256(data).hexdigest()}
                records.append(record)
                (folder/record['filename']).write_bytes(data)
            (folder/'specifications.json').write_text(json.dumps(records))
            archive = module.protocol_archive(root)
            with zipfile.ZipFile(archive) as package:
                self.assertEqual(sorted(package.namelist()), ['TS-0.pdf', 'TS-1.pdf'])
                for record in records:
                    self.assertEqual(hashlib.sha256(package.read(record['filename'])).hexdigest(), record['sha256'])
            first = archive.read_bytes()
            self.assertEqual(module.protocol_archive(root).read_bytes(), first)
            (folder/'TS-1.pdf').unlink()
            with self.assertRaises(ValueError):
                module.protocol_archive(root)

    def test_start_rebuilds_after_source_changes(self):
        publisher = load('publish_site.py')
        self.assertTrue(hasattr(publisher, 'needs_rebuild'), 'launcher must detect stale HTML after git pull')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root/'note.md'
            source.write_text('version one')
            site = root/'site/student-site'
            site.mkdir(parents=True)
            (site/'index.html').write_text('old rendering')
            with patch.multiple(publisher, ROOT=root, SITE=site, WATCHED=[source]):
                self.assertTrue(publisher.needs_rebuild())
                publisher.save_build_state()
                self.assertFalse(publisher.needs_rebuild())
                source.write_text('version two, after pull')
                self.assertTrue(publisher.needs_rebuild())
        self.assertIn('needs_rebuild()', (ROOT/'start.py').read_text())

    def test_readme_explains_reading_controls(self):
        text = (ROOT/'README.md').read_text()
        for term in ('## How to use the site', 'Abbreviation lookup', 'Parallel reading', 'Swap',
                     'Figures', 'Reading tools', 'Colour tells you the source'):
            self.assertIn(term, text)

    def test_legacy_downloads_move_only_after_hash_verification(self):
        module = load('references/3gpp/specifications.py')
        self.assertTrue(hasattr(module, 'migrate_legacy_downloads'))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            folder = root/'references/3gpp'
            folder.mkdir(parents=True)
            old = root/'documents/3gpp'
            old.mkdir(parents=True)
            data = b'%PDF-original'
            (old/'example.pdf').write_bytes(data)
            (old/'personal.txt').write_text('preserve this')
            (folder/'specifications.json').write_text(json.dumps([
                {'filename':'example.pdf', 'sha256': hashlib.sha256(data).hexdigest()}]))
            module.migrate_legacy_downloads(root)
            self.assertEqual((folder/'example.pdf').read_bytes(), data)
            self.assertFalse((old/'example.pdf').exists())
            self.assertEqual((old/'personal.txt').read_text(), 'preserve this')


if __name__ == '__main__':
    unittest.main()
