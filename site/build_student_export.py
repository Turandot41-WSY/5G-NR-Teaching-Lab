#!/usr/bin/env python3
"""Build the local Saar 5G NR website; --archive also exports a portable ZIP."""

from __future__ import annotations

import argparse
import re
import json
import shutil
import subprocess
import sys
import hashlib
import tempfile
from html.parser import HTMLParser
from urllib.parse import unquote, urlsplit
from pathlib import Path

import yaml

# The tests load this file via spec_from_file_location, which does not put the
# script's own directory on sys.path. Add it so the shared theme module resolves
# whether this runs as a script or as a loaded module.
if str(Path(__file__).resolve().parent) not in sys.path:
    sys.path.insert(0, str(Path(__file__).resolve().parent))

from export_theme import render_export_css, render_export_js, render_export_theme_scss
import note_annotations
from local_assets import compact_assets, resolve_asset, reading_export

REPOSITORY = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPOSITORY / 'references/3gpp'))
from specifications import (localize_links, verified_documents, copy_documents,
                            records, copy_protocol_archive, PROTOCOL_ZIP, OFFICIAL_INDEX)
ROOT = REPOSITORY / "notes"
EXPORT = Path(__file__).resolve().parent
SOURCE = EXPORT / "student-source"
SITE = EXPORT / "student-site"
ZIP_BASE = EXPORT / "Saar-5G-NR-Teaching-Knowledge-Base"


def stars() -> list[Path]:
    paths = sorted((ROOT / "05 Knowledge Syntheses").glob("Star-*.md"))
    return sorted(paths, key=star_number)


def uni_notes() -> list[Path]:
    return sorted((ROOT / "05 Knowledge Syntheses").glob("Uni-*.md"))


def uni_number(path: Path) -> int:
    match = re.search(r"Uni-(\d+)-", path.name)
    if not match:
        raise RuntimeError(f"invalid Uni filename: {path.name}")
    return int(match.group(1))


def star_number(path: Path) -> int:
    match = re.search(r"Star-(\d+)-", path.name)
    if not match:
        raise RuntimeError(f"invalid Star filename: {path.name}")
    return int(match.group(1))


def output_for(path: Path) -> str:
    if path.name.startswith("Uni-"):
        number = uni_number(path)
        slug = re.sub(r"^Uni-\d+-", "", path.stem).casefold().replace(".", "-")
        return f"uni/uni-{number:02d}-{slug}.qmd"
    number = star_number(path)
    slug = re.sub(r"^Star-\d+-", "", path.stem).casefold().replace(".", "-")
    folder = "book" if number <= 27 else "protocol"
    return f"{folder}/star-{number:02d}-{slug}.qmd"


def title_for(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"^#\s+(.+)$", text, re.MULTILINE)
    return (match.group(1) if match else path.stem).replace('"', "'")


def reset() -> None:
    for path in (SOURCE, SITE):
        if path.exists():
            shutil.rmtree(path)
    archive = ZIP_BASE.with_suffix(".zip")
    if archive.exists():
        archive.unlink()
    for folder in ("book", "protocol", "uni", "images", "manifests"):
        (SOURCE / folder).mkdir(parents=True, exist_ok=True)


def strip_frontmatter(text: str) -> str:
    return re.sub(r"\A---\n.*?\n---\n", "", text, count=1, flags=re.S)


def convert_callouts(text: str) -> str:
    return note_annotations.convert(text)


def rel_target(output_rel: str, target_rel: str) -> str:
    depth = len(Path(output_rel).parent.parts)
    return "../" * depth + target_rel


def export_asset_rel(path: Path) -> str:
    """Return a collision-safe student asset path that preserves source folders."""

    attachment_root = (ROOT / "99 Attachments" / "5G").resolve()
    resolved = path.resolve()
    if resolved.parts[: len(attachment_root.parts)] != attachment_root.parts:
        raise ValueError(f"image is outside the managed 5G attachment root: {path}")
    relative = Path(*resolved.parts[len(attachment_root.parts):])
    return (Path("images") / relative).as_posix()


