"""Generate the nine notebooks from the same Markdown cells used by the website."""
from pathlib import Path
import sys
import nbformat

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'jupyter/runtime'))
from course_runtime import parse_cells


def main():
    out=ROOT/'jupyter/notebooks'
    out.mkdir(exist_ok=True)
    for source in sorted((ROOT/'jupyter/cells').glob('*Execution Cells.md')):
        name=source.name[:6]
        nb=nbformat.v4.new_notebook()
        nb.metadata.kernelspec=dict(name='jupyter_matlab_kernel',display_name='MATLAB Kernel',language='matlab')
        nb.metadata.language_info=dict(name='matlab',file_extension='.m')
        nb.cells=[nbformat.v4.new_markdown_cell(f'# {name} — MATLAB engineering experiment\n\nRead the corresponding note in `notes/05 Knowledge Syntheses`. Run cells in order. MATLAB and the required toolboxes must be installed and licensed locally.', id=name.lower()+'-intro')]
        for cell in parse_cells(source.read_text(),name.lower().replace('-','')):
            nb.cells.append(nbformat.v4.new_markdown_cell('## '+cell['title']+'\n\n'+cell['description'], id=cell['id']+'-heading'))
            nb.cells.append(nbformat.v4.new_code_cell(cell['code'],id=cell['id']))
        nbformat.validate(nb)
        nbformat.write(nb,out/(name+'.ipynb'))
        print(name,len([c for c in nb.cells if c.cell_type=='code']),'cells')


if __name__=='__main__':
    main()
