# Reading website

Run `python3 publish_site.py build` from the repository root. The exporter reads `notes/`, the original figure manifests and `references/3gpp/spec-manifest.yml`. Quarto renders 50 pages with search, abbreviation lookup, parallel reading, figure zoom and the existing day/night theme.

Outputs are `site/student-source/`, `site/student-site/` and the reading ZIP in this folder. They are generated and excluded from version control. The ZIP is for reading; clone the repository to obtain MATLAB, Jupyter and setup files.

`python3 publish_site.py --no-browser` serves the reading site on localhost:8765 and rebuilds when its inputs change. `python3 start.py` serves the site through the authenticated Jupyter runtime on localhost:8891 so the Uni execution cells can run MATLAB.

The shared theme lives in `tokens.css`, `approved-design.css` and `export_theme.py`. Teaching content belongs in Markdown. Third-party source images excluded from the distribution are not restored during builds.

`validate_distribution.py` checks note links, figure hashes, notebook structure and retained experimental tables. Run it directly with `python site/validate_distribution.py` after activating the course environment, or through `python publish_site.py build --validate`.

The sidebar's **3GPP protocols (ZIP)** link serves the verified archive from `references/3gpp/`. Both launchers prepare its ten PDFs and ZIP before building pages, including when an earlier installation skipped references. Missing PDFs are downloaded; verified copies are reused. A download or checksum failure stops startup and reports the cause. The distributable reading ZIP uses official links, while the installed local site supplies the protocol archive.

The launcher checks a saved build fingerprint against notes, references and builder inputs. A change after `git pull` triggers a rebuild. A failed build prevents startup from presenting an outdated page as the new version.

The reading server reserves its port before building. Its local status endpoint identifies the checkout using a hash of its resolved path; a repeated command for the same checkout reuses the existing server. Pages return HTTP 503 while the first build is running. An unknown listener produces a short port conflict message before any build, and a failed startup releases its own port. Existing services are never stopped automatically.
