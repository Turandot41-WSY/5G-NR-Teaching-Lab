# Sources and distribution choices

The course cites its sources beside the relevant explanations and in each note's references. This folder owns the reference files, their download code and the records of their origins. The textbook reference page provides chapter DOIs. See [3gpp/README.md](3gpp/README.md) for the ten core PDFs and their fixed versions.

From the repository root, run `python references/3gpp/download.py` to download or verify the PDFs and generate `references/3gpp/3GPP-Rel-18-Core-Specifications.zip`. The site builder uses the verified files for direct PDF links and the sidebar ZIP download. Internet access is needed for missing files; an existing file with a different hash stops the download. The installer runs this step automatically, and startup checks it again before serving the website.

There is one reference directory. The previous `documents/` contents are now owned here. PDF files and their generated ZIP stay local and are ignored by Git; source URLs and SHA-256 values are tracked. The reusable reading ZIP points to the official documents.

The source image manifests distinguish original teaching diagrams and simulation plots from reproduced images. Only the former are included. `omitted-source-images.json` records the corresponding public source links and locations for omitted reproductions. A previous `student_export: true` flag by itself is not treated as a copyright licence.

The original local course includes reproduced textbook/Notion images, ShareTechnote screenshots and specification excerpts. They remain in the author's Vault and are absent from this repository. Unclassified images are excluded by default. Figures here are retained according to their original manifest classification; this selection is not a legal opinion about every possible use of the material.

MATLAB and MathWorks example implementations are installed by the student under the applicable licence. Python packages and Quarto are installed as dependencies, not copied from the author's environment. The source repository does not vendor those distributions.

`source-map.json` records the import snapshot. Maintain the distributed Markdown in `notes/`, review any new external material for redistribution permission, and rebuild the site. When importing later revisions from the private Vault, review their differences before applying them to these files; private source folders must not be copied wholesale. Generated site output and local experiment outputs are ignored by Git.