def approved_star_images() -> list[Path]:
    """Return every student-approved local image embedded by a Star."""

    manifest_path = ROOT / "01 Source Collections" / "Visual Evidence Manifest.yml"
    records = yaml.safe_load(manifest_path.read_text(encoding="utf-8"))
    approved = {
        str(record["local_file"])
        for record in records
        if bool(record.get("student_export"))
    }
    embedded: set[str] = set()
    for star in stars():
        embedded.update(
            match.group(1).split("|", 1)[0].strip()
            for match in re.finditer(r"!\[\[([^\]]+\.png(?:\|[^\]]+)?)\]\]", star.read_text(encoding="utf-8"), re.I)
        )
    uni_manifest = ROOT / "01 Source Collections" / "Uni Visual Evidence Manifest.yml"
    if uni_manifest.is_file():
        for record in json.loads(uni_manifest.read_text(encoding="utf-8")):
            if bool(record.get("student_export")):
                approved.add(str(record["local_file"]))
    excerpts = ROOT / "01 Source Collections/Uni Protocol Excerpts.json"
    if excerpts.is_file():
        for record in json.loads(excerpts.read_text(encoding="utf-8"))["records"]:
            if record.get("student_export"):
                path = ROOT / record["local_file"]
                if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != record["sha256"]:
                    raise RuntimeError(f"protocol excerpt missing or changed: {path}")
                approved.add(str(record["local_file"]))
    for note in uni_notes():
        embedded.update(
            match.group(1).split("|", 1)[0].strip()
            for match in re.finditer(r"!\[\[([^\]]+\.png(?:\|[^\]]+)?)\]\]", note.read_text(encoding="utf-8"), re.I)
        )
    missing_manifest = sorted(path for path in embedded if path not in approved)
    if missing_manifest:
        raise RuntimeError(f"embedded images are missing student-export approval: {missing_manifest}")
    paths = [ROOT / path for path in sorted(embedded)]
    missing_files = [path for path in paths if not path.is_file()]
    if missing_files:
        raise RuntimeError(f"embedded student images are missing: {missing_files}")
    return paths


def quarto_anchor(heading: str) -> str:
    """Approximate Pandoc's automatic heading identifier for exported headings."""
    anchor = re.sub(r"[^\w\s.-]", "", heading.casefold(), flags=re.UNICODE)
    anchor = re.sub(r"\s+", "-", anchor.strip())
    anchor = re.sub(r"^[^a-z]+", "", anchor)
    return anchor or "section"


def convert_wikilinks(text: str, output_rel: str, mapping: dict[str, str]) -> str:
    matlab_sources: set[str] = set()
    for name in ("Visual Evidence Manifest.yml", "Uni Visual Evidence Manifest.yml"):
        manifest = ROOT / "01 Source Collections" / name
        if manifest.is_file():
            records = yaml.safe_load(manifest.read_text(encoding="utf-8"))
            matlab_sources.update(str(item["local_file"]) for item in records
                                  if item.get("kind") == "matlab_result")
    # Filter original private-file links before introducing public note links.
    # Applying this after wikilink conversion also removed valid public links.
    text = re.sub(r"(?<!!)\[([^\]]+)\]\(<?(?!https?:|#|mailto:)[^)>]+>?\)", r"\1", text)
    def image_repl(m: re.Match[str]) -> str:
        source, separator, alias = m.group(1).partition("|")
        source = source.strip()
        alt = alias.strip() if separator else Path(source).stem
        target = rel_target(output_rel, export_asset_rel(ROOT / source))
        safe_alt = alt.replace('"', "'")
        image_class = ".matlab-result " if source in matlab_sources else ""
        return f'![](<{target}>){{{image_class}fig-alt="{safe_alt}"}}'
    text = re.sub(r"!\[\[([^\]]+\.png(?:\|[^\]]+)?)\]\]", image_repl, text, flags=re.I)

    def link_repl(m: re.Match[str]) -> str:
        target, alias = m.group(1).strip(), (m.group(2) or m.group(1)).strip()
        # Obsidian escapes the alias separator inside tables as "\|"; drop the escape.
        target = target.rstrip("\\").strip()
        if target.startswith("#"):
            return f"[{alias}](#{quarto_anchor(target[1:])})"
        base, separator, heading = target.partition("#")
        fragment = f"#{quarto_anchor(heading)}" if separator else ""
        if base in mapping:
            return f"[{alias}]({rel_target(output_rel, mapping[base])}{fragment})"
        if base == "5G Abbreviation Database":
            return f"[{alias}]({rel_target(output_rel, 'abbreviations.qmd')}{fragment})"
        if base.endswith("spec-manifest.yml") or base == "Protocol/Rel-18/spec-manifest.yml":
            return f"[{alias}]({rel_target(output_rel, 'manifests/spec-manifest.yml')})"
        if base == "5G NR 2e Source Manifest":
            return f"[{alias}]({rel_target(output_rel, 'manifests/5g-nr-2e-source-manifest.qmd')})"
        return alias
    text = re.sub(r"(?<!!)\[\[([^\]|]+)(?:\|([^\]]+))?\]\]", link_repl, text)
    return text


