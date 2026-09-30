# Uni-09 — Connected multiuser cell

In MATLAB from the repository root: `addpath(genpath('matlab')); test_uni09; test_uni09_outputs;`. Run `run_uni09` for all scenarios or open `jupyter/notebooks/Uni-09.ipynb` for a short comparison.

MATLAB R2026a, 5G Toolbox and Wireless Network Toolbox are required. The runner's `cfg` struct sets frequency, bandwidth, powers, duration, steps, repetitions and seed. The interactive `jupyter/uni09_network_experiment.m` additionally takes the user positions, scenario and scheduling policy from the notebook.

The simulation begins with connected users and compares Round Robin, Proportional Fair and Best CQI scheduling. `results/run.mat`, `summary.mat` and CSV files retain throughput, delay, retransmissions and fairness measurements; `uni09_replot` redraws them.

The PHY is abstract and the propagation assumptions are stated in the note. A user with no delivered packets has undefined packet delay. Short single cell experiments do not establish deployment performance or URLLC reliability.
