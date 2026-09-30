"""Resolve the course environment for both launchers, without shell activation."""
import os
import shutil
import subprocess
from pathlib import Path


def prepare_references(root, python):
    """Prepare the same verified PDF archive for reading and MATLAB launchers."""
    root = Path(root)
    print('Preparing the 3GPP PDF archive; existing verified files will be reused.', flush=True)
    subprocess.run([str(python), str(root/'references/3gpp/download.py')], cwd=root, check=True)


def python_executable(root, windows=None):
    from environment_selection import select_python
    return select_python(root, windows=windows)


def prepare_environment(python):
    python = Path(python).absolute()
    prefix = python.parent if os.name == 'nt' and python.parent.name != 'Scripts' else python.parent.parent
    bins = [prefix, prefix/'Scripts', prefix/'Library/bin', prefix/'Library/usr/bin'] if os.name == 'nt' else [prefix/'bin']
    os.environ['PATH'] = os.pathsep.join([*(str(p) for p in bins), os.environ.get('PATH', '')])
    os.environ['COURSE_PYTHON'] = str(python)
    os.environ['PYTHONNOUSERSITE'] = '1'
    os.environ.pop('PYTHONPATH', None)
    os.environ.pop('PYTHONHOME', None)
    if (prefix/'conda-meta').is_dir():
        os.environ['CONDA_PREFIX'] = str(prefix)
        # Conda packages install tools separately from the Quarto distribution.
        # Resolve their installed locations, including when no shell was activated.
        search = os.pathsep.join(map(str, bins))
        for key, tool in {'DENO':'deno','PANDOC':'pandoc','ESBUILD':'esbuild',
                          'TYPST':'typst','DART_SASS':'sass'}.items():
            executable = shutil.which(tool, path=search)
            if executable:
                os.environ['QUARTO_'+key] = executable
        for relative in ('lib/deno_dom.dylib','lib/deno_dom.so','Library/bin/deno_dom.dll'):
            if (prefix/relative).is_file():
                os.environ['QUARTO_DENO_DOM'] = str(prefix/relative)
                os.environ['DENO_DOM_PLUGIN'] = str(prefix/relative)
                break
        for relative in ('share/quarto','Library/share/quarto'):
            if (prefix/relative).is_dir():
                os.environ['QUARTO_SHARE_PATH'] = str(prefix/relative)
                break
        os.environ['QUARTO_CONDA_PREFIX'] = str(prefix)
