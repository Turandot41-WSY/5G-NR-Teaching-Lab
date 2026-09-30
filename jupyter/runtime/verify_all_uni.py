"""Execute chapter cells serially through the real local MATLAB kernel.

Writes fresh verification notebooks and a measured report. Never calls the
teacher batch runners. Pass a private connection.json; tokens are not recorded.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time

import nbformat

from course_runtime import HERE, PROJECT, SITE, chapter, cell_snapshot, make_notebook
from probe_kernel import MatlabSession

OUT = PROJECT / '.validation/runtime'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def protected_hashes():
    files = []
    for name in ('matlab', 'notes'):
        for p in (PROJECT / name).rglob('*'):
            if not p.is_file() or any(x in p.parts for x in ('.venv', 'jupyter', '__pycache__', '.pytest_cache')):
                continue
            if p.suffix in ('.m', '.py', '.mat', '.json', '.csv', '.png', '.md'):
                files.append(p)
    return {str(p.relative_to(PROJECT)): digest(p) for p in files}


def implementation_hashes(lab):
    dependencies = {'uni03': ('uni01', 'uni03'), 'uni08': ('uni01', 'uni03', 'uni04', 'uni08')}
    files = []
    for dep in dependencies.get(lab, (lab,)):
        for p in (PROJECT / 'matlab' / dep).rglob('*'):
            if p.is_file() and p.suffix in ('.m', '.py') and not any(x in p.parts for x in ('.venv', 'student-results', '__pycache__')):
                files.append(p)
    return {str(p.relative_to(PROJECT)): digest(p) for p in files}


def convert(messages):
    outputs, count, errors = [], None, []
    for m in messages:
        t, c = m['header']['msg_type'], m['content']
        if t in ('execute_input', 'execute_reply'):
            count = c.get('execution_count', count)
        if t == 'stream':
            outputs.append(nbformat.v4.new_output('stream', name=c['name'], text=c['text']))
            if c['name'] == 'stderr':
                errors.append(c['text'])
        elif t == 'error':
            outputs.append(nbformat.v4.new_output('error', ename=c['ename'], evalue=c['evalue'], traceback=c.get('traceback', [])))
            errors.append(c['evalue'])
        elif t in ('display_data', 'execute_result'):
            extra = dict(execution_count=c['execution_count']) if t == 'execute_result' else {}
            outputs.append(nbformat.v4.new_output(t, data=c['data'], metadata=c.get('metadata', {}), **extra))
        elif t == 'execute_reply' and c.get('status') == 'error':
            errors.append(c.get('evalue', 'Execution failed'))
    return outputs, count, errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('state', type=Path)
    parser.add_argument('--labs', nargs='+', default=[f'uni{i:02d}' for i in range(1,10)])
    args = parser.parse_args()
    OUT.mkdir(parents=True,exist_ok=True)
    report_path = OUT / 'execution.json'
    report = json.loads(report_path.read_text()) if report_path.exists() else {'chapters': {}}
    report['checked_at'] = datetime.now(timezone.utc).isoformat()
    before = protected_hashes()
    session = MatlabSession(json.loads(args.state.read_text()))
    try:
        for lab in args.labs:
            info = chapter(lab)
            cells, source_hash = cell_snapshot(lab)
            html = (SITE / info['page']).read_text()
            assert all(f'id="{c["anchor"]}"' in html for c in cells), lab + ': missing anchor'
            nb = make_notebook(cells, lab)
            nb.metadata.uni.source_sha256 = source_hash
            nb.metadata.uni.implementation_sha256 = implementation_hashes(lab)
            code_cells = [c for c in nb.cells if c.cell_type == 'code']
            record = {'cells': [], 'passed': False, 'source_sha256': source_hash,
                      'implementation_sha256': dict(nb.metadata.uni.implementation_sha256)}
            report['chapters'][lab] = record
            for source, target in zip(cells, code_cells):
                started = time.monotonic()
                messages = session.execute(source['code'], timeout=900)
                outputs, count, errors = convert(messages)
                target.outputs, target.execution_count = outputs, count
                target.metadata.uni = dict(lab=lab, stale=bool(errors), executed_source=source['code'])
                images = sum('image/png' in o.get('data', {}) for o in outputs)
                text = ''.join(o.get('text', '') for o in outputs)
                record['cells'].append(dict(id=source['id'], seconds=round(time.monotonic()-started, 2), images=images,
                                             execution_count=count, stdout=text, errors=errors))
                print(lab, source['id'], 'FAIL' if errors else 'PASS', images, 'PNG', flush=True)
                nbformat.write(nb, OUT / (info['name'] + '-executed.ipynb'))
                report_path.write_text(json.dumps(report, indent=2))
                if errors:
                    print('\n'.join(errors), flush=True)
                    raise RuntimeError(lab + '/' + source['id'] + ' failed')
            assert record['implementation_sha256'] == implementation_hashes(lab), lab + ': implementation changed during execution'
            record['passed'] = True
            record['images'] = sum(c['images'] for c in record['cells'])
            record['notebook_sha256'] = digest(OUT / (info['name'] + '-executed.ipynb'))
            nbformat.validate(nb)
            session.execute('clear ' + info['variable'] + '; close all;')
            report_path.write_text(json.dumps(report, indent=2))
    finally:
        session.close()
        after = protected_hashes()
        report['protected_count'] = len(before)
        report['protected_changes'] = [p for p, h in before.items() if after.get(p) != h]
        report_path.write_text(json.dumps(report, indent=2))
        assert not report['protected_changes'], report['protected_changes']


if __name__ == '__main__':
    main()