def convert_protocol_pairs(text: str) -> str:
    """Keep ordinary Obsidian embeds; comments opt into a two-panel web layout."""
    state = "outside"
    output = []
    for line in text.splitlines():
        marker = line.strip()
        if marker == "<!-- protocol-pair:start -->":
            if state != "outside":
                raise ValueError("nested protocol pair")
            state = "source"
            output.append(":::: {.protocol-pair}\n\n::: {.protocol-panel}")
        elif marker == "<!-- protocol-pair:result -->":
            if state != "source":
                raise ValueError("protocol pair result without source")
            state = "result"
            output.append(":::\n\n::: {.protocol-panel}")
        elif marker == "<!-- protocol-pair:end -->":
            if state != "result":
                raise ValueError("protocol pair end without result")
            state = "outside"
            output.append(":::\n\n::::")
        else:
            output.append(line)
    if state != "outside":
        raise ValueError("unclosed protocol pair")
    return "\n".join(output) + "\n"


def convert_highlights(text: str) -> str:
    """Obsidian ==highlight== becomes a Pandoc span that the theme styles as a mark."""
    return re.sub(r"==([^=\n]+?)==", r"[\1]{.mark}", text)


def export_md(source: Path, output_rel: str, title: str, mapping: dict[str, str]) -> None:
    text, code = note_annotations.protect_code(strip_frontmatter(source.read_text(encoding="utf-8")))
    text = convert_protocol_pairs(convert_highlights(convert_wikilinks(convert_callouts(text), output_rel, mapping)))
    text = note_annotations.restore_code(text, code)
    text = localize_links(text, REPOSITORY, output_rel)
    text = re.sub(r"^# .+$", "", text, count=1, flags=re.M).lstrip()
    target = SOURCE / output_rel
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(f'---\ntitle: "{title}"\nformat:\n  html:\n    toc: true\n---\n\n{text}', encoding="utf-8")


