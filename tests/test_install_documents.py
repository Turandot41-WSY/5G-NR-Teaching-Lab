"""Regression checks for Conda setup and direct specification access."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import os
import zipfile

ROOT = Path(__file__).resolve().parents[1]


class InstallDocumentTests(unittest.TestCase):
    def load(self, relative):
        path = ROOT / relative
        self.assertTrue(path.is_file(), relative)
        spec = importlib.util.spec_from_file_location(path.stem, path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module

    def test_conda_environment_is_pinned(self):
        path = ROOT / 'environment.yml'
        self.assertTrue(path.is_file())
        import yaml
        data = yaml.safe_load(path.read_text())
        self.assertIn('nodefaults', data['channels'])
        self.assertIn('python=3.12', data['dependencies'])
        self.assertTrue(any(x.startswith('quarto=') for x in data['dependencies']))

    def test_installer_checks_actual_render(self):
        installer = (ROOT/'setup/install.py').read_text()
        self.assertIn("ROOT/'setup/check_environment.py'", installer)
        self.assertTrue((ROOT/'setup/check_environment.py').is_file())

    def test_ready_conda_environment_takes_precedence(self):
        module = self.load('setup/runtime_environment.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            legacy = root / '.venv/bin/python'
            modern = root / '.conda/bin/python'
            for p in (legacy, modern):
                p.parent.mkdir(parents=True)
                p.touch()
            self.assertEqual(module.python_executable(root, windows=False), legacy)
            (root / 'local-config.json').write_text(json.dumps({'environment': '.conda'}))
            self.assertEqual(module.python_executable(root, windows=False), modern)

    def test_pdf_download_rejects_wrong_bytes(self):
        module = self.load('references/3gpp/specifications.py')
        data = b'%PDF-1.7\nexample'
        record = {'filename': 'TS-38.211-v18.9.0.pdf', 'sha256': hashlib.sha256(data).hexdigest()}
        module.verify_pdf(data, record)
        with self.assertRaises(ValueError):
            module.verify_pdf(data + b'changed', record)
        with self.assertRaises(ValueError):
            module.verify_pdf(b'<html>Error</html>', record)

    def test_environment_path_preserves_venv_symlink(self):
        module = self.load('setup/runtime_environment.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            python = root/'.venv/bin/python'
            python.parent.mkdir(parents=True)
            python.symlink_to('/usr/bin/python3')
            original = dict(os.environ)
            try:
                module.prepare_environment(python)
                self.assertEqual(os.environ['PATH'].split(os.pathsep)[0], str(python.parent))
            finally:
                os.environ.clear()
                os.environ.update(original)

    def test_reading_zip_uses_official_url_and_omits_pdf(self):
        module = self.load('references/3gpp/specifications.py')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'LICENSE').write_text('Course license')
            (root/'references/3gpp').mkdir(parents=True)
            record = {'filename':'example.pdf','url':'https://www.etsi.org/example.pdf'}
            (root/'references/3gpp/specifications.json').write_text(json.dumps([record]))
            site = root/'site'
            (site/'protocol').mkdir(parents=True)
            (site/'references/3gpp').mkdir(parents=True)
            (site/'references/3gpp/example.pdf').write_bytes(b'%PDF-example')
            (site/'protocol/star.html').write_text('<a href="../references/3gpp/example.pdf#page=4">PDF</a>')
            module.reading_archive(root, site, root/'reading.zip')
            with zipfile.ZipFile(root/'reading.zip') as archive:
                self.assertEqual(archive.namelist(), ['LICENSE', 'protocol/star.html'])
                self.assertIn(record['url']+'#page=4', archive.read('protocol/star.html').decode())

    def test_conda_quarto_tools_resolve_inside_environment(self):
        module = self.load('setup/runtime_environment.py')
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory)/'.conda'
            (prefix/'conda-meta').mkdir(parents=True)
            for name in ('bin/python','bin/deno','bin/pandoc','bin/esbuild','bin/typst','bin/sass','lib/deno_dom.dylib'):
                p = prefix/name
                p.parent.mkdir(parents=True, exist_ok=True)
                p.touch()
                p.chmod(0o755)
            (prefix/'share/quarto').mkdir(parents=True)
            original = dict(os.environ)
            try:
                os.environ.pop('QUARTO_DENO', None)
                os.environ['QUARTO_DENO_DOM'] = '/missing/build/machine/library'
                module.prepare_environment(prefix/'bin/python')
                self.assertEqual(os.environ.get('QUARTO_DENO'), str(prefix/'bin/deno'))
                self.assertEqual(os.environ['QUARTO_DENO_DOM'], str(prefix/'lib/deno_dom.dylib'))
            finally:
                os.environ.clear()
                os.environ.update(original)

    def test_document_link_uses_local_file_only_after_verification(self):
        module = self.load('references/3gpp/specifications.py')
        data = b'%PDF-1.7\nexample'
        record = {'filename': 'TS-38.211-v18.9.0.pdf', 'sha256': hashlib.sha256(data).hexdigest(),
                  'url': 'https://www.etsi.org/deliver/test.pdf', 'archive_url': 'https://www.3gpp.org/ftp/test.zip'}
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'references/3gpp').mkdir(parents=True)
            (root/'references/3gpp/specifications.json').write_text(json.dumps([record]))
            text = '[Open PDF](' + record['url'] + '#page=12)'
            self.assertEqual(module.localize_links(text, root, 'protocol/star.qmd'), text)
            (root/'references/3gpp'/record['filename']).write_bytes(data)
            self.assertEqual(module.localize_links(text, root, 'protocol/star.qmd'),
                             '[Open PDF](../references/3gpp/TS-38.211-v18.9.0.pdf#page=12)')

    def test_ten_protocol_notes_open_pdf_without_manifest_hop(self):
        path = ROOT / 'references/3gpp/specifications.json'
        self.assertTrue(path.is_file())
        records = json.loads(path.read_text())
        self.assertEqual(len(records), 10)
        for record in records:
            note = next((ROOT/'notes/05 Knowledge Syntheses').glob(f'Star-{record["star"]}-*.md'))
            self.assertIn(f'[Open the specification PDF]({record["url"]})', note.read_text())


if __name__ == '__main__':
    unittest.main()
