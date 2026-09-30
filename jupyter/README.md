# Jupyter teaching notebooks

`notebooks/Uni-01.ipynb` through `Uni-09.ipynb` contain 62 MATLAB execution cells. They are delivered without execution counts or outputs. The saved teacher plots remain in the notes; running a cell produces a new result on your computer.

The editable source is `cells/* Execution Cells.md`. Activate your selected course environment (`conda activate fiveg-notebooks` for the shared installation), then regenerate notebooks from the repository root with `python jupyter/export_notebooks.py`. If you reused an older environment, activate its prefix instead. The website reads these same cell sources and inserts them at the corresponding note headings.

The easiest entry is `python start.py` from the repository root. It opens Course Index; select a Uni note to reach its MATLAB cells. Use `python start.py --lab uni01` to open a particular experiment directly. For JupyterLab, activate the course Conda environment, use `python -m jupyter lab` and open a notebook in `notebooks/`. Both use MathWorks' `jupyter_matlab_kernel`, a licensed local MATLAB and its toolboxes. Complete setup instructions are in the [root README](../README.md#install-with-miniconda).

For Uni-03/08 in a direct JupyterLab session, first run this additional MATLAB cell with your installed example directory:

```matlab
setenv('NR_CELL_SEARCH_EXAMPLE','/path/to/NRCellSearchMIBAndSIB1RecoveryExample');
```

The `start.py` website entry reads the directory from `local-config.json` and passes it automatically. The ASN.1 codecs locate the configured course environment through `matlab/course_python.m`.

Run cells in order and one experiment at a time. The official MATLAB kernel shares its workspace between notebooks on a server. Changes to an earlier website cell mark later results stale. Download the notebook to retain your edited cells and displayed results. The final cell saves arrays under the laboratory's ignored `jupyter/student-results/` folder.

`runtime/` contains the authenticated Jupyter extension and page adapter. Keep it on localhost. Never publish a server token or expose an unrestricted MATLAB kernel to the Internet.
