"""Checks for a portable course delivery. Run with python -m unittest discover -s tests."""
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import unittest
from unittest.mock import patch
from course_test_data import course_site

ROOT = Path(__file__).resolve().parents[1]


class DistributionTests(unittest.TestCase):
    def test_python_locator_has_no_recursive_fallback(self):
        code = (ROOT / 'matlab/course_python.m').read_text()
        self.assertNotRegex(code, r'python\s*=\s*course_python\s*;')
        self.assertIn("fullfile(root,folder,'bin','python')", code)

    def test_notebook_markdown_ids_are_stable(self):
        for path in (ROOT / 'jupyter/notebooks').glob('Uni-*.ipynb'):
            cells = json.loads(path.read_text())['cells']
            self.assertEqual(cells[0]['id'], path.stem.lower() + '-intro')
            for heading, code in zip(cells[1::2], cells[2::2]):
                self.assertEqual(heading['id'], code['id'] + '-heading')

    def test_modules_have_readmes(self):
        for name in ('notes', 'references/3gpp', 'jupyter', 'matlab', 'site', 'setup'):
            self.assertTrue((ROOT / name / 'README.md').is_file(), name)

    def test_nine_notebooks_have_clean_matlab_cells(self):
        notebooks = sorted((ROOT / 'jupyter/notebooks').glob('Uni-*.ipynb'))
        self.assertEqual(len(notebooks), 9)
        for path in notebooks:
            data = json.loads(path.read_text())
            self.assertEqual(data['metadata']['kernelspec']['name'], 'jupyter_matlab_kernel')
            cells = [c for c in data['cells'] if c['cell_type'] == 'code']
            self.assertIn(len(cells), (6, 7, 8))
            self.assertTrue(all(c['execution_count'] is None and not c['outputs'] for c in cells))
            text = path.read_text()
            self.assertNotIn('/Users/', text)
            self.assertNotIn('10 MATLAB Labs', text)

    def test_launcher_help_from_another_directory(self):
        p = subprocess.run([sys.executable, str(ROOT / 'start.py'), '--help'],
                           cwd=ROOT.parent, capture_output=True, text=True)
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertIn('--matlab', p.stdout)

    def test_all_note_images_resolve(self):
        folder = ROOT / 'notes'
        notes = list((folder / '05 Knowledge Syntheses').glob('*.md'))
        self.assertEqual(len(notes), 46)
        for path in notes:
            for target in re.findall(r'!\[\[([^\]|]+)', path.read_text()):
                self.assertTrue((folder / target).is_file(), (path.name, target))

    def test_runtime_uses_repository_paths(self):
        path = ROOT / 'jupyter/runtime/course_runtime.py'
        self.assertTrue(path.is_file())
        spec = importlib.util.spec_from_file_location('distribution_runtime', path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertEqual(module.PROJECT, ROOT)
        with course_site() as site, patch.object(module, 'SITE', site):
            for lab, row in module.chapters().items():
                self.assertTrue((ROOT / row['source']).is_file())
                self.assertGreaterEqual(len(module.load_cells(lab)), 6)


if __name__ == '__main__':
    unittest.main()
