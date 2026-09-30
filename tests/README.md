# Delivery checks

For source tests on a clean clone without MATLAB or Quarto, install
`python -m pip install -r tests/requirements.txt`. The tests generate temporary
page mappings from the real note filenames and exporter; an existing website
build is not required. This is also the dependency set used by GitHub checks.

Before publication, run `python site/check_publication.py`. It checks candidate
files, the staged index and reachable Git history, including commit emails.
Its tests cover ignored files, forced additions, staged and historical secrets,
notebook outputs, local paths and symlinks. See [maintenance](../MAINTAINING.md)
for the review steps that remain manual.

Activate the course environment from the repository root, then run the commands below. If you reused another environment, activate its prefix instead of the shared name `fiveg-notebooks`.

```sh
conda activate fiveg-notebooks
python -m unittest discover -s tests
python publish_site.py build --validate
```

The tests check module paths, clean MATLAB notebooks, installation commands, verified PDF links, protocol ZIP contents and detection of an outdated website. Temporary test inputs are created outside the course and removed when each test ends.

The site validation checks the actual notes, figures, source hashes and retained experiment tables. It does not rerun MATLAB. The separate execution check in `jupyter/runtime/verify_all_uni.py` needs a running authenticated local service and the required MATLAB toolboxes; see the Jupyter module before using it.
