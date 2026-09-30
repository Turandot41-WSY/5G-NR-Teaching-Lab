# Uni-01 — Cell acquisition

From the repository root in MATLAB: `addpath(genpath('matlab')); test_uni01;`. Run `run_uni01` for the full saved experiment, or `jupyter/notebooks/Uni-01.ipynb` for seven interactive stages.

Edit `uni01_config.m` for the transmitter and receiver configuration. `uni01_tx` produces an SSB; `uni01_observe` adds noise, frequency offset and delay; `uni01_rx` recovers synchronization and broadcast fields; `uni01_accept` compares the recovered fields with the transmitter. Reception uses samples and receiver configuration, not the injected ground truth.

The supplied baseline is `results/run-20260907-002810/`. It includes MAT arrays and CSV summaries. `uni01_plots` and `uni01_plots_extra` render the saved arrays. MATLAB R2026a and 5G Toolbox are required. Correlation, estimation and acceptance policy are engineering choices described in the note.