def write_source_manifest(sources: dict[Path, str]) -> None:
    """Record public relative paths and the exact Markdown bytes used in a build."""
    records = [{"source": source.relative_to(ROOT).as_posix(),
                "qmd": output, "html": str(Path(output).with_suffix(".html")),
                "sha256": hashlib.sha256(source.read_bytes()).hexdigest()}
               for source, output in sources.items()]
    target = SOURCE / "manifests/note-sources.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(records, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def validate_rendered_site(sources: dict[Path, str]) -> None:
    """Reject a partial render or a missing local asset before changing the served site."""
    for output in sources.values():
        if not (SITE / Path(output).with_suffix(".html")).is_file():
            raise RuntimeError(f"missing rendered note: {output}")

    class Resources(HTMLParser):
        def __init__(self):
            super().__init__()
            self.links = []
            self.ids = set()

        def handle_starttag(self, tag, attrs):
            self.links.extend(value for key, value in attrs if key in {"src", "href"} and value)
            self.ids.update(value for key, value in attrs if key == "id" and value)

    parsed_pages = {}
    for page in SITE.rglob("*.html"):
        parser = Resources()
        parser.feed(page.read_text(encoding="utf-8"))
        parsed_pages[page.resolve()] = parser
    for page, parser in parsed_pages.items():
        for link in parser.links:
            parsed = urlsplit(link)
            if parsed.scheme or parsed.netloc:
                continue
            local = unquote(parsed.path)
            target = (SITE / local.lstrip("/") if local.startswith("/") else page.parent / local).resolve() if local else page
            if target.is_dir():
                target = target / "index.html"
            if not target.is_relative_to(SITE.resolve()):
                raise RuntimeError(f"broken local resource in {page.relative_to(SITE)}: {link}")
            if not target.exists() and resolve_asset(REPOSITORY, SITE, target.relative_to(SITE.resolve()).as_posix()) is None:
                raise RuntimeError(f"broken local resource in {page.relative_to(SITE)}: {link}")
            if parsed.fragment and target in parsed_pages and unquote(parsed.fragment) not in parsed_pages[target].ids:
                raise RuntimeError(f"broken local anchor in {page.relative_to(SITE)}: {link}")


def verify_input_hashes(hashes: dict[Path, str]) -> None:
    changed = [path for path, digest in hashes.items()
               if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != digest]
    if changed:
        raise RuntimeError(f"source changed during build; retry with saved files: {changed}")


def promote_build(stage: Path, destination: Path) -> None:
    """Install a checked render with rollback if any replacement fails."""
    if not (stage/'student-site/index.html').is_file():
        raise ValueError('A complete staged site is required before promotion')
    names = ("student-source", "student-site", "Saar-5G-NR-Teaching-Knowledge-Base.zip")
    previous = stage / "previous"
    previous.mkdir()
    installed = []
    backed_up = []
    try:
        for name in names:
            current = destination / name
            if current.exists():
                current.rename(previous / name)
                backed_up.append(name)
            if name != 'student-source' and (stage / name).exists():
                (stage / name).rename(current)
                installed.append(name)
    except Exception:
        for name in reversed(installed):
            (destination / name).rename(stage / name)
        for name in reversed(backed_up):
            (previous / name).rename(destination / name)
        raise


