"""Authenticated local routes for the existing site and nine Uni experiments."""
import hashlib
import json
from pathlib import Path
import re
import nbformat
from tornado import web
from jupyter_server.base.handlers import AuthenticatedFileHandler, JupyterHandler
from jupyter_server.auth.decorator import authorized

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[1]
SITE = PROJECT / 'site/student-site'
CELL_SOURCE = PROJECT / 'jupyter/cells/Uni-01 Execution Cells.md'
UNI_PAGE = 'uni/uni-01-cell-search-synchronization-and-mib-recovery.html'


def chapters():
    """Use the exporter mapping; never accept arbitrary source paths from a URL."""
    result = {}
    for row in json.loads((SITE / 'manifests/note-sources.json').read_text()):
        match = re.fullmatch(r'uni/uni-(0[1-9])-[\w-]+\.html', row['html'])
        if match:
            number = match[1]
            lab, name = 'uni' + number, 'Uni-' + number
            result[lab] = dict(lab=lab, name=name, page=row['html'],
                source=f'jupyter/cells/{name} Execution Cells.md',
                variable='u' + number, note='notes/' + row['source'])
    if len(result) != 9:
        raise ValueError('Expected nine Uni pages in the source manifest; rebuild the course.')
    return result


def chapter(lab='uni01'):
    if lab not in {f'uni{i:02d}' for i in range(1, 10)}:
        raise ValueError('Unknown Uni experiment')
    return chapters()[lab]


def parse_cells(text, lab='uni01'):
    cells = []
    for section in re.split(r'^## ', text, flags=re.M)[1:]:
        header, body = section.split('\n', 1)
        cell_id, title = header.split(': ', 1)
        anchor = re.search(r'<!-- anchor: ([\w-]+) -->', body).group(1)
        before, code, after = re.split(r'```matlab\n(.*?)\n```', body, maxsplit=1, flags=re.S)
        description = re.sub(r'<!--.*?-->', '', before, flags=re.S).strip()
        cells.append(dict(id=cell_id,title=title,anchor=anchor,description=description,code=code))
    if not cells or len({c['id'] for c in cells}) != len(cells):
        raise ValueError(f'{lab}: empty or duplicate execution cells')
    return cells


def cell_snapshot(lab='uni01'):
    data = (PROJECT / chapter(lab)['source']).read_bytes()
    return parse_cells(data.decode('utf-8'), lab), hashlib.sha256(data).hexdigest()


def load_cells(lab='uni01'):
    return cell_snapshot(lab)[0]


def make_notebook(cells, lab='uni01'):
    c = chapter(lab)
    nb = nbformat.v4.new_notebook()
    nb.metadata.kernelspec = dict(name='jupyter_matlab_kernel',display_name='MATLAB Kernel',language='matlab')
    nb.metadata.language_info = dict(name='matlab',file_extension='.m')
    nb.metadata.uni = dict(lab=lab, source=c['source'], note=c['note'])
    nb.cells.append(nbformat.v4.new_markdown_cell(f"# {c['name']} — Local MATLAB experiment\n\nRun inside the course directory with its MATLAB functions. These cells accompany {c['note']}. Run one experiment at a time on this local MATLAB server."))
    for cell in cells:
        nb.cells.append(nbformat.v4.new_markdown_cell('## '+cell['title']+'\n\n'+cell['description']))
        nb.cells.append(nbformat.v4.new_code_cell(cell['code'],id=cell['id']))
    return nb


def decorate_html(html, lab='uni01'):
    chapter(lab)
    return html.replace('</head>', f'<meta name="uni-lab" content="{lab}"><link rel="stylesheet" href="/course-runtime/runtime.css"></head>').replace(
        '</body>', f'<script data-uni-lab="{lab}" src="/course-runtime/runtime.js"></script></body>')


class CourseFiles(AuthenticatedFileHandler):
    # The generated course is trusted application HTML and needs same-origin API
    # access. Other Jupyter /files documents retain their normal sandbox policy.
    @property
    def content_security_policy(self):
        return JupyterHandler.content_security_policy.fget(self)

    @web.authenticated
    @authorized
    async def get(self, path, **kwargs):
        self.xsrf_token
        lab = next((k for k, c in chapters().items() if path == c['page']), None)
        if lab:
            self.set_header('Content-Type','text/html; charset=utf-8')
            self.set_header('Cache-Control','no-store')
            self.finish(decorate_html((SITE / path).read_text(), lab))
        else:
            await super().get(path or 'index.html', **kwargs)


class CellsHandler(JupyterHandler):
    @web.authenticated
    def get(self):
        self.xsrf_token
        self.set_header('Cache-Control','no-store')
        lab = self.get_query_argument('lab', 'uni01')
        try:
            c = chapter(lab)
        except ValueError as exc:
            raise web.HTTPError(404, str(exc)) from exc
        cells, source_hash = cell_snapshot(lab)
        self.finish({**c, 'cells': cells, 'kernel':'jupyter_matlab_kernel',
                     'source_sha256': source_hash,
                     'notebook': make_notebook(cells, lab)})


class NotebookHandler(JupyterHandler):
    @web.authenticated
    def get(self):
        lab = self.get_query_argument('lab', 'uni01')
        try:
            c = chapter(lab)
        except ValueError as exc:
            raise web.HTTPError(404, str(exc)) from exc
        self.set_header('Content-Type','application/x-ipynb+json')
        self.set_header('Content-Disposition',f'attachment; filename="{c["name"]}.ipynb"')
        self.finish(nbformat.writes(make_notebook(load_cells(lab), lab)))


def _jupyter_server_extension_points():
    return [{'module':'course_runtime'}]


def _load_jupyter_server_extension(serverapp):
    serverapp.web_app.add_handlers('.*$', [
        (r'/course/(.*)',CourseFiles,{'path':str(SITE)}),
        (r'/course-runtime/cells',CellsHandler),
        (r'/course-runtime/notebook',NotebookHandler),
        (r'/course-runtime/(runtime\.(?:js|css))',AuthenticatedFileHandler,{'path':str(HERE)}),
    ])
