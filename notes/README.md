# Reading notes

Start with [Course Index](Course%20Index.md). The 37 Star notes and nine Uni notes are in `05 Knowledge Syntheses/`; the shared abbreviation database is in `09 Abbreviation Database/`. Original figures are in `99 Attachments/5G/`.

This folder is a distribution copy of the maintained Obsidian course. It preserves the teaching text while replacing third-party image reproductions with source references. The private Vault remains the author's working source. `references/source-map.json` records the source and delivered hashes at import; there is no automatic sync between a clone and the author's Vault.

You can open this folder as an Obsidian vault. Edit Markdown, then run `python3 publish_site.py build` from the repository root to update the local website. The website is generated from these notes; do not edit generated HTML.

Use `!important[...]`, `!warning[...]` and `!note[...]` for website annotations. Native Obsidian callouts are also supported. The existing source colours and day/night theme are retained.

Execution cells are maintained separately in `jupyter/cells/`. To edit both notes and code in Obsidian, open the repository root as a vault. Local relative filenames and wikilinks should be preserved when moving content.
