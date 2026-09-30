"""Temporary page mapping derived from the real notes and exporter."""
from contextlib import contextmanager
import importlib.util
import json
from pathlib import Path
import tempfile

ROOT = Path(__file__).resolve().parents[1]


@contextmanager
def course_site():
    spec = importlib.util.spec_from_file_location('test_builder', ROOT / 'site/build_student_export.py')
    builder = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(builder)
    with tempfile.TemporaryDirectory() as folder:
        site = Path(folder)
        (site / 'manifests').mkdir()
        rows = [dict(source=str(path.relative_to(ROOT / 'notes')),
                     html=builder.output_for(path).replace('.qmd', '.html'))
                for path in builder.uni_notes()]
        (site / 'manifests/note-sources.json').write_text(json.dumps(rows))
        yield site
