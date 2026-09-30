# MATLAB laboratories

Each `uniXX/` folder owns its experiment functions, acceptance tests, configuration and retained numerical results. Use the corresponding Jupyter notebook for a short interactive run, or the laboratory entry below for the complete experiment. Read each lab's README before starting a parameter sweep.

In MATLAB, set the current directory to the repository root and run:

```matlab
addpath(genpath('matlab'));
test_uni01;
```

| Lab | Complete experiment | Focus |
| --- | --- | --- |
| uni01 | `run_uni01` | SSB generation, search and MIB recovery |
| uni02 | `run_uni02`; `run_uni02_coded` | Reference signals, fading and coded PDSCH |
| uni03 | `run_uni03` | Broadcast control and SIB1 |
| uni04 | `run_uni04`; `uni04_expansion` | PRACH, timing advance and aligned PUSCH |
| uni05 | `run_uni05` | LDPC and HARQ comparisons |
| uni06 | `run_uni06` | Power control and coverage sweep |
| uni07 | `run_uni07` | CSI and adaptive MIMO |
| uni08 | `run_uni08` | Access, RRC subset and bidirectional transport |
| uni09 | `run_uni09` | Multiuser network simulation |

`results/` retains selected teacher runs as MAT arrays and CSV summaries, including their configuration and software version where recorded. These are scientific evidence, not caches. Full experiments can take time and some entries overwrite their lab's `results/` files; keep a copy if you want to preserve the supplied baseline. Interactive notebooks write to separate `jupyter/student-results/` directories.

`pubfig.m` controls scientific figure formatting. `replot_all('uni01')` redraws that lab's figures from saved data; examine each lab's plotting entry before regenerating its reference illustrations. Conceptual diagrams in the notes are separate from MATLAB results.

The code calls licensed Toolbox APIs. Vendor example helpers are resolved from your local MathWorks installation. Uni-03 and Uni-08 require the example path described in the [root README](../README.md); their Python codecs use pycrate from the configured course environment. No MATLAB or Toolbox implementation files are distributed.
