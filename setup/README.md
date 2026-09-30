# Environment setup

The [root README](../README.md#install-with-miniconda) contains the complete student installation, MATLAB configuration, startup and verification instructions.

From a Miniconda terminal at the repository root, `python setup/install.py` installs the course environment and downloads the core specification PDFs. The installer reads `environment.yml` and `setup/requirements.txt`; it saves machine settings in ignored `local-config.json` after setup succeeds.

`runtime_environment.py` selects the configured interpreter for both launchers, resolves the environment's Quarto tools and runs their shared protocol preparation step. Each startup verifies or downloads the ten PDFs and generates their ZIP before exposing the website. Existing installations can retain `.venv` until Conda setup completes. Environment directories and machine paths are excluded from Git.
