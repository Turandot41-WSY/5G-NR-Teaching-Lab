# Uni-05 — LDPC and HARQ

In MATLAB from the repository root: `addpath(genpath('matlab')); test_uni05;`. Run `run_uni05` for the complete comparison or open `jupyter/notebooks/Uni-05.ipynb`.

The configuration struct in `run_uni05.m` defines transport block size, code rate, coded length, redundancy versions, SNRs, trial count, decoder iterations and seed. `uni05_link` processes one link scenario. The comparison covers incremental redundancy, Chase combining and resetting the combining state.

`results/run-20260907-120612/` contains arrays and 5,040 decoder attempts. `uni05_plots` redraws the retained results. The note distinguishes attempts from independent trials when reporting error rates and intervals. MATLAB R2026a, 5G Toolbox and Communications Toolbox are required.
