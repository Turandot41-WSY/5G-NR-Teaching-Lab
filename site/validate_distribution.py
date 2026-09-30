"""Audit the distributable source files and generated site, without executing MATLAB."""
from pathlib import Path
import csv
import hashlib
import importlib.util
import json
import re
import sys
import yaml

ROOT=Path(__file__).resolve().parents[1]


def main():
    notes=ROOT/'notes'
    pages=sorted((notes/'05 Knowledge Syntheses').glob('*.md'))
    assert sum(p.name.startswith('Star-') for p in pages)==37
    assert sum(p.name.startswith('Uni-') for p in pages)==9
    figures={}
    for name in ('Visual Evidence Manifest.yml','Uni Visual Evidence Manifest.yml'):
        for row in yaml.safe_load((notes/'01 Source Collections'/name).read_text()):
            assert row['kind'] in {'generated_diagram','original_diagram','original_imagegen_schematic','matlab_result'}
            path=notes/row['local_file']
            assert path.is_file(),path
            assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256'],path
            figures[row['local_file']]=row
    stems={p.stem for p in notes.rglob('*.md')}
    allowed_aliases={'5G NR 2e Source Manifest','spec-manifest.yml','Protocol/Rel-18/spec-manifest.yml'}
    for page in pages:
        text=page.read_text()
        assert '/Users/' not in text and '/Volumes/' not in text,page
        assert '[[ENG-' not in text and '[[CHAPTER ' not in text,page
        for embed in re.findall(r'!\[\[([^\]|]+)',text):
            assert embed in figures,(page.name,embed)
        for link in re.findall(r'(?<!!)\[\[([^\]]+)\]\]',text):
            target=link.replace('\\|','|').split('|')[0].split('#')[0].strip()
            assert not target or target in stems or target in allowed_aliases or (notes/target).is_file(),(page.name,target)
    manifest=yaml.safe_load((ROOT/'references/3gpp/spec-manifest.yml').read_text())
    for spec in manifest['specifications']:
        assert spec['download_url'].startswith('https://www.3gpp.org/ftp/Specs/')
        assert re.fullmatch(r'[0-9a-f]{64}',spec['sha256'])
    for number in range(1,10):
        notebook=json.loads((ROOT/f'jupyter/notebooks/Uni-{number:02d}.ipynb').read_text())
        code=[c for c in notebook['cells'] if c['cell_type']=='code']
        assert len(code) in (6,7,8)
        assert all(c['execution_count'] is None and not c['outputs'] for c in code)
    # Selected teacher CSV evidence must remain complete.
    expected={'uni02/results/run-20260907-120305/trials.csv':1260,
              'uni03/results/run-20260907-122809/trials.csv':120,
              'uni05/results/run-20260907-120612/trials.csv':5040,
              'uni06/results/trials.csv':768,'uni07/results/trials.csv':720,
              'uni09/results/per_ue.csv':144}
    for path,count in expected.items():
        with (ROOT/'matlab'/path).open() as f:
            assert len(list(csv.DictReader(f)))==count,path
    site=ROOT/'site/student-site'
    if site.exists():
        sys.path.insert(0,str(ROOT/'site'))
        import build_student_export as builder
        mapping={notes/row['source']:row['qmd'] for row in json.loads((site/'manifests/note-sources.json').read_text())}
        assert len(mapping)==50
        builder.validate_rendered_site(mapping)
        for row in json.loads((site/'manifests/note-sources.json').read_text()):
            assert hashlib.sha256((notes/row['source']).read_bytes()).hexdigest()==row['sha256']
    print(f'PASS: 37 Star, 9 Uni, {len(figures)} original figure records, 9 clean notebooks, {len(manifest["specifications"])} specification references; retained trial counts verified.')


if __name__=='__main__':
    main()
