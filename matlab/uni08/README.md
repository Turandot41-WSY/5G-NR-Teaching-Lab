# Uni-08 — Radio access and first transfer

In MATLAB from the repository root: `addpath(genpath('matlab')); uni03_setup; test_uni08; test_uni08_control;`. Run `run_uni08` for the full experiment or `jupyter/notebooks/Uni-08.ipynb` for one access sequence and its checks.

This lab composes Uni-01, Uni-03 and Uni-04. It requires MATLAB R2026a, 5G Toolbox, the locally installed MathWorks cell search example and Python with pycrate. `setup/install.py` installs Python dependencies; see `setup/README.md` for the example path.

`uni08_control` handles the selected control messages, `uni08_packet` carries shared channel payloads, `uni08_rar` encodes and decodes the random access response, and `uni08_states` evaluates procedural cases. `rrc_codec.py` and `rrc-fixtures.json` provide the selected RRC messages. The interactive worker is `jupyter/uni08_access_experiment.m` inside this lab.

`results/run.mat` and CSV files retain the teacher run. `uni08_plots` renders its outputs. The recovered SFN anchors the PRACH calendar. Control resources and later grants are explicitly configured; RRC/SRB1 support is a message subset, NAS is opaque, and the final packets are physical transport tests rather than an IP service.
