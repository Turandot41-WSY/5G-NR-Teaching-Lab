# Uni-03 — MIB to SIB1

In MATLAB from the repository root: `addpath(genpath('matlab')); uni03_setup; test_uni03;`. Run `run_uni03` for acquisition, MIB recovery, PDCCH search, DL-SCH decoding and ASN.1 interpretation. The interactive notebook is `jupyter/notebooks/Uni-03.ipynb`.

MATLAB R2026a and 5G Toolbox are required. Install MathWorks' cell search example with `openExample('5g/NRCellSearchMIBAndSIB1RecoveryExample')`, then set `NR_CELL_SEARCH_EXAMPLE` to that folder. The root launcher can read this setting from `local-config.json`; see `setup/README.md`. Vendor helpers remain outside the repository.

`uni03_tx` owns the generated broadcast configuration. `uni03_receive` accepts recovered MIB fields, a capture grid and failure test options. `uni03_table` supplies the configured table mapping. `sib1-fixture.json` is the course's generated SIB1 message; `sib1_codec.py` uses the installed pycrate package. The interactive notebook can stop at recovered transport bits or optionally parse ASN.1. The batch runner includes parsing.

The baseline `results/run-20260907-122809/` retains waveform and receiver arrays plus the 120 conditional trials. `uni03_plots` redraws them. This experiment uses a partial broadcast capture and the documented Case C/30 kHz configuration; it is not a general conformance receiver.
