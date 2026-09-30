# Uni-04 — PRACH and uplink timing

In MATLAB from the repository root: `addpath(genpath('matlab')); test_uni04;`. `run_uni04` runs the PRACH and PUSCH baseline; `uni04_expansion` produces the additional timing experiments. Use `jupyter/notebooks/Uni-04.ipynb` for the shorter sequence.

`config.json` owns the baseline numerology, PRACH configuration, delay, detection threshold, noise definition, seeds and trial counts. `uni04_prach` produces and detects the preamble; `uni04_ta` converts the arrival estimate into a timing advance; `uni04_pusch` measures the effect on uplink decoding.

`results/run.mat`, `results/expansion.mat` and their CSV files retain the teacher data. `test_outputs` and `test_expansion` check those arrays. `uni04_plots` renders them. MATLAB R2026a and 5G Toolbox are required. Keep the estimated timing residual distinct from the residual computed using the injected delay.
