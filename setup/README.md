# Environment setup

The [root README](../README.md#install-with-miniconda) contains the complete student installation, MATLAB configuration, startup and verification instructions.

From the repository root, `python start.py --check-environment` checks installed dependencies without downloading files or starting a server. `python setup/install.py` reuses a compatible environment, checks an actual Quarto render and kernel registration, prepares notebooks and references, and saves the interpreter in ignored `local-config.json`. Specify `--python PATH` to select an existing interpreter explicitly. These commands do not install packages.

If a first installation is necessary, `python setup/install.py --create` explicitly creates the shared Conda environment `fiveg-notebooks`, outside the checkout. Multiple clones reuse it. Its Python, Jupyter, Quarto and dependencies can use 1–2 GB or more; Conda caches and generated course files use additional space. Only `--update` updates that shared environment. It affects every clone using it; stop their servers first. Existing project environments are preserved.

`environment_selection.py` checks pinned versions, imports, the MATLAB kernel and Quarto. Discovery checks local environments, the current interpreter, the shared Conda name and registered older course environments. Arbitrary Conda environments are not scanned. `runtime_environment.py` prepares the selected process environment and the verified protocol archive. Each ordinary startup verifies or downloads the ten PDFs and generates their ZIP before exposing the website. A saved interpreter that is no longer valid produces an error; use `--python` to replace it. Paths and environments stay out of Git.
