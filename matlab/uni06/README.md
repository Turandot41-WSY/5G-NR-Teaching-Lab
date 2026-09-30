# Uni-06 — PUSCH power and coverage

In MATLAB from the repository root: `addpath(genpath('matlab')); test_uni06;`. Run `run_uni06` for the sweep or `jupyter/notebooks/Uni-06.ipynb` for selected operating points.

The `cfg` struct in `run_uni06.m` sets resource allocation, path loss, compensation factor, power limit, noise figure and seed. `uni06_power` computes the commanded and limited transmit powers. The runner creates actual PUSCH waveforms, estimates the channel and decodes transport blocks.

`results/run.mat`, `trials.csv` and `summary.csv` retain 768 trials. `uni06_replot` redraws them. The experiment supplies scheduling and timing explicitly to isolate coverage. MATLAB R2026a and 5G Toolbox are required.
