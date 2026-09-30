# Uni-07 — CSI and adaptive MIMO

In MATLAB from the repository root: `addpath(genpath('matlab')); test_uni07;`. Run `run_uni07` for the comparison or open `jupyter/notebooks/Uni-07.ipynb`.

The runner's `cfg` struct defines channel, noise levels, seed and repetition count. `uni07_codebook` supplies the teaching precoders. CSI measurements select transmission parameters before PDSCH reception; the note explains the assumptions for each strategy.

`results/run.mat` and its CSV summaries retain 720 trials. `uni07_replot` renders the saved arrays. Delayed feedback in this experiment delays PMI while MCS uses newly measured quality; the SVD comparison idealizes precoding. MATLAB R2026a and 5G Toolbox are required.
