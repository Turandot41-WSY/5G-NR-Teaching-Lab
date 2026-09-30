"""Check the installed kernel and render a small page before setup succeeds."""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from jupyter_client.kernelspec import KernelSpecManager
from runtime_environment import prepare_environment


def main():
    prepare_environment(sys.executable)
    quarto = shutil.which('quarto')
    if not quarto:
        raise RuntimeError('Quarto is missing from the course environment')
    version = subprocess.check_output([quarto, '--version'], text=True).strip()
    if version != '1.8.27':
        raise RuntimeError(f'Expected Quarto 1.8.27, found {version}')
    if 'jupyter_matlab_kernel' not in KernelSpecManager().find_kernel_specs():
        raise RuntimeError('MATLAB kernel registration is missing')
    with tempfile.TemporaryDirectory(prefix='5g-install-check-') as directory:
        page = Path(directory)/'check.qmd'
        page.write_text('---\ntitle: Installation check\nformat: html\n---\n\nCourse environment ready.\n')
        subprocess.run([quarto, 'render', str(page), '--quiet'], cwd=directory, check=True)
        if not (Path(directory)/'check.html').is_file():
            raise RuntimeError('Quarto did not create the test page')
    print('Quarto 1.8.27 render and MATLAB kernel registration passed.')


if __name__ == '__main__':
    main()