def abbreviation_json() -> str:
    """Rows of the abbreviation database as a compact JSON list for the lookup panel."""
    rows = []
    for line in (ROOT / "09 Abbreviation Database/5G Abbreviation Database.md").read_text(encoding="utf-8").splitlines():
        if not line.startswith("| ") or line.startswith("| ---") or line.startswith("| Abbreviation"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 4:
            continue
        rows.append({"a": cells[0], "t": cells[1], "e": cells[2], "l": cells[3]})
    return json.dumps(rows, ensure_ascii=False).replace("</", "<\\/")


def write_project(paths: list[Path], mapping: dict[str, str]) -> None:
    def items(scope: range) -> str:
        rows = []
        for p in paths:
            n = star_number(p)
            if n in scope:
                rows.append(f"          - href: {mapping[p.stem]}\n            text: \"{title_for(p)}\"")
        return "\n".join(rows)

    uni_rows = "\n".join(
        f"          - href: {mapping[p.stem]}\n            text: \"{title_for(p)}\"" for p in uni_notes())
    uni_section = ("      - section: Engineering Notes\n        contents:\n" + uni_rows) if uni_rows else ""
    has_protocols = len(verified_documents(REPOSITORY)) == len(records(REPOSITORY))
    protocol_target = PROTOCOL_ZIP if has_protocols else OFFICIAL_INDEX
    protocol_label = '3GPP protocols (ZIP)' if has_protocols else '3GPP official specifications'
    config = f'''project:
  type: website
  output-dir: ../student-site

website:
  title: "Saarland University 5G NR Teaching Knowledge Base"
  search: true
  page-footer:
    center: "Saarland University 5G NR Teaching Knowledge Base · Author: Shiyi Wang"
  sidebar:
    style: docked
    contents:
      - href: index.qmd
        text: Course Index
      - section: Book Chapters
        contents:
{items(range(1, 28))}
      - section: Core 3GPP Specifications
        contents:
{items(range(28, 38))}
{uni_section}
      - href: uni-index.qmd
        text: Engineering Index
      - href: abbreviations.qmd
        text: Abbreviations
      - section: References
        contents:
          - href: manifests/5g-nr-2e-source-manifest.qmd
            text: Textbook references
          - href: {protocol_target}
            text: {protocol_label}

format:
  html:
    theme: [cosmo, hallmark.scss]
    css: styles.css
    include-after-body: hallmark-tools.html
    toc: true
    code-copy: true
    html-math-method: mathjax
    link-external-newwindow: true

execute:
  freeze: true
'''
    (SOURCE / "_quarto.yml").write_text(config, encoding="utf-8")
    (SOURCE / "hallmark.scss").write_text(render_export_theme_scss(), encoding="utf-8")
    (SOURCE / "styles.css").write_text(render_export_css(), encoding="utf-8")
    # Inlined rather than linked: the pages sit at several directory depths,
    # and an inline block is depth-independent without extra resource copying.
    (SOURCE / "hallmark-tools.html").write_text(
        "<script>\nwindow.HM_ABBR = " + abbreviation_json() + ";\n</script>\n"
        "<script>\n" + render_export_js() + "\n</script>\n", encoding="utf-8")


def build_staged() -> None:
    paths = stars()
    if len(paths) != 37:
        raise RuntimeError(f"expected 37 Stars before export; found {len(paths)}")
    numbers = [star_number(path) for path in paths]
    if numbers != list(range(1, 38)):
        raise RuntimeError(f"expected Star numbers 1–37 before export; found {numbers}")
    required = [
        ROOT / "Course Index.md",
        ROOT / "Uni Engineering Index.md",
        ROOT / "09 Abbreviation Database/5G Abbreviation Database.md",
        ROOT / "01 Source Collections/5G NR 2e Source Manifest.md",
        REPOSITORY / "references/3gpp/spec-manifest.yml",
        REPOSITORY / "references/3gpp/specifications.json",
        REPOSITORY / "references/3gpp/specifications.py",
    ]
    missing = [path for path in required if not path.is_file()]
    if missing:
        raise RuntimeError(f"missing export inputs: {missing}")
    # Capture mutable manifests and source before approval and conversion.
    inputs = [*paths, *uni_notes(), *required, REPOSITORY / "LICENSE", EXPORT / "tokens.css", Path(__file__),
              EXPORT / "export_theme.py", EXPORT / "note_annotations.py", EXPORT / "approved-design.css",
              EXPORT / "local_assets.py",
              *(ROOT / "01 Source Collections").glob("*.yml"),
              *(ROOT / "01 Source Collections").glob("*.json")]
    hashes = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs}
    hashes.update({path: record['sha256'] for record, path in verified_documents(REPOSITORY)})
    images = approved_star_images()
    hashes.update({path: hashlib.sha256(path.read_bytes()).hexdigest() for path in images})
    # Recheck approval after hashes are captured to close the approval/capture interval.
    approved_star_images()
    map_count = sum("Knowledge Maps" in image.parts for image in images)
    if map_count != 37:
        raise RuntimeError(f"expected 37 embedded knowledge maps before export; found {map_count}")
    quarto = shutil.which("quarto")
    if not quarto:
        raise RuntimeError("Quarto executable not found on PATH")
    reset()
    mapping = {p.stem: output_for(p) for p in paths}
    mapping.update({p.stem: output_for(p) for p in uni_notes()})
    mapping.update({"Course Index": "index.qmd", "Uni Engineering Index": "uni-index.qmd"})
    write_project(paths, mapping)
    export_md(ROOT / "Course Index.md", "index.qmd", title_for(ROOT / "Course Index.md"), mapping)
    export_md(ROOT / "Uni Engineering Index.md", "uni-index.qmd", title_for(ROOT / "Uni Engineering Index.md"), mapping)
    for p in paths:
        export_md(p, mapping[p.stem], title_for(p), mapping)
    for p in uni_notes():
        export_md(p, mapping[p.stem], title_for(p), mapping)
    export_md(ROOT / "09 Abbreviation Database/5G Abbreviation Database.md", "abbreviations.qmd", title_for(ROOT / "09 Abbreviation Database/5G Abbreviation Database.md"), mapping)
    export_md(ROOT / "01 Source Collections/5G NR 2e Source Manifest.md", "manifests/5g-nr-2e-source-manifest.qmd", title_for(ROOT / "01 Source Collections/5G NR 2e Source Manifest.md"), mapping)
    source_map = {p: output_for(p) for p in [*paths, *uni_notes()]}
    source_map.update({ROOT / "Course Index.md": "index.qmd", ROOT / "Uni Engineering Index.md": "uni-index.qmd",
                       ROOT / "09 Abbreviation Database/5G Abbreviation Database.md": "abbreviations.qmd",
                       ROOT / "01 Source Collections/5G NR 2e Source Manifest.md": "manifests/5g-nr-2e-source-manifest.qmd"})
    write_source_manifest(source_map)
    shutil.copy2(REPOSITORY / "references/3gpp/spec-manifest.yml", SOURCE / "manifests/spec-manifest.yml")
    for image in images:
        target = SOURCE / export_asset_rel(image)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(image, target)
        if hashlib.sha256(target.read_bytes()).hexdigest() != hashes[image]:
            raise RuntimeError(f"source changed during build: {image}")
    copy_documents(REPOSITORY, SOURCE)
    has_protocols = len(verified_documents(REPOSITORY)) == len(records(REPOSITORY))
    if has_protocols:
        copy_protocol_archive(REPOSITORY, SOURCE)
    subprocess.run([quarto, "render"], cwd=SOURCE, check=True)
    # Manifests are downloadable resources, independent of Quarto's resource inference.
    shutil.copytree(SOURCE / "manifests", SITE / "manifests", dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns("*.qmd"))
    local_pdfs = copy_documents(REPOSITORY, SITE)
    if has_protocols:
        local_pdfs.add(copy_protocol_archive(REPOSITORY, SITE))
    validate_rendered_site(source_map)
    verify_input_hashes(hashes)
    forbidden = {".pdf", ".ppt", ".pptx", ".ipynb", ".docx", ".zip"}
    leaked = [p for p in SITE.rglob("*") if p.is_file() and p.suffix.casefold() in forbidden and p not in local_pdfs]
    if leaked:
        raise RuntimeError(f"private binary source leaked: {leaked}")
    assets = {export_asset_rel(image): image for image in images}
    assets.update({path.relative_to(SITE).as_posix(): REPOSITORY/path.relative_to(SITE)
                   for path in local_pdfs})
    compact_assets(REPOSITORY, SITE, assets)
    validate_rendered_site(source_map)
    print("validated", len(paths), "Star pages and", len(uni_notes()), "Uni pages")


def main() -> None:
    global SOURCE, SITE, ZIP_BASE
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', action='store_true', help='Also create a portable reading ZIP')
    args = parser.parse_args()
    previous_paths = SOURCE, SITE, ZIP_BASE
    # Quarto excludes input below hidden directory components from project discovery.
    stage = Path(tempfile.mkdtemp(prefix="build-staging-", dir=EXPORT))
    SOURCE, SITE = stage / "student-source", stage / "student-site"
    ZIP_BASE = stage / "Saar-5G-NR-Teaching-Knowledge-Base"
    try:
        build_staged()
        if args.archive:
            reading_export(REPOSITORY, SITE, str(ZIP_BASE)+'.zip')
        promote_build(stage, EXPORT)
    except Exception:
        print(f"Build was not installed. Diagnostic files: {stage}", file=sys.stderr)
        raise
    else:
        shutil.rmtree(stage)
        print("built source-derived website at", EXPORT / "student-site")
    finally:
        SOURCE, SITE, ZIP_BASE = previous_paths


if __name__ == "__main__":
    main()
