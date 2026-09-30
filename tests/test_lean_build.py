"""Local builds reuse source assets and export a portable ZIP only on request."""
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch
import urllib.request
import zipfile

from test_reference_startup import ROOT, load


class LeanBuildTests(unittest.TestCase):
    def assets_module(self):
        self.assertTrue((ROOT/'site/local_assets.py').is_file(), 'Local resource reuse is missing')
        return load('site/local_assets')

    def fixture(self, directory):
        root = Path(directory)
        site = root/'site/student-site'
        image = root/'notes/99 Attachments/5G/Test/image.png'
        image.parent.mkdir(parents=True)
        image.write_bytes(b'original image bytes')
        target = site/'images/Test/image.png'
        target.parent.mkdir(parents=True)
        shutil.copy2(image, target)
        (site/'index.html').write_text('<img src="images/Test/image.png">')
        return root, site, image, target

    def test_compact_removes_only_verified_copy_and_resolves_original(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            module.compact_assets(root, site, {'images/Test/image.png': original})
            self.assertFalse(copy.exists())
            self.assertEqual(module.resolve_asset(root, site, 'images/Test/image.png'), original.resolve())
            self.assertEqual(original.read_bytes(), b'original image bytes')
            manifest = (site/'manifests/local-assets.json').read_text()
            self.assertNotIn(str(root), manifest)

    def test_compact_rejects_changed_copy_without_removing_it(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            copy.write_bytes(b'wrong version')
            with self.assertRaises(ValueError):
                module.compact_assets(root, site, {'images/Test/image.png': original})
            self.assertTrue(copy.exists())

    def test_resolver_denies_unlisted_paths_and_traversal(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            module.compact_assets(root, site, {'images/Test/image.png': original})
            for path in ('images/unknown.png', '../local-config.json', '/images/Test/image.png',
                         'images/../Test/image.png', 'images\\Test\\image.png'):
                self.assertIsNone(module.resolve_asset(root, site, path), path)

    def test_tampered_mapping_cannot_expose_private_file(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            module.compact_assets(root, site, {'images/Test/image.png': original})
            manifest = site/'manifests/local-assets.json'
            data = json.loads(manifest.read_text())
            data['assets']['images/Test/image.png']['source'] = 'local-config.json'
            manifest.write_text(json.dumps(data))
            (root/'local-config.json').write_text('private')
            self.assertIsNone(module.resolve_asset(root, site, 'images/Test/image.png'))

    def test_protocol_assets_reuse_original_bytes(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            for name in ('TS-38.211.pdf', '3GPP-Rel-18-Core-Specifications.zip'):
                relative = 'references/3gpp/'+name
                source = root/relative
                source.parent.mkdir(parents=True, exist_ok=True)
                source.write_bytes(b'verified protocol bytes')
                target = site/relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target)
                module.compact_assets(root, site, {relative: source})
                self.assertFalse(target.exists())
                self.assertEqual(module.resolve_asset(root, site, relative).read_bytes(), source.read_bytes())

    def test_resource_code_changes_invalidate_build(self):
        publisher = load('publish_site')
        for path in ('site/local_assets.py', 'jupyter/runtime/course_runtime.py'):
            self.assertIn(ROOT/path, publisher.WATCHED)

    def test_resolver_rejects_symlink_escape_and_missing_original(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            module.compact_assets(root, site, {'images/Test/image.png': original})
            original.unlink()
            self.assertIsNone(module.resolve_asset(root, site, 'images/Test/image.png'))
            secret = root/'local-config.json'
            secret.write_text('private')
            original.symlink_to(secret)
            self.assertIsNone(module.resolve_asset(root, site, 'images/Test/image.png'))

    def test_portable_export_contains_original_image_without_map_or_protocols(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            (root/'LICENSE').write_text('test license')
            (root/'references/3gpp').mkdir(parents=True)
            (root/'references/3gpp/specifications.json').write_text('[]')
            module.compact_assets(root, site, {'images/Test/image.png': original})
            target = root/'reading.zip'
            module.reading_export(root, site, target)
            with zipfile.ZipFile(target) as archive:
                self.assertEqual(archive.read('images/Test/image.png'), original.read_bytes())
                self.assertEqual(archive.read('LICENSE'), b'test license')
                self.assertNotIn('manifests/local-assets.json', archive.namelist())
            self.assertFalse(copy.exists())

    def test_export_rejects_source_changed_after_build(self):
        module = self.assets_module()
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            module.compact_assets(root, site, {'images/Test/image.png': original})
            original.write_bytes(b'new version')
            with self.assertRaises(ValueError):
                module.reading_export(root, site, root/'reading.zip')

    def test_promotion_drops_owned_intermediates_but_preserves_unrelated_files(self):
        builder = load('site/build_student_export')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            stage, output = root/'stage', root/'output'
            for base in (stage, output):
                (base/'student-site').mkdir(parents=True)
                (base/'student-source').mkdir()
            (stage/'student-site/index.html').write_text('new')
            (output/'student-site/index.html').write_text('old')
            (output/'Saar-5G-NR-Teaching-Knowledge-Base.zip').write_bytes(b'old generated archive')
            (output/'keep.txt').write_text('user file')
            builder.promote_build(stage, output)
            self.assertFalse((output/'student-source').exists())
            self.assertFalse((output/'Saar-5G-NR-Teaching-Knowledge-Base.zip').exists())
            self.assertEqual((output/'student-site/index.html').read_text(), 'new')
            self.assertEqual((output/'keep.txt').read_text(), 'user file')

    def test_failed_promotion_restores_previous_outputs(self):
        builder = load('site/build_student_export')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            stage, output = root/'stage', root/'output'
            for base in (stage, output):
                (base/'student-site').mkdir(parents=True)
                (base/'student-source').mkdir()
            (output/'student-site/index.html').write_text('old')
            (stage/'student-site/index.html').write_text('new')
            rename = Path.rename
            def failing(path, target):
                if path == stage/'student-site':
                    raise OSError('test promotion failure')
                return rename(path, target)
            with patch.object(Path, 'rename', failing), self.assertRaises(OSError):
                builder.promote_build(stage, output)
            self.assertEqual((output/'student-site/index.html').read_text(), 'old')
            self.assertTrue((output/'student-source').is_dir())

    def test_archive_install_failure_restores_every_old_output(self):
        builder = load('site/build_student_export')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            stage, output = root/'stage', root/'output'
            archive = 'Saar-5G-NR-Teaching-Knowledge-Base.zip'
            for base in (stage, output):
                (base/'student-site').mkdir(parents=True)
                (base/'student-source').mkdir()
            (stage/'student-site/index.html').write_text('new')
            (output/'student-site/index.html').write_text('old')
            (output/'student-source/keep.qmd').write_text('old source')
            (stage/archive).write_bytes(b'new archive')
            (output/archive).write_bytes(b'old archive')
            rename = Path.rename
            def failing(path, target):
                if path == stage/archive:
                    raise OSError('test archive installation failure')
                return rename(path, target)
            with patch.object(Path, 'rename', failing), self.assertRaises(OSError):
                builder.promote_build(stage, output)
            self.assertEqual((output/'student-site/index.html').read_text(), 'old')
            self.assertEqual((output/'student-source/keep.qmd').read_text(), 'old source')
            self.assertEqual((output/archive).read_bytes(), b'old archive')
            self.assertEqual((stage/'student-site/index.html').read_text(), 'new')

    def test_plain_build_does_not_create_reading_archive(self):
        builder = load('site/build_student_export')
        with tempfile.TemporaryDirectory() as directory:
            def render():
                builder.SOURCE.mkdir()
                builder.SITE.mkdir()
                (builder.SITE/'index.html').write_text('rendered')
            with patch.object(builder, 'EXPORT', Path(directory)), \
                 patch.object(builder, 'build_staged', side_effect=render), \
                 patch.object(sys, 'argv', ['build_student_export.py']):
                builder.main()
            self.assertTrue((Path(directory)/'student-site/index.html').is_file())
            self.assertFalse((Path(directory)/'student-source').exists())
            self.assertEqual(list(Path(directory).glob('*.zip')), [])

    def test_reading_server_serves_mapped_image_and_rejects_private_file(self):
        module = self.assets_module()
        publisher = load('publish_site')
        with tempfile.TemporaryDirectory() as directory:
            root, site, original, copy = self.fixture(directory)
            module.compact_assets(root, site, {'images/Test/image.png': original})
            (root/'local-config.json').write_text('private')
            with patch.object(publisher, 'ROOT', root), patch.object(publisher, 'SITE', site):
                server = publisher.serve(0)
                server.ready = True
                url = f'http://127.0.0.1:{server.server_port}'
                try:
                    with urllib.request.urlopen(url+'/images/Test/image.png') as response:
                        self.assertEqual(response.read(), original.read_bytes())
                        self.assertEqual(response.headers.get_content_type(), 'image/png')
                    with self.assertRaises(urllib.error.HTTPError) as error:
                        urllib.request.urlopen(url+'/images/../../local-config.json')
                    self.assertEqual(error.exception.code, 404)
                finally:
                    server.shutdown()
                    server.server_close()


if __name__ == '__main__':
    unittest.main()
