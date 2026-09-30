# 5G NR Teaching Lab

Follow a 5G idea from the textbook into a 3GPP specification, then into MATLAB and a signal you can inspect. These notes are for students who know the basics of digital communications and want to understand how the pieces of a radio system work together.

The course has three layers:

| Layer | Contents | What you can do with it |
| --- | --- | --- |
| Textbook and system view | Star-01–27 | Learn each mechanism and locate it within the UE, radio channel and network. |
| Reading the specifications | Star-28–37 | Find the Release 18 specification and clause that defines a signal, parameter or procedure. |
| Engineering in MATLAB | Uni-01–09 | Trace an engineering task through its parameters, arrays, receiver decisions and measured results. |

## Install with Miniconda

Install [Miniconda](https://www.anaconda.com/docs/getting-started/miniconda/install) for your operating system. You also need a licensed **MATLAB R2026a** with **5G Toolbox** and **Communications Toolbox**; Uni-09 additionally needs **Wireless Network Toolbox**. Install MATLAB and the toolboxes through MathWorks or your university licence. The course installer handles Python, Jupyter and website dependencies.

Download and extract this repository, or clone it with Git:

```sh
git clone https://github.com/Turandot41-WSY/5G-NR-Teaching-Lab.git
cd 5G-NR-Teaching-Lab
```

Use a terminal where `conda --version` works; on Windows, open **Anaconda Prompt (Miniconda)**. Run one setup command:

```sh
python setup/install.py
```

Setup creates an isolated **`.conda/`** environment inside this repository. It installs Python 3.12, Quarto 1.8.27, JupyterLab, the MathWorks MATLAB kernel and the packages in [setup/requirements.txt](setup/requirements.txt). It generates nine notebooks, downloads ten fixed versions of the core specifications into **`references/3gpp/`**, checks each PDF's SHA-256, and packs them into **`3GPP-Rel-18-Core-Specifications.zip`** in the same folder. Package dependencies and kernel registration are checked before setup reports success. Internet access is required on the first run. Your Conda base environment is preserved.

The direct dependencies are pinned in [environment.yml](environment.yml) and the requirements file. Conda resolves additional platform dependencies; binary packages may therefore differ between operating systems. This setup and MATLAB execution have been tested on macOS. Windows and Linux execution still need testing on those platforms.

If the official PDF service is unavailable, setup can finish with `python setup/install.py --skip-references`. The next `python start.py` retries the reference download before opening the course. An existing PDF with a different checksum causes an error; inspect the named file before retrying.

## Start the notebook

From the repository root, run:

```sh
python start.py
```

The launcher selects the course environment automatically, prepares the reference files, rebuilds when notes or site code have changed, and opens an authenticated local page. Choose a Uni note, click **Connect MATLAB**, and run its cells in order. **Download notebook** saves your edited cells and their current outputs. After setup, you can also double-click **Open Notebook.command** on macOS or **Open Notebook.bat** on Windows.

The server listens on `127.0.0.1:8891`. Keep the terminal open; press **Ctrl+C** there to stop it. One server shares one MATLAB workspace: run one experiment at a time. Your MATLAB licence and toolboxes are required for execution. A static page alone cannot run MATLAB.

Uni-03 and Uni-08 additionally use the licensed MathWorks cell search example. Install it in MATLAB with:

```matlab
openExample('5g/NRCellSearchMIBAndSIB1RecoveryExample')
```

Save its local folder and, if needed, your MATLAB executable path with:

```sh
python setup/install.py --example-directory "/path/to/NRCellSearchMIBAndSIB1RecoveryExample" --matlab "/path/to/matlab"
```

Replace the example paths with your own. On Windows, the MATLAB executable is usually `C:\Program Files\MATLAB\R2026a\bin\matlab.exe`; on macOS the launcher also searches `/Applications`. On Linux, put MATLAB on PATH or provide `--matlab`. These settings are saved in ignored `local-config.json`. Repeating setup updates the same course environment and preserves existing settings. Vendor example files come from your MATLAB installation.

### Check the installation

Activate the course environment to use its commands directly:

```sh
conda activate ./.conda
quarto --version
python -m jupyter kernelspec list
python publish_site.py build --validate
python -m unittest discover -s tests
```

Quarto should report `1.8.27`; the kernel list should include `jupyter_matlab_kernel`. In MATLAB, `ver` should list the required toolboxes. Connecting and running Uni-01 checks whether MATLAB can start with your licence. Package installation alone cannot verify a MATLAB licence.

If port 8891 is occupied, use `python start.py --port 8892`. Add `--no-browser` to keep startup in the terminal. Credentials stay in a private temporary directory; never publish them or expose the MATLAB execution server to the Internet.

## Open the original specifications

Run **`python start.py`** to prepare the course. It downloads any missing fixed versions of the ten PDFs, verifies their hashes, creates the ZIP, rebuilds the pages when needed, and starts the website with MATLAB support. Existing verified PDFs are reused, so subsequent starts work offline. If preparation fails, startup stops with the failing file or connection; resolve that error and rerun the same command.

Click **References → 3GPP protocols (ZIP)** in the website sidebar to download all ten core protocol PDFs as one archive. The archive contains the full, unmodified PDFs for Star-28–37. You can also open the files directly in **`references/3gpp/`**.

Each of **Star-28–37** begins with **Open the specification PDF**, followed by its exact version. The local website opens the verified file; GitHub Markdown opens the official PDF directly. The [reference index](references/3gpp/README.md) lists the versions and official links. Installation keeps the versions used by the course.

The PDFs and protocol ZIP are created on your computer and ignored by Git. The separately generated reading ZIP omits these reference files and uses official links. The version manifests remain available for reproducibility checks; they are not the sidebar's protocol download.

### After pulling an update

Stop the running server with **Ctrl+C**, then run these commands from the repository root:

```sh
git pull --ff-only
python start.py
```

Startup moves verified PDFs from the previous `documents/3gpp/` location into `references/3gpp/`, prepares the protocol ZIP and rebuilds an outdated website. Files you added to the old folder are preserved. Refresh the browser after startup. If an update changes the environment files, run `python setup/install.py` before starting.

## How to use the site

- **Search.** The box at the top of the chapter list searches every page.
- **Abbreviation lookup.** Type in the small box in the right margin, or press `a`, to look up a term without leaving the page.
- **Section list.** The right margin shows the sections of the note you are reading. Click a heading to jump there.
- **Parallel reading.** Press `Split` in the top bar, or `s`, to open a second note. Choose it from the list in the bar, or hold Alt (Option) and click a chapter. Each pane has its own section list, and both share the abbreviation lookup. `Swap` exchanges the notes; drag the divider to adjust their widths.
- **Figures.** Click a figure to see it at full size; click again to close it.
- **Reading tools.** `Night` changes the theme, `A−` and `A+` change text size, and `Normal` cycles through the reading widths. Drag the chapter list's edge to resize it. Press `?` to see the keyboard shortcuts.
- **Protocol download.** Under **References**, click **3GPP protocols (ZIP)** to save the ten specifications used in the protocol notes.

### Colour tells you the source

The coloured title bars and labels show where an explanation comes from: steel for the textbook, red for 3GPP, blue for engineering commentary, and green for MATLAB and its results. **Important**, **Warning** and **Note** highlight points to notice using yellow, peach and lavender.

## Reading, editing and running

| Module | Input and entry | Output and next step |
| --- | --- | --- |
| [setup](setup/README.md) | `python setup/install.py`; environment files and your MATLAB path | Course environment; then run `python start.py` |
| [references](references/README.md) | `python references/3gpp/download.py`; fixed official URLs and hashes | Verified PDFs and protocol ZIP for the website |
| [notes](notes/README.md) | Obsidian Markdown and figures; begin at [Course Index](notes/Course%20Index.md) | Teaching content passed to the site builder |
| [site](site/README.md) | `python publish_site.py build --validate`; notes, references and theme | Reading website served by the launcher |
| [jupyter](jupyter/README.md) | Markdown execution cells and the local Jupyter service | Calls the MATLAB labs and displays their output |
| [matlab](matlab/README.md) | Nine laboratories, configuration and retained numerical evidence | Waveforms, decoded fields and plots returned to the student |
| [tests](tests/README.md) | `python -m unittest discover -s tests` | Checks of installation, downloads and module interfaces |

For a first complete run, install, start, and open **Uni-01**. Connect MATLAB and execute its cells in order. The default experiment should recover **PCI 321** and **SFN 426**. Download the notebook to retain the code and outputs from that run.

Open `notes/` in Obsidian to read and edit the course. To rebuild after edits:

```sh
python3 publish_site.py build
python3 start.py
```

The command and the double-click launchers open **Course Index**. Choose a Uni note from the navigation to use its MATLAB cells. To open a specific experiment directly, use `python start.py --lab uni01` (or another Uni number).

For reading with automatic rebuilds, use `python3 publish_site.py --no-browser` and visit `http://127.0.0.1:8765`. This entry prepares the same protocol ZIP before building or serving pages. Refresh after a rebuild. This reading server is separate from the MATLAB execution server. The root launcher supports `--lab uni09`, `--matlab`, `--port`, `--rebuild` and `--no-browser`.

Starting the reading server again reuses the server for this same project, with no second build. If it is still preparing, wait for its terminal to report ready. If another program or an older server occupies the port, startup stops before building and tells you how to close it or choose another port. Stop a server in its original terminal with `Ctrl+C`.

For the usual JupyterLab interface:

```sh
conda activate ./.conda
python -m jupyter lab
```

Open a notebook under `jupyter/notebooks/` and select **MATLAB Kernel**. For Uni-03/08 in JupyterLab, run this additional MATLAB cell with your installed example directory: `setenv('NR_CELL_SEARCH_EXAMPLE','/path/to/NRCellSearchMIBAndSIB1RecoveryExample');`. The course website passes this setting from `local-config.json` automatically.

## Experiments

| Note | Engineering task |
| --- | --- |
| Uni-01 | Cell search, synchronization and MIB recovery from I/Q samples |
| Uni-02 | Reference signals, channel estimation and PDSCH equalization |
| Uni-03 | MIB, CORESET0, PDCCH and SIB1 recovery |
| Uni-04 | PRACH detection, timing advance and uplink alignment |
| Uni-05 | Transport blocks, LDPC coding and HARQ |
| Uni-06 | PUSCH power control and coverage |
| Uni-07 | CSI feedback and adaptive MIMO |
| Uni-08 | Radio access, an RRC message subset and the first bidirectional transport blocks |
| Uni-09 | A connected multiuser TDD cell, scheduling and delivered performance |

Uni-08 implements the documented teaching subset of access and RRC; it does not provide a complete core network or IP service. Uni-09 uses the network simulator's abstract PHY. The notes explain these assumptions alongside the results. Retained plots come from saved MATLAB runs; short interactive comparisons are demonstrations, not replacements for the statistical experiments.

## Sources and distribution

The theoretical structure follows Dahlman, Parkvall and Sköld's *5G NR: The Next Generation Wireless Access Technology*, second edition. The notes cite fixed 3GPP versions and use ShareTechnote for engineering explanations.

This distribution contains the author's teaching text, original illustrations, simulation plots and course code. Reproduced textbook, Notion, ShareTechnote and specification images are omitted where redistribution permission has not been established; the notes retain citations. Books, slides, standards archives, proprietary MATLAB files, private project records and temporary build files are excluded. [Source handling](references/README.md) explains the selection. Third-party material remains subject to its own rights and permissions.

## License and maintenance

The original materials and code use the [Education and Noncommercial Research License 1.0](LICENSE). You may use, run, adapt and share them for teaching, personal study and noncommercial research, with attribution and retained notices. Commercial use requires separate written permission. The license explains ordinary university teaching, academic publication and third-party exclusions. It is a custom license with restrictions on purpose; this project is not distributed under an OSI-approved open source license.

For future edits, use this repository's Markdown and code as the working source. [Maintaining the course](MAINTAINING.md) explains Obsidian editing, commit email privacy, validation and publishing updates. Run `python site/check_publication.py` before committing and again before pushing. GitHub also checks source files and Git history on each push and pull request.

## Acknowledgement

These notes are a gift to Prof. Dr.-Ing. Thorsten Herfet and the 5G teaching team at Saarland University. Thorsten shared the course's Jupyter notebooks and offered encouragement while my plans to join Saarland were uncertain. Having struggled to connect 5G theory, scattered specifications and working implementations during my own research, I wanted to make that journey easier for the students who follow. This course grew from that opportunity and kindness.

**Author:** Shiyi Wang · shiyi.wang@it-u.at
