# Uni-02 — Reference signals and equalization

In MATLAB from the repository root: `addpath(genpath('matlab')); test_uni02;`. `run_uni02` performs the reference signal and channel estimation sweep; `run_uni02_coded` adds transport block coding. The interactive notebook is `jupyter/notebooks/Uni-02.ipynb`.

The configuration struct near the start of `run_uni02.m` controls SNR, Doppler, DM-RS density, seeds and trial count. `uni02_link` returns the generated grid, channel estimates and receiver outputs. `uni02_coded` returns the coded transport experiment. The grid model is explicitly documented in the note; uncoded BER and coded CRC results have different meanings.

Teacher evidence is in `results/run-20260907-120305/` and `results/coded-20260907-120710/`. `uni02_plots` draws the saved data. MATLAB R2026a, 5G Toolbox and Communications Toolbox are required.
