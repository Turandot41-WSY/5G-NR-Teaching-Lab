# 3GPP reference specifications

This folder holds the ten core specifications used by Star-28–37. After installation, the website sidebar offers **3GPP protocols (ZIP)**, and each protocol note opens its own PDF directly.

## Download and verify

Normal startup with `python start.py` downloads and verifies the references automatically. The reading entry `python publish_site.py` uses the same preparation step. For a separate reference check, run this optional command from the repository root:

```sh
python references/3gpp/download.py
```

The script downloads missing PDFs from the official ETSI service, verifies every SHA-256 and creates `references/3gpp/3GPP-Rel-18-Core-Specifications.zip`. It also moves verified downloads left in the old `documents/3gpp/` folder. No download is needed for files already present with the expected hashes. An incomplete set or a checksum mismatch prevents creation of a new archive.

The resulting folder contains filenames such as `TS-38.211-v18.9.0.pdf` and one ZIP containing all ten PDFs. Run `python start.py` to use them in the website. Successful setup and startup run the same verification automatically.

| Note | Specification | Version | Official PDF |
| --- | --- | --- | --- |
| Star-28 | TS 38.300 | 18.10.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138300/18.10.00_60/ts_138300v181000p.pdf) |
| Star-29 | TS 38.211 | 18.9.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.09.00_60/ts_138211v180900p.pdf) |
| Star-30 | TS 38.212 | 18.8.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138212/18.08.00_60/ts_138212v180800p.pdf) |
| Star-31 | TS 38.213 | 18.8.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138213/18.08.00_60/ts_138213v180800p.pdf) |
| Star-32 | TS 38.214 | 18.10.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138200_138299/138214/18.10.00_60/ts_138214v181000p.pdf) |
| Star-33 | TS 38.321 | 18.10.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138321/18.10.00_60/ts_138321v181000p.pdf) |
| Star-34 | TS 38.322 | 18.2.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138322/18.02.00_60/ts_138322v180200p.pdf) |
| Star-35 | TS 38.323 | 18.5.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138323/18.05.00_60/ts_138323v180500p.pdf) |
| Star-36 | TS 38.331 | 18.10.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138300_138399/138331/18.10.00_60/ts_138331v181000p.pdf) |
| Star-37 | TS 38.401 | 18.7.0 | [Open PDF](https://www.etsi.org/deliver/etsi_ts/138400_138499/138401/18.07.00_60/ts_138401v180700p.pdf) |

## Version records and distribution

`specifications.json` owns the ten PDF URLs, filenames and hashes; `specifications.py` verifies and packages them for the site. `spec-manifest.yml` retains 31 original archive references, including supporting specifications, release summaries and LTE comparisons. These records support version checks; readers can use the PDFs and ZIP directly.

The experiment versions are fixed. A newer release requires checking the affected equations, tables, MATLAB configuration and teaching claims. The ZIP is generated locally and contains ten PDFs, with no Word files or work caches. PDFs and ZIPs are ignored by Git and omitted from the distributable reading ZIP. The latter links to the official specifications. Additional personal references can go in the ignored `local/` directory.

See the [root README](../../README.md#install-with-miniconda) for installation and [source handling](../README.md) for distribution boundaries.
