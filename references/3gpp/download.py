"""Download the ten frozen official PDFs for personal local reading."""
from pathlib import Path
import os
import sys
import tempfile
from urllib.request import Request, urlopen
from specifications import records, verify_pdf, protocol_archive, migrate_legacy_downloads

ROOT = Path(__file__).resolve().parents[2]


def main():
    folder = ROOT/'references/3gpp'
    folder.mkdir(parents=True, exist_ok=True)
    migrate_legacy_downloads(ROOT)
    for record in records(ROOT):
        path = folder/record['filename']
        if path.exists():
            verify_pdf(path.read_bytes(), record)
            print('Verified', path.name)
            continue
        request = Request(record['url'], headers={'User-Agent': '5G-NR-Teaching-Notebooks/1.0'})
        with urlopen(request, timeout=60) as response:
            data = response.read()
        verify_pdf(data, record)
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(dir=folder, suffix='.download', delete=False) as output:
                temporary = output.name
                output.write(data)
            os.replace(temporary, path)
        finally:
            if temporary and Path(temporary).exists():
                Path(temporary).unlink()
        print('Downloaded and verified', path.name)
    archive = protocol_archive(ROOT)
    print(f'{len(records(ROOT))} verified PDFs and {archive.name} ready in references/3gpp/.')
    print('Local reference files are excluded from Git and the distributable reading ZIP.')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        sys.exit(f'Reference setup failed: {error}. Fix the reported file or connection, then rerun python references/3gpp/download.py.')
