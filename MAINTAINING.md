# Maintaining the course

Use this repository as the working source for future public updates. Its
first commit contains the reviewed course snapshot. Earlier private Git
history is kept separately and must not be merged into this repository.

## Choose your working copy

```sh
git clone https://github.com/Turandot41-WSY/5G-NR-Teaching-Lab.git
cd 5G-NR-Teaching-Lab
python start.py --check-environment
```

If the check passes, the clone can reuse the printed interpreter. Run
`python setup/install.py --python PATH` to save a specific existing interpreter.
Only a first installation needs `python setup/install.py --create`; it creates
one shared environment for reuse by later clones. See the root README for
disk space and dependency update instructions.

Open this copy's `notes/` folder in Obsidian. Those Markdown files are the
website's source. Keep teaching cells in `jupyter/cells/` and MATLAB functions
in `matlab/`; see their module READMEs for the exact locations. The older
private Vault is an archive and optional source of reviewed imports. Editing
it does not automatically update this repository. Compare and import intended
changes without copying private attachments or another Git directory.

## Protect your commit email

In GitHub **Settings → Emails**, enable email privacy and copy your own
GitHub noreply address. Configure it in this checkout before committing:

```sh
git config --local user.name "YOUR NAME"
git config --local user.email "YOUR GITHUB NOREPLY ADDRESS"
git config --local user.useConfigOnly true
git config --local pull.ff only
```

Replace both uppercase values. Do this again for each new clone; Git does not
copy local configuration. Enable GitHub's option to block command line pushes
that expose your private email. Other contributors should use their own
noreply addresses. Changing a setting does not alter earlier commits.

## Edit, verify and publish

Before editing, check `git status` and use `git pull --ff-only` when your
working copy is clean. Keep local work safe if Git reports a conflict.
For a change, create a branch such as `git switch -c update-uni01`.

After editing, activate the shared course environment and run the commands
below. If you reused a different environment, activate that environment's
prefix instead of `fiveg-notebooks`.

```sh
conda activate fiveg-notebooks
python jupyter/export_notebooks.py
python -m unittest discover -s tests
python publish_site.py build --validate
python site/check_publication.py
```

Use `python start.py` to inspect the course. Changes to scientific code also
need the affected MATLAB checks and a saved verification of the resulting
figures and numbers. The commands above do not rerun the MATLAB experiments.
Review both page themes when a change affects display.

Inspect `git diff` and `git status --short`. Stage the intended paths with
`git add <paths>`, inspect `git diff --cached`, and run the publication check
again. It checks the staged bytes even when they differ from your working
files. Commit with a description of the change, run the check once more to
verify the new commit's email, and push your branch. Open a pull request,
review the changes and merge after the checks pass.

GitHub runs the publication check, Python tests and source validator on
pushes and pull requests. That automated check does not start MATLAB or
replace a local website build. Check locally before pushing: a failing
GitHub check cannot undo information that has already been uploaded.

## Files that stay local

Keep environments, credentials, local configuration, private context,
generated websites, protocol PDFs and ZIPs, caches and student outputs out
of Git. `.gitignore` covers the normal paths; never force add these files.
Retained teacher arrays and statistical tables under `matlab/` support the
published results and remain tracked. Review new arrays for private paths
and metadata before adding them.

`site/check_publication.py` checks candidate filenames, selected credential
patterns, local paths, notebook outputs, the Git index and reachable Git
history. It requires noreply author and committer emails. It reports paths
and categories without printing the matched secrets. Images, compressed
binary data and copyright permissions require separate review; passing the
script is not a guarantee that no sensitive material exists.

If a secret has already been pushed, revoke or rotate it immediately and
assess all affected copies. Deleting it in a later commit leaves it in
history. Coordinate any history repair before other people pull or push.

## Contributions and permissions

Include only material you have permission to contribute under [LICENSE](LICENSE),
or identify its separate license and compatibility before proposing it.
Preserve citations and notices. External specifications continue to download
from their official source on each student's machine. Permission requests
for commercial use go to the contact in the license.
