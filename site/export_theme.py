"""Reading theme for the Saarland University 5G NR Teaching Knowledge Base.

Design references, read in full before this file was written:
  .hallmark/references/dell-1996.DESIGN.md  — palette, the three font families, hard black chrome
  .hallmark/references/apple.DESIGN.md      — reading measure, vertical rhythm, quiet figure plates

What is taken from Dell 1996: the white canvas inside a black page frame, Dell red as the single
attention colour, classic link blue, Arial Black display headings, Helvetica bold upper-case labels,
Times New Roman body copy, square corners, one-pixel black hairlines, no soft shadows.
What is taken from Apple: a centred reading column of about 66 characters, 17–18 px body with 1.5
leading, 64–96 px of air between sections, images on a parchment plate with at least 40 px of air,
captions in a small quiet sans, and a slim black bar at the top of the page.
"""
from __future__ import annotations

import re
from pathlib import Path


def render_export_tokens() -> str:
    """Design tokens shared by the site, the preview builder and the figure tools."""
    return Path(__file__).with_name("tokens.css").read_text(encoding="utf-8")


def render_export_theme_scss() -> str:
    """Resolve Bootstrap's compile-time defaults from the light tokens."""
    tokens = render_export_tokens()
    values: dict[str, str] = {}
    for key, value in re.findall(r"--([\w-]+):\s*([^;]+);", tokens):
        values.setdefault(key, value.strip())
    settings = {
        "font-family-sans-serif": "font-body", "font-family-serif": "font-body",
        "font-family-monospace": "font-mono", "body-bg": "canvas",
        "body-color": "body", "primary": "accent", "link-color": "link",
        "border-color": "hairline", "font-size-root": "text-root",
        "headings-color": "ink", "code-color": "t-structure-deep",
        "code-bg": "t-structure-wash", "pre-bg": "canvas-elevated",
        "table-border-color": "hairline", "navbar-bg": "canvas",
        "navbar-fg": "ink",
    }
    lines = ["/*-- scss:defaults --*/"]
    lines.extend(f"${key}: {values[token]};" for key, token in settings.items())
    lines.extend(["$headings-font-weight: 700;", "/*-- scss:rules --*/",
                  ".btn, .form-control { border-radius: var(--radius-input); }"])
    return "\n".join(lines) + "\n"


def render_export_css() -> str:
    return render_export_tokens() + "\n" + CSS + "\n" + Path(__file__).with_name("approved-design.css").read_text(encoding="utf-8")


CSS = r"""
/* ══════════════════════════════════════════════════════════════════
   PAGE GROUND — Dell frame, Apple air
   ══════════════════════════════════════════════════════════════════ */

html { font-size: var(--text-root); overflow-x: clip; }
html, body { background: var(--frame-ink); }
body {
  color: var(--body);
  font-family: var(--font-body);
  line-height: var(--lh-read);
  border: var(--frame-width) solid var(--frame-ink);
  background: var(--canvas);
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
}
#quarto-content { background: var(--canvas); }
*:focus-visible { outline: 2px solid var(--focus); outline-offset: 2px; }
::selection { background: var(--yellow); color: var(--ink); }

a { color: var(--link); text-decoration: underline; text-underline-offset: 0.14em; text-decoration-thickness: 1px; }
a:hover, a:focus-visible { color: var(--accent); }

/* ══════════════════════════════════════════════════════════════════
   TOP BAR — the Dell black banner with the chapter code in red
   ══════════════════════════════════════════════════════════════════ */

#hm-banner {
  display: flex; align-items: center; gap: var(--space-xs);
  margin: 0 0 var(--space-md);
  padding: 0 var(--space-xs) 0 0;
  background: var(--frame-ink);
  color: #ffffff;
  min-height: 44px;
}
#hm-banner .hm-brand {
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700;
  text-transform: uppercase; letter-spacing: 0.04em; color: #ffffff;
  padding: 0 var(--space-xs); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
#hm-banner .hm-code {
  margin-inline-start: auto;
  font-family: var(--font-label); font-size: var(--text-base); font-weight: 700;
  color: var(--accent); white-space: nowrap;
}

#hm-tools { display: inline-flex; align-items: stretch; margin: 0; }
.hm-btn {
  appearance: none; background: var(--frame-ink); border: none; border-inline-end: 1px solid #3a3a3a;
  color: #ffffff; font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700;
  text-transform: uppercase; line-height: 1; padding: 0 12px; min-height: 44px; min-width: 44px; cursor: pointer;
}
.hm-btn:hover, .hm-btn:focus-visible { background: var(--accent); color: #ffffff; }
.hm-sep { display: none; }

/* ══════════════════════════════════════════════════════════════════
   READING COLUMN — Apple measure and rhythm
   ══════════════════════════════════════════════════════════════════ */

main.content { padding-block: 0 var(--space-xxl); font-size: calc(var(--text-base) * var(--reading-scale)); }
main.content > p, main.content section > p,
main.content section > ul, main.content section > ol, main.content > ul, main.content > ol,
main.content section > blockquote, main.content > dl, main.content section > dl { max-width: var(--measure); }
main.content p { margin-block: 0 var(--space-xs); }
main.content li { margin-block: 0 var(--space-xxxs); }
main.content ul, main.content ol { padding-inline-start: 1.4em; }
main.content strong { font-weight: 700; color: var(--ink); }

.quarto-title-breadcrumbs, .quarto-page-breadcrumbs {
  font-family: var(--font-label); font-size: var(--text-xs); text-transform: uppercase; letter-spacing: 0.04em;
  color: var(--muted); margin-block-end: var(--space-xs);
}
.quarto-title-breadcrumbs a, .quarto-page-breadcrumbs a { color: var(--muted); text-decoration: none; }

#title-block-header { margin-block-end: var(--space-md); }
#title-block-header .title, main.content > h1:first-child {
  font-family: var(--font-display);
  font-size: var(--text-title);
  font-weight: 900;
  line-height: var(--lh-display);
  letter-spacing: 0;
  color: var(--ink);
  margin: 0 0 var(--space-xs);
  padding-block-end: var(--space-xs);
  border-block-end: 3px solid var(--frame-ink);
  max-width: none;
}
#hm-readtime {
  font-family: var(--font-label); font-size: var(--text-xs); color: var(--muted);
  text-transform: uppercase; letter-spacing: 0.04em; margin: 0 0 var(--space-lg);
}

/* Headings: Dell's stencil display for H2, Helvetica caps for H3/H4 */
main.content h2 {
  font-family: var(--font-display);
  font-size: var(--text-xl);
  font-weight: 900;
  line-height: var(--lh-display);
  color: var(--ink);
  margin: var(--space-xl) 0 var(--space-xs);
  padding-block-end: var(--space-xxs);
  border-block-end: 2px solid var(--frame-ink);
  max-width: none;
}
main.content h3 {
  font-family: var(--font-label); font-size: var(--text-md); font-weight: 700; text-transform: uppercase;
  letter-spacing: 0.02em; color: var(--ink); margin: var(--space-md) 0 var(--space-xxs);
}
main.content h4, main.content h5 {
  font-family: var(--font-label); font-size: var(--text-sm); font-weight: 700; text-transform: uppercase;
  letter-spacing: 0.04em; color: var(--body-muted); margin: var(--space-sm) 0 var(--space-xxs);
}
main.content h1, main.content h2, main.content h3, main.content h4 { overflow-wrap: anywhere; }

/* Bold leads inside prose: Helvetica caps labels, red for the section purpose */
main.content p > strong:first-child {
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700;
  text-transform: uppercase; letter-spacing: 0.06em; color: var(--body-muted); margin-inline-end: 0.35em;
}
main.content p[data-hm-lead="purpose"] {
  max-width: var(--measure); border-inline-start: 6px solid var(--t-structure); background: var(--t-structure-wash);
  padding: var(--space-xxs) var(--space-xs); margin-block: var(--space-xs) var(--space-sm);
}
main.content p[data-hm-lead="purpose"] > strong:first-child { color: var(--t-structure-deep); }
main.content p[data-hm-lead="stage"] { display: none; }
main.content p[data-hm-lead="question"] {
  border-inline-start: var(--rule-tint) solid var(--t-insight); padding-inline-start: var(--space-xs); margin-block: var(--space-sm) var(--space-xxs);
}
main.content p[data-hm-lead="question"] > strong:first-child { color: var(--t-insight-deep); }
main.content p[data-hm-lead="answer"] {
  border-inline-start: var(--rule-tint) solid var(--t-structure); background: var(--t-structure-wash);
  padding: var(--space-xxs) var(--space-xs); margin-block: 0 var(--space-sm);
}
main.content p[data-hm-lead="answer"] > strong:first-child { color: var(--t-structure-deep); }

/* Obsidian ==highlight== : Dell sticker yellow */
main.content .mark, main.content mark { background: var(--yellow); color: var(--annotation-ink); padding: 0 0.15em; }

/* ══════════════════════════════════════════════════════════════════
   CALLOUTS — the ribbon card at reading volume
   white title bar, black hairline, tint rule, ≤ 9 % wash
   ══════════════════════════════════════════════════════════════════ */

main.content div.callout {
  border: 1px solid var(--frame-ink);
  border-inline-start: 6px solid var(--hairline-strong);
  border-radius: 0;
  background: var(--canvas);
  padding: 0;
  margin-block: var(--space-sm);
  max-width: var(--measure);
}
main.content div.callout .callout-header {
  display: flex; align-items: center; gap: var(--space-xxs);
  background: var(--hairline);
  border: none; border-block-end: 1px solid var(--frame-ink);
  padding: 5px 12px;
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700;
  text-transform: uppercase; letter-spacing: 0.04em; color: var(--ink);
}
main.content div.callout .callout-header[data-hm-source]::before {
  content: attr(data-hm-source); flex: none; background: var(--ink); color: #ffffff;
  font-size: 10px; letter-spacing: 0.1em; padding: 3px 6px; line-height: 1;
}
main.content div.callout .callout-body, main.content div.callout .callout-body-container {
  background: none; padding: 12px 16px; font-size: var(--text-base);
}
main.content div.callout .callout-body > :last-child { margin-block-end: 0; }
main.content div.callout.callout-style-default > div.callout-header { border-block-end: 1px solid var(--frame-ink); }
main.content div.callout .callout-icon::before { display: none; }
main.content div.callout .callout-title-container { margin: 0; flex: 1; }
main.content div.callout[data-hm-kind="spec"] { border-inline-start-color: var(--t-spec); }
main.content div.callout[data-hm-kind="spec"] .callout-header { background: var(--t-spec); color: #ffffff; }
main.content div.callout[data-hm-kind="spec"] .callout-header[data-hm-source]::before { background: var(--t-spec-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="spec"] .callout-body-container, main.content div.callout[data-hm-kind="spec"] .callout-body { background: var(--t-spec-wash); }
main.content div.callout[data-hm-kind="book"] { border-inline-start-color: var(--t-book); }
main.content div.callout[data-hm-kind="book"] .callout-header { background: var(--t-book); color: var(--ink); }
main.content div.callout[data-hm-kind="book"] .callout-header[data-hm-source]::before { background: var(--t-book-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="book"] .callout-body-container, main.content div.callout[data-hm-kind="book"] .callout-body { background: var(--t-book-wash); }
main.content div.callout[data-hm-kind="engineering"] { border-inline-start-color: var(--t-engineering); }
main.content div.callout[data-hm-kind="engineering"] .callout-header { background: var(--t-engineering); color: var(--ink); }
main.content div.callout[data-hm-kind="engineering"] .callout-header[data-hm-source]::before { background: var(--t-engineering-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="engineering"] .callout-body-container, main.content div.callout[data-hm-kind="engineering"] .callout-body { background: var(--t-engineering-wash); }
main.content div.callout[data-hm-kind="insight"] { border-inline-start-color: var(--t-insight); }
main.content div.callout[data-hm-kind="insight"] .callout-header { background: var(--t-insight); color: var(--ink); }
main.content div.callout[data-hm-kind="insight"] .callout-header[data-hm-source]::before { background: var(--t-insight-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="insight"] .callout-body-container, main.content div.callout[data-hm-kind="insight"] .callout-body { background: var(--t-insight-wash); }
main.content div.callout[data-hm-kind="search"] { border-inline-start-color: var(--t-search); }
main.content div.callout[data-hm-kind="search"] .callout-header { background: var(--t-search); color: var(--ink); }
main.content div.callout[data-hm-kind="search"] .callout-header[data-hm-source]::before { background: var(--t-search-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="search"] .callout-body-container, main.content div.callout[data-hm-kind="search"] .callout-body { background: var(--t-search-wash); }
main.content div.callout[data-hm-kind="structure"] { border-inline-start-color: var(--t-structure); }
main.content div.callout[data-hm-kind="structure"] .callout-header { background: var(--t-structure); color: var(--ink); }
main.content div.callout[data-hm-kind="structure"] .callout-header[data-hm-source]::before { background: var(--t-structure-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="structure"] .callout-body-container, main.content div.callout[data-hm-kind="structure"] .callout-body { background: var(--t-structure-wash); }
main.content div.callout[data-hm-kind="figure"] { border-inline-start-color: var(--t-figure); }
main.content div.callout[data-hm-kind="figure"] .callout-header { background: var(--t-figure); color: var(--ink); }
main.content div.callout[data-hm-kind="figure"] .callout-header[data-hm-source]::before { background: var(--t-figure-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="figure"] .callout-body-container, main.content div.callout[data-hm-kind="figure"] .callout-body { background: var(--t-figure-wash); }
main.content div.callout[data-hm-kind="trace"] { border-inline-start-color: var(--t-trace); }
main.content div.callout[data-hm-kind="trace"] .callout-header { background: var(--t-trace); color: var(--ink); }
main.content div.callout[data-hm-kind="trace"] .callout-header[data-hm-source]::before { background: var(--t-trace-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="trace"] .callout-body-container, main.content div.callout[data-hm-kind="trace"] .callout-body { background: var(--t-trace-wash); }
main.content div.callout[data-hm-kind="warn"] { border-inline-start-color: var(--t-warn); }
main.content div.callout[data-hm-kind="warn"] .callout-header { background: var(--t-warn); color: var(--ink); }
main.content div.callout[data-hm-kind="warn"] .callout-header[data-hm-source]::before { background: var(--t-warn-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="warn"] .callout-body-container, main.content div.callout[data-hm-kind="warn"] .callout-body { background: var(--t-warn-wash); }
main.content div.callout[data-hm-kind="matlab"] { border-inline-start-color: var(--t-matlab); }
main.content div.callout[data-hm-kind="matlab"] .callout-header { background: var(--t-matlab); color: var(--ink); }
main.content div.callout[data-hm-kind="matlab"] .callout-header[data-hm-source]::before { background: var(--t-matlab-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="matlab"] .callout-body-container, main.content div.callout[data-hm-kind="matlab"] .callout-body { background: var(--t-matlab-wash); }
main.content div.callout[data-hm-kind="result"] { border-inline-start-color: var(--t-result); }
main.content div.callout[data-hm-kind="result"] .callout-header { background: var(--t-result); color: var(--ink); }
main.content div.callout[data-hm-kind="result"] .callout-header[data-hm-source]::before { background: var(--t-result-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="result"] .callout-body-container, main.content div.callout[data-hm-kind="result"] .callout-body { background: var(--t-result-wash); }
main.content div.callout[data-hm-kind="failure"] { border-inline-start-color: var(--t-failure); }
main.content div.callout[data-hm-kind="failure"] .callout-header { background: var(--t-failure); color: var(--ink); }
main.content div.callout[data-hm-kind="failure"] .callout-header[data-hm-source]::before { background: var(--t-failure-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="failure"] .callout-body-container, main.content div.callout[data-hm-kind="failure"] .callout-body { background: var(--t-failure-wash); }
main.content div.callout[data-hm-kind="tradeoff"] { border-inline-start-color: var(--t-tradeoff); }
main.content div.callout[data-hm-kind="tradeoff"] .callout-header { background: var(--t-tradeoff); color: var(--ink); }
main.content div.callout[data-hm-kind="tradeoff"] .callout-header[data-hm-source]::before { background: var(--t-tradeoff-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="tradeoff"] .callout-body-container, main.content div.callout[data-hm-kind="tradeoff"] .callout-body { background: var(--t-tradeoff-wash); }
main.content div.callout[data-hm-kind="parameter"] { border-inline-start-color: var(--t-parameter); }
main.content div.callout[data-hm-kind="parameter"] .callout-header { background: var(--t-parameter); color: var(--ink); }
main.content div.callout[data-hm-kind="parameter"] .callout-header[data-hm-source]::before { background: var(--t-parameter-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="parameter"] .callout-body-container, main.content div.callout[data-hm-kind="parameter"] .callout-body { background: var(--t-parameter-wash); }
main.content div.callout[data-hm-kind="supp"] { border-inline-start-color: var(--t-supp); }
main.content div.callout[data-hm-kind="supp"] .callout-header { background: var(--t-supp); color: var(--ink); }
main.content div.callout[data-hm-kind="supp"] .callout-header[data-hm-source]::before { background: var(--t-supp-deep); color: #ffffff; }
main.content div.callout[data-hm-kind="supp"] .callout-body-container, main.content div.callout[data-hm-kind="supp"] .callout-body { background: var(--t-supp-wash); }

/* ══════════════════════════════════════════════════════════════════
   FIGURES — Apple plates: parchment ground, air, quiet caption
   ══════════════════════════════════════════════════════════════════ */

.quarto-figure, main.content p:has(> img:only-child) { margin: var(--space-md) 0 var(--space-xxs); max-width: none; }
.quarto-figure img, main.content p > img {
  display: block; max-width: min(100%, calc(var(--measure) * 0.86)); height: auto; margin-inline: auto; cursor: zoom-in;
  background: var(--figure-paper);
  padding: var(--space-sm);
  box-sizing: border-box;
  border: 1px solid var(--hairline);
}
html[data-hm-theme="dark"] .quarto-figure img, html[data-hm-theme="dark"] main.content p > img { border-color: var(--hairline-strong); }
.quarto-figure figcaption, .figure-caption { display: none; }
main.content p[data-hm-caption] {
  font-family: var(--font-label); font-size: var(--text-sm); line-height: var(--lh-normal);
  color: var(--body-muted); margin: 0 auto var(--space-lg); padding: 0 var(--space-xxxs); max-width: calc(var(--measure) * 0.86);
}
main.content p[data-hm-caption] em { font-style: normal; }
main.content p[data-hm-caption]::before { content: "Figure"; font-weight: 700; color: var(--ink); text-transform: uppercase; letter-spacing: 0.04em; margin-inline-end: 0.6em; font-size: var(--text-xs); }

/* Fill expands the reading area; a standalone experimental plot stays bounded. */
html[data-hm-width="fill"] main.content img.matlab-result:not(.protocol-panel img) {
  width: auto; height: auto; max-width: min(100%, 840px);
  max-height: min(520px, 60vh); object-fit: contain;
}
html[data-hm-width="fill"] main.content .quarto-figure:has(img.matlab-result):not(.protocol-panel .quarto-figure) + p[data-hm-caption],
html[data-hm-width="fill"] main.content p:has(> img.matlab-result):not(.protocol-panel p) + p[data-hm-caption] {
  max-width: min(100%, 840px);
}

/* Exact protocol excerpt beside its experimental result. Existing tokens apply. */
main.content .protocol-pair { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: var(--space-sm); margin-block: var(--space-md) var(--space-lg); }
main.content .protocol-panel { min-width: 0; }
main.content .protocol-panel .quarto-figure, main.content .protocol-panel p:has(> img:only-child) { margin: 0 0 var(--space-xxs); }
main.content .protocol-panel img { width: 100%; max-width: 100%; height: 320px; object-fit: contain; padding: var(--space-xxs); }
main.content .protocol-panel p[data-hm-caption] { max-width: 100%; margin-bottom: 0; }
@media (max-width: 767px) {
  main.content .protocol-pair { grid-template-columns: minmax(0, 1fr); }
  main.content .protocol-panel img { height: auto; }
}

/* ══════════════════════════════════════════════════════════════════
   TABLES, CODE, MATH — Dell data table chrome
   ══════════════════════════════════════════════════════════════════ */

main.content table { border-collapse: collapse; width: 100%; margin-block: var(--space-xs) var(--space-md); font-size: var(--text-sm); }
main.content thead th {
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em;
  color: var(--ink); background: var(--canvas); border-block-end: 2px solid var(--frame-ink); padding: 8px 10px; text-align: start; vertical-align: bottom;
}
main.content tbody td { padding: 8px 10px; border-block-end: 1px solid var(--hairline); vertical-align: top; }
main.content tbody tr:last-child td { border-block-end: 1px solid var(--frame-ink); }
main.content tbody tr:hover { background: var(--shade); }
main.content table code { white-space: nowrap; }
main.content .table-responsive, main.content div:has(> table) { overflow-x: auto; max-width: 100%; }

main.content code:not(pre code) {
  font-family: var(--font-mono); font-size: 0.86em; color: var(--t-structure-deep); background: var(--t-structure-wash); padding: 0.08em 0.3em;
}
main.content pre {
  background: var(--canvas-elevated); border: 1px solid var(--frame-ink); padding: var(--space-xs);
  font-size: var(--text-sm); overflow-x: auto; margin-block: var(--space-xs) var(--space-sm); max-width: none;
}
main.content pre code { font-family: var(--font-mono); background: none; padding: 0; color: var(--body); }
mjx-container[display="true"] { max-width: 100%; overflow-x: auto; overflow-y: hidden; padding-block: var(--space-xxxs); }
main.content hr { border: 0; border-block-start: 1px solid var(--frame-ink); margin-block: var(--space-lg); }
main.content blockquote { border-inline-start: 4px solid var(--hairline); padding-inline-start: var(--space-xs); color: var(--body-muted); margin: 0 0 var(--space-xs); }

/* ══════════════════════════════════════════════════════════════════
   SIDEBAR — Dell icon-label nav: Helvetica caps, black rules, red active
   ══════════════════════════════════════════════════════════════════ */

#quarto-sidebar, .sidebar.sidebar-navigation {
  background: var(--canvas);
  border-inline-end: 1px solid var(--frame-ink) !important;
  transition: transform var(--dur-rail) var(--ease-out), opacity var(--dur-rail) var(--ease-out);
}
#quarto-sidebar .sidebar-menu-container { min-width: 0; white-space: normal; }
.sidebar-title, .sidebar-title a {
  font-family: var(--font-display); font-size: var(--text-md); font-weight: 900; line-height: var(--lh-display);
  color: var(--ink) !important; text-decoration: none;
}
.sidebar-item-text { font-family: var(--font-label); font-size: var(--text-sm); line-height: 1.3; color: var(--body); overflow-wrap: anywhere; }
.sidebar-item-section > .sidebar-item-container > .sidebar-item-text {
  font-size: var(--text-xs); font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--ink);
  border-block-end: 1px solid var(--frame-ink); padding-block-end: 4px; margin-block-start: var(--space-xs);
}
.sidebar-item .sidebar-item-text:hover, .sidebar-item .sidebar-item-text:focus-visible { color: var(--accent); }
.sidebar-item-text.active, .sidebar-link.active, a.sidebar-item-text[aria-current="page"] {
  color: var(--accent) !important; font-weight: 700; box-shadow: inset 3px 0 0 var(--accent); padding-inline-start: var(--space-xxs);
}
#quarto-search .aa-DetachedSearchButton, .sidebar-search .aa-DetachedSearchButton, .aa-Autocomplete .aa-Form {
  border: 1px solid var(--frame-ink) !important; border-radius: 0 !important; background: var(--canvas) !important; color: var(--body) !important;
}
.aa-Panel, .aa-Panel * { border-radius: 0 !important; }
.aa-ItemContentTitle mark, .aa-ItemContentDescription mark { background: var(--yellow); color: var(--ink); }
.aa-Item[aria-selected="true"] { background: var(--shade) !important; }

/* Right margin: section list and lookup, pinned */
#TOC { font-family: var(--font-label); font-size: var(--text-xs); }
#TOC > h2, .toc-title { font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--ink); border-block-end: 1px solid var(--frame-ink); padding-block-end: 4px; }
#TOC a, .sidebar nav[role="doc-toc"] ul > li > a { color: var(--body-muted); text-decoration: none; line-height: 1.35; }
#TOC a.active, .sidebar nav[role="doc-toc"] ul > li > a.active { color: var(--accent); font-weight: 700; border-inline-start: 2px solid var(--accent); }
@media (min-width: 992px) {
  #quarto-margin-sidebar, #quarto-margin-sidebar.rollup, #quarto-margin-sidebar.collapse {
    display: block !important; position: sticky; top: var(--space-md);
    max-height: calc(100vh - var(--space-md) - var(--space-xs)); overflow-y: auto; padding-block-end: var(--space-xs);
  }
  #quarto-margin-sidebar > * { opacity: 1 !important; pointer-events: auto !important; overflow: visible !important; }
  #quarto-toc-toggle, .quarto-sidebar-toggle { display: none !important; }
}

/* ══════════════════════════════════════════════════════════════════
   READING TOOLS — square, black, Helvetica
   ══════════════════════════════════════════════════════════════════ */

#hm-progress { position: fixed; top: 0; left: 0; height: 3px; width: 0; background: var(--accent); z-index: 1200; transition: width 90ms linear; }

#hm-rail-toggle {
  position: fixed; top: 50%; z-index: 1202; transform: translateY(-50%);
  background: var(--canvas); border: 1px solid var(--frame-ink); border-inline-start: none; color: var(--ink);
  cursor: pointer; padding: var(--space-xs) 4px; font-size: 12px; line-height: 1;
  transition: inset-inline-start var(--dur-rail) var(--ease-out);
}
#hm-rail-toggle:hover, #hm-rail-toggle:focus-visible { background: var(--accent); color: #ffffff; }
body.hm-rail-collapsed #quarto-sidebar { transform: translateX(-102%); opacity: 0; pointer-events: none; }
#hm-rail-grip { position: fixed; inset-block: 0; width: 10px; margin-inline-start: -5px; z-index: 1202; cursor: col-resize; background: transparent; }
#hm-rail-grip::after { content: ""; position: absolute; inset-block: 0; inset-inline-start: 4px; width: 2px; background: transparent; transition: background var(--dur-short) var(--ease-out); }
#hm-rail-grip:hover::after, body.hm-rail-dragging #hm-rail-grip::after { background: var(--accent); }
body.hm-rail-dragging { cursor: col-resize; user-select: none; }
body.hm-rail-dragging #quarto-sidebar { transition: none; }
body.hm-rail-collapsed #hm-rail-grip { display: none; }

@media (min-width: 992px) {
  body.hm-rail-collapsed #quarto-content.page-columns {
    grid-template-columns:
      [screen-start] 1.5rem [screen-start-inset page-start] 0px [page-start-inset] 0px [body-start-outset] 0px [body-start] 0px
      [body-content-start] minmax(0, 1fr) [body-content-end] 1.5rem [body-end] 3rem [body-end-outset] 6rem [page-end-inset] 3rem
      [page-end] 0px [screen-end-inset] 1.5rem [screen-end] !important;
  }
  html[data-hm-rail-w] body.docked:not(.hm-rail-collapsed) #quarto-content.page-columns {
    grid-template-columns:
      [screen-start] 0px [screen-start-inset page-start] var(--hm-rail-w, 225px) [page-start-inset] 0px [body-start-outset] 0px [body-start] 1.5em
      [body-content-start] minmax(0, 1fr) [body-content-end] 1.5em [body-end] 50px [body-end-outset] minmax(50px, 100px) [page-end-inset] 50px
      [page-end] 0px [screen-end-inset] 1.5em [screen-end] !important;
  }
}

#hm-top {
  position: fixed; bottom: var(--space-xs); right: var(--space-xs); z-index: 1201;
  background: var(--frame-ink); color: #ffffff; border: none;
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em;
  padding: 10px 14px; cursor: pointer; opacity: 0; pointer-events: none; transition: opacity var(--dur-short) var(--ease-out);
}
#hm-top.hm-show { opacity: 1; pointer-events: auto; }
#hm-top:hover, #hm-top:focus-visible { background: var(--accent); }

#hm-keys { position: fixed; inset: 0; z-index: 1300; display: none; place-items: center; background: var(--overlay); }
#hm-keys.hm-show { display: grid; }
#hm-keys .hm-sheet { background: var(--canvas); border: 2px solid var(--frame-ink); padding: var(--space-sm); min-width: min(380px, 90vw); }
#hm-keys h2 { font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--ink); margin: 0 0 var(--space-xs); border: none; padding: 0; }
#hm-keys dl { display: grid; grid-template-columns: auto 1fr; gap: var(--space-xxs) var(--space-xs); margin: 0; }
#hm-keys dt { font-family: var(--font-mono); color: var(--accent-deep); font-weight: 600; }
#hm-keys dd { margin: 0; color: var(--body-muted); font-size: var(--text-sm); font-family: var(--font-label); }

#hm-chapter-nav { display: flex; gap: var(--space-xs); justify-content: space-between; margin-block-start: var(--space-xl); padding-block-start: var(--space-sm); border-block-start: 2px solid var(--frame-ink); max-width: none; }
.hm-navlink { display: flex; flex-direction: column; gap: 2px; text-decoration: none; color: var(--ink); max-width: 48%; }
.hm-navlink .hm-dir { font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--accent); }
.hm-navlink .hm-title { font-family: var(--font-label); font-size: var(--text-sm); font-weight: 700; }
.hm-navlink.hm-next { text-align: end; margin-inline-start: auto; }
.hm-navlink:hover .hm-title { color: var(--accent); }

/* Abbreviation lookup: a small Dell text-input card */
#hm-abbr-btn {
  position: fixed; top: 50%; right: 0; z-index: 1202; transform: translateY(-50%); writing-mode: vertical-rl;
  background: var(--canvas); border: 1px solid var(--frame-ink); border-right: none; color: var(--ink);
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em;
  padding: var(--space-xs) 5px; cursor: pointer;
}
#hm-abbr-btn:hover, #hm-abbr-btn:focus-visible, #hm-abbr-btn[aria-expanded="true"] { background: var(--accent); color: #ffffff; }
#hm-abbr {
  position: fixed; top: 56px; right: var(--space-xs); width: min(320px, calc(100vw - 2 * var(--space-xs))); max-height: min(60vh, 520px);
  z-index: 1203; display: none; flex-direction: column; background: var(--canvas); border: 1px solid var(--frame-ink);
}
#hm-abbr.hm-show { display: flex; }
#hm-abbr.hm-inline { position: static; display: flex; width: auto; max-height: none; margin-block-start: var(--space-sm); }
#hm-abbr.hm-inline ol { max-height: 40vh; }
#hm-abbr header { display: flex; align-items: center; gap: var(--space-xxs); padding: 4px var(--space-xxs); border-block-end: 1px solid var(--frame-ink); background: var(--canvas); }
#hm-abbr header h2 { flex: 1; margin: 0; padding: 0; border: none; font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--ink); }
#hm-abbr header .hm-btn { background: var(--canvas); color: var(--ink); min-height: 28px; border: none; }
#hm-abbr input {
  margin: var(--space-xxs); padding: 6px 9px; width: calc(100% - 2 * var(--space-xxs)); box-sizing: border-box;
  font-family: var(--font-mono); font-size: var(--text-sm); color: var(--ink); background: var(--canvas); border: 1px solid var(--frame-ink); border-radius: 0;
}
#hm-abbr input:focus { outline: none; border-color: var(--accent); box-shadow: inset 0 0 0 1px var(--accent); }
#hm-abbr .hm-abbr-hint { margin: 0 var(--space-xxs) var(--space-xxs); font-size: var(--text-xs); color: var(--muted); font-family: var(--font-label); }
#hm-abbr ol { list-style: none; margin: 0; padding: 0 var(--space-xxs); overflow-y: auto; }
#hm-abbr li { padding: var(--space-xxs) 0; border-block-start: 1px solid var(--hairline); }
#hm-abbr .hm-abbr-key { font-family: var(--font-mono); font-weight: 700; color: var(--accent-deep); font-size: var(--text-sm); }
#hm-abbr .hm-abbr-term { display: block; font-family: var(--font-label); font-weight: 700; color: var(--ink); font-size: var(--text-xs); }
#hm-abbr .hm-abbr-exp { margin: 2px 0 0; font-size: var(--text-sm); line-height: var(--lh-normal); color: var(--body); }
#hm-abbr .hm-abbr-loc { margin: 2px 0 0; font-family: var(--font-mono); font-size: var(--text-xs); color: var(--muted); overflow-wrap: anywhere; }
#hm-abbr mark { background: var(--yellow); color: inherit; padding: 0; }

/* Footer */
.nav-footer { font-family: var(--font-label); font-size: var(--text-xs); text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted); border-block-start: 1px solid var(--frame-ink); padding-block: var(--space-xs); }


/* ══════════════════════════════════════════════════════════════════
   KNOWLEDGE-SOURCE KEY, STAGE CHIPS, HEADING SOURCE CHIPS
   ══════════════════════════════════════════════════════════════════ */

#hm-key { display: flex; flex-wrap: wrap; gap: 6px 16px; margin: calc(-1 * var(--space-md)) 0 var(--space-lg); max-width: none; }
#hm-key span { display: inline-flex; align-items: center; gap: 6px; font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: var(--body-muted); }
#hm-key i { width: 14px; height: 14px; border: 1px solid var(--frame-ink); display: inline-block; }
#hm-key .hm-key-title { color: var(--ink); }

main.content section[data-hm-stage] > h2 { border-block-end: 3px solid var(--hm-stage-tint); }
main.content section[data-hm-stage] > h3 { border-inline-start: 6px solid var(--hm-stage-tint); padding-inline-start: 10px; }
main.content h2[data-hm-chip]::before, main.content h3[data-hm-chip]::before {
  content: attr(data-hm-chip); display: inline-block; vertical-align: middle; margin-inline-end: 10px; margin-block-end: 5px;
  font-family: var(--font-label); font-size: 11px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; line-height: 1;
  color: var(--ink); background: var(--hm-stage-tint, var(--hairline)); padding: 4px 8px; border: 1px solid var(--frame-ink);
}
main.content h2[data-hm-chip="3GPP protocol"]::before { color: #ffffff; }
main.content h3[data-hm-chip]::before { font-size: 10px; padding: 3px 6px; margin-block-end: 2px; }

/* Lightbox: click a figure to view it at full size */
#hm-lightbox { position: fixed; inset: 0; z-index: 1400; display: none; place-items: center; background: rgba(0, 0, 0, 0.86); cursor: zoom-out; }
#hm-lightbox.hm-show { display: grid; }
#hm-lightbox img { max-width: 96vw; max-height: 92vh; background: #ffffff; padding: 12px; box-sizing: border-box; }
#hm-lightbox p { position: absolute; bottom: 10px; left: 0; right: 0; text-align: center; color: #ffffff; font-family: var(--font-label); font-size: var(--text-xs); text-transform: uppercase; letter-spacing: 0.06em; margin: 0; }

/* ══════════════════════════════════════════════════════════════════
   PARALLEL READING — second note in a right-hand window
   ══════════════════════════════════════════════════════════════════ */

#hm-split {
  position: fixed; top: var(--frame-width); right: var(--frame-width); bottom: var(--frame-width);
  width: var(--hm-split-w, 46vw); z-index: 1150; display: none; flex-direction: column;
  background: var(--canvas); border-inline-start: 3px solid var(--frame-ink);
}
html[data-hm-split="1"] #hm-split { display: flex; }
html[data-hm-split="1"] #quarto-content { margin-inline-end: var(--hm-split-w, 46vw); }
html[data-hm-split="1"] #hm-top { right: calc(var(--hm-split-w, 46vw) + var(--space-xs)); }
html[data-hm-split="1"] #hm-abbr-btn { right: var(--hm-split-w, 46vw); }
#hm-split header {
  display: flex; align-items: center; gap: 8px; padding: 0 8px 0 12px; min-height: 44px; background: var(--frame-ink); color: #ffffff;
  font-family: var(--font-label); font-size: var(--text-xs); font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em;
}
#hm-split header .hm-split-label { white-space: nowrap; color: var(--accent); }
#hm-split select {
  flex: 1; min-width: 0; font-family: var(--font-label); font-size: 13px; color: #ffffff; background: #000000;
  border: 1px solid #ffffff; border-radius: 0; padding: 5px 6px;
}
#hm-split header .hm-btn { min-height: 34px; border: 1px solid #3a3a3a; }
#hm-split iframe { flex: 1; width: 100%; border: 0; background: #ffffff; }
#hm-split-grip { position: absolute; inset-block: 0; inset-inline-start: -6px; width: 10px; cursor: col-resize; }
#hm-split-grip:hover { background: var(--accent); opacity: 0.5; }
@media (max-width: 991px) {
  #hm-split-btn, html[data-hm-split="1"] #hm-split { display: none !important; }
  html[data-hm-split="1"] #quarto-content { margin-inline-end: 0; }
}

/* Embedded page inside the second window: only the article and its section list */
html[data-hm-embed] #quarto-sidebar, html[data-hm-embed] #hm-banner, html[data-hm-embed] #hm-rail-toggle, html[data-hm-embed] #hm-rail-grip,
html[data-hm-embed] #hm-abbr, html[data-hm-embed] #hm-abbr-btn, html[data-hm-embed] #hm-top, html[data-hm-embed] #hm-progress,
html[data-hm-embed] .nav-footer, html[data-hm-embed] #hm-chapter-nav, html[data-hm-embed] #hm-split, html[data-hm-embed] .quarto-secondary-nav,
html[data-hm-embed] #hm-key { display: none !important; }
html[data-hm-embed] body { border-width: 0; }
html[data-hm-embed] #hm-readtime { margin-block-end: var(--space-sm); }

/* ══════════════════════════════════════════════════════════════════
   RESPONSIVE, NIGHT, PRINT
   ══════════════════════════════════════════════════════════════════ */

@media (max-width: 991px) {
  #hm-rail-toggle, #hm-rail-grip { display: none; }
  body.hm-rail-collapsed #quarto-sidebar { transform: none; opacity: 1; pointer-events: auto; }
  .quarto-secondary-nav, .quarto-secondary-nav .quarto-btn-toggle, .quarto-secondary-nav .quarto-secondary-nav-title {
    background: var(--canvas) !important; color: var(--ink) !important; border-block-end: 1px solid var(--frame-ink);
  }
  .quarto-secondary-nav a, .quarto-secondary-nav .quarto-btn-toggle i { color: var(--ink) !important; }
}
@media (max-width: 768px) {
  main.content { padding-inline: var(--space-xs); }
  main.content h2 { margin-block-start: var(--space-lg); }
  main.content table { font-size: var(--text-xs); }
  #hm-banner .hm-brand { font-size: 11px; }
  #hm-chapter-nav { flex-direction: column; }
  main.content p[data-hm-lead="question"], main.content p[data-hm-lead="answer"] { margin-inline-start: 0; }
}
@media (max-width: 480px) {
  .hm-btn { padding: 0 8px; min-width: 36px; font-size: 11px; }
  .quarto-figure img, main.content p > img { padding: var(--space-xxs); }
}
html[data-hm-theme="dark"] .hm-btn, html[data-hm-theme="dark"] #hm-banner { background: #000000; }
html[data-hm-theme="dark"] main.content thead th { background: var(--canvas); }
@media (prefers-reduced-motion: reduce) { * { transition-duration: 0.01ms !important; animation-duration: 0.01ms !important; } }
@media print {
  #quarto-sidebar, #quarto-margin-sidebar, .navbar, #hm-banner, #hm-tools, #hm-rail-toggle, #hm-rail-grip, #hm-abbr-btn, #hm-abbr,
  #hm-progress, #hm-top, #hm-chapter-nav, #hm-split, #hm-lightbox { display: none !important; }
  body { border: none; background: #fff; color: #000; }
  main.content div.callout { background: none; }
}
"""


def render_export_js() -> str:
    """Reading tools plus the semantic colour tagging.

    Callout kind and paragraph-lead type are derived here rather than in CSS,
    because both distinctions live in the element's text: several different
    meanings share one Quarto callout class, and the contract markers are bold
    leads inside ordinary paragraphs.
    """

    return """/* Hallmark reading tools for the Saar 5G NR knowledge base.
 * Semantic colour tagging, sidebar collapse, theme, reading width, text size,
 * progress, chapter nav, anchors, back-to-top, keyboard shortcuts.
 * Every preference is per-reader and stored locally; nothing leaves the browser.
 */
(function () {
  "use strict";

  var LS = "hm-prefs";
  var prefs = { theme: "light", width: "normal", size: "m", rail: "open", railw: 0 };
  var EMBED = /(?:^|[?&])embed=1(?:&|$)/.test(location.search);
  if (EMBED) document.documentElement.setAttribute("data-hm-embed", "1");

  try {
    var saved = JSON.parse(localStorage.getItem(LS) || "{}");
    for (var k in saved) { if (prefs.hasOwnProperty(k)) prefs[k] = saved[k]; }
  } catch (e) { /* private mode, blocked storage: keep defaults */ }

  function save() {
    try { localStorage.setItem(LS, JSON.stringify(prefs)); } catch (e) { /* non-fatal */ }
  }

  function applyAll() {
    var r = document.documentElement;
    r.setAttribute("data-hm-theme", prefs.theme);
    r.setAttribute("data-hm-width", prefs.width);
    r.setAttribute("data-hm-size", prefs.size);
    document.body.classList.toggle("hm-rail-collapsed", EMBED || prefs.rail === "closed");
    if (prefs.railw > 0) {
      r.style.setProperty("--hm-rail-w", prefs.railw + "px");
      r.setAttribute("data-hm-rail-w", String(prefs.railw));
    } else {
      r.style.removeProperty("--hm-rail-w");
      r.removeAttribute("data-hm-rail-w");
    }
    positionRail();
  }

  function el(tag, attrs, text) {
    var n = document.createElement(tag);
    for (var a in attrs) {
      if (a === "class") n.className = attrs[a]; else n.setAttribute(a, attrs[a]);
    }
    if (text != null) n.textContent = text;
    return n;
  }

  /* ── Semantic colour tagging ────────────────────────────────────
     Several meanings collapse onto one Quarto callout class, so the
     kind is read from the callout's own title instead. */

  var KINDS = [
    [/failure|failed|error diagnosis|rejection/i, "failure"],
    [/\\b(?:verified|validated|measured|observed) result\\b/i, "result"],
    [/trade.?off|limitation|design choice/i, "tradeoff"],
    [/matlab|experiment|simulation/i, "matlab"],
    [/parameter|configuration|assumption/i, "parameter"],
    [/3gpp|reality check/i,        "spec"],
    [/book expansion/i,            "book"],
    [/sharetechnote|engineering/i, "engineering"],
    [/search this note/i,          "search"],
    [/searchable structure/i,      "structure"],
    [/figure correction|redraw|unresolved/i, "figure"],
    [/end-to-end trace|trace/i,    "trace"],
    [/reading order|important/i,   "warn"]
  ];

  function tagCallouts() {
    var nodes = document.querySelectorAll("#quarto-document-content div.callout");
    for (var i = 0; i < nodes.length; i++) {
      var c = nodes[i];
      // The callout div carries an exact title attribute. Prefer it: the
      // rendered header also contains a screen-reader-only kind prefix
      // ("Tip", "Note") that would pollute the match.
      var title = c.getAttribute("title") || "";
      if (!title) {
        var tc = c.querySelector(".callout-title-container");
        if (tc) {
          var sr = tc.querySelector(".screen-reader-only");
          title = (tc.textContent || "").replace(sr ? sr.textContent : "", "");
        }
      }
      title = title.trim();
      var kind = c.getAttribute("data-hm-kind") || "";
      for (var j = 0; j < KINDS.length; j++) {
        if (kind) break;
        if (KINDS[j][0].test(title)) { kind = KINDS[j][1]; break; }
      }
      if (!kind) {
        // The lightbulb asides carry no useful title; treat them as insight.
        if (/^\\s*\\u{1F4A1}?\\s*$/u.test(title) || title === "") kind = "insight";
        else if (c.classList.contains("callout-warning")) kind = "figure";
        else if (c.classList.contains("callout-important")) kind = "warn";
        else kind = "insight";
      }
      kind = ({failure: "warning", insight: "important", warn: "note", figure: "warning",
               tradeoff: "note", parameter: "note", search: "note", structure: "note", trace: "note", supp: "note"})[kind] || kind;
      c.setAttribute("data-hm-kind", kind);
      var header = c.querySelector(".callout-header");
      if (header && SOURCE[kind]) header.setAttribute("data-hm-source", SOURCE[kind][0]);
    }
  }

  /* Knowledge source behind each colour: what the reader is looking at. */
  var SOURCE = {
    book:        ["Textbook",        "book"],
    spec:        ["3GPP protocol",   "spec"],
    engineering: ["ShareTechnote",   "engineering"],
    supp:        ["Supplement",      "supp"],
    matlab:      ["MATLAB",          "matlab"],
    parameter:   ["Parameter",       "parameter"],
    result:      ["Measured result", "result"],
    warning:     ["Warning",         "warning"],
    tradeoff:    ["Trade-off",       "tradeoff"],
    important:   ["Important",       "important"],
    insight:     ["Reproduce and references", "neutral"],
    search:      ["Search",          "search"],
    structure:   ["Structure",       "structure"],
    figure:      ["Figure note",     "figure"],
    trace:       ["Trace",           "trace"],
    note:        ["Note",            "note"]
  };

  /* Uni notes mark each section with its stage: textbook → protocol → MATLAB → results. */
  var STAGES = [
    [/textbook/i,              "book",    "Textbook workflow"],
    [/3gpp|protocol/i,         "spec",    "3GPP protocol"],
    [/matlab|experiment/i,     "matlab",  "MATLAB experiment"],
    [/result|measure/i,        "result",  "Measured results"],
    [/reproduc|reference/i,    "insight", "Reproduce and references"]
  ];

  function tagStages() {
    var ps = document.querySelectorAll("#quarto-document-content p[data-hm-lead='stage']");
    for (var i = 0; i < ps.length; i++) {
      var p = ps[i], text = (p.textContent || "").replace(/^\\s*stage\\s*[\u2014\u2013-]\\s*/i, "").replace(/\\.\\s*$/, "").trim();
      var kind = "", label = text;
      for (var j = 0; j < STAGES.length; j++) { if (STAGES[j][0].test(text)) { kind = STAGES[j][1]; label = STAGES[j][2]; break; } }
      if (!kind) continue;
      var sec = p.closest("section") || p.parentNode;
      sec.setAttribute("data-hm-stage", kind);
      sec.style.setProperty("--hm-stage-tint", "var(--t-" + kind + ")");
      var h = sec.querySelector("h2, h3");
      if (h) h.setAttribute("data-hm-chip", label);
    }
  }

  /* Star notes: colour a heading by the source it draws on. */
  var HEAD_SRC = [
    [/sharetechnote/i,                       "engineering"],
    [/supplement|course alignment/i,         "supp"],
    [/3gpp|\\bTS\\s*38\\.|protocol/i,            "spec"],
    [/textbook|the book|book road/i,         "book"],
    [/matlab|simulation|experiment/i,        "matlab"],
    [/common confusions|worked example|reader question/i, "insight"]
  ];

  function tagHeadings() {
    var hs = document.querySelectorAll("#quarto-document-content h2, #quarto-document-content h3");
    for (var i = 0; i < hs.length; i++) {
      var h = hs[i];
      if (h.hasAttribute("data-hm-chip") || h.closest("section[data-hm-stage]")) continue;
      var t = (h.textContent || "").trim();
      if (/^\\d+(?:\\.\\d+)*\\s+(?:references|abbreviation|mathematical|symbol)/i.test(t)) continue;
      for (var j = 0; j < HEAD_SRC.length; j++) {
        if (HEAD_SRC[j][0].test(t)) {
          var k = HEAD_SRC[j][1];
          h.setAttribute("data-hm-chip", SOURCE[k][0]);
          h.style.setProperty("--hm-stage-tint", "var(--t-" + k + ")");
          h.setAttribute("data-hm-src", k);
          break;
        }
      }
    }
  }

  /* Click a figure to see it at full size. */
  function lightbox() {
    var box = el("div", { id: "hm-lightbox", role: "dialog", "aria-label": "Figure at full size" });
    var img = el("img", { alt: "" });
    var cap = el("p", {}, "Click anywhere to close");
    box.appendChild(img); box.appendChild(cap);
    box.addEventListener("click", function () { box.classList.remove("hm-show"); img.src = ""; });
    document.body.appendChild(box);
    document.addEventListener("click", function (e) {
      var t = e.target;
      if (!t || t.tagName !== "IMG" || !t.closest("#quarto-document-content")) return;
      if (t.closest("a")) return;
      img.src = t.currentSrc || t.src; img.alt = t.alt || "";
      box.classList.add("hm-show");
    });
    document.addEventListener("keydown", function (e) { if (e.key === "Escape") box.classList.remove("hm-show"); });
  }

  var LEADS = [
    [/^stage\\b/i,            "stage"],
    [/^section purpose/i,    "purpose"],
    [/^section conclusion/i, "conclusion"],
    [/^reader question/i,    "question"],
    [/^short answer/i,       "answer"]
  ];

  function tagCaptions() {
    var imgs = document.querySelectorAll("#quarto-document-content img");
    for (var i = 0; i < imgs.length; i++) {
      var block = imgs[i].closest(".quarto-figure, figure, p") || imgs[i];
      var next = block.nextElementSibling;
      while (next && next.tagName === "DIV" && !next.classList.contains("callout") && next.children.length === 1) next = next.firstElementChild;
      if (next && next.tagName === "P" && next.firstElementChild && next.firstElementChild.tagName === "EM" &&
          next.textContent.trim() === next.firstElementChild.textContent.trim()) {
        next.setAttribute("data-hm-caption", "1");
      }
    }
  }

  function tagLeads() {
    var ps = document.querySelectorAll("#quarto-document-content p > strong:first-child");
    for (var i = 0; i < ps.length; i++) {
      var s = ps[i], p = s.parentNode;
      if (!p || p.tagName !== "P") continue;
      var t = (s.textContent || "").trim();
      for (var j = 0; j < LEADS.length; j++) {
        if (LEADS[j][0].test(t)) { p.setAttribute("data-hm-lead", LEADS[j][1]); break; }
      }
    }
  }

  var KEY_ORDER = ["book", "spec", "engineering", "matlab", "result"];

  function buildKey() {
    if (EMBED) return;
    var main = document.querySelector("#quarto-document-content");
    if (!main) return;
    var present = {};
    main.querySelectorAll("div.callout[data-hm-kind]").forEach(function (c) { present[c.getAttribute("data-hm-kind")] = 1; });
    main.querySelectorAll("section[data-hm-stage]").forEach(function (c) { present[c.getAttribute("data-hm-stage")] = 1; });
    main.querySelectorAll("[data-hm-src]").forEach(function (c) { present[c.getAttribute("data-hm-src")] = 1; });
    if (present.parameter) present.matlab = 1;
    var rows = KEY_ORDER.filter(function (k) { return present[k]; });
    if (rows.length < 2) return;
    var wrap = el("div", { id: "hm-key", "aria-label": "Colour key: knowledge source" });
    wrap.appendChild(el("span", { class: "hm-key-title" }, "Colour by source"));
    rows.forEach(function (k) {
      var sp = el("span");
      var i = el("i");
      i.style.background = "var(--t-" + k + ")";
      sp.appendChild(i);
      sp.appendChild(document.createTextNode(SOURCE[k][0]));
      wrap.appendChild(sp);
    });
    var after = document.querySelector("#hm-readtime") || document.querySelector("#title-block-header");
    if (after && after.parentNode) after.parentNode.insertBefore(wrap, after.nextSibling);
    else main.insertBefore(wrap, main.firstChild);
  }

  /* ── Rail toggle ────────────────────────────────────────────── */

  var railBtn, railGrip;

  /* Drag the sidebar edge: the rail width becomes a CSS variable, the grid
     gives the content column whatever remains, and the text reflows to it. */
  function buildGrip() {
    railGrip = el("div", { id: "hm-rail-grip", role: "separator", "aria-orientation": "vertical",
                           title: "Drag to resize the chapter list. Double-click to reset." });
    var dragging = false;
    function move(e) {
      if (!dragging) return;
      var w = Math.max(160, Math.min(560, Math.round(e.clientX)));
      prefs.railw = w;
      var r = document.documentElement;
      r.style.setProperty("--hm-rail-w", w + "px");
      r.setAttribute("data-hm-rail-w", String(w));
      positionRail();
    }
    railGrip.addEventListener("pointerdown", function (e) {
      if (prefs.rail === "closed") return;
      dragging = true;
      try { railGrip.setPointerCapture(e.pointerId); } catch (err) { /* synthetic or stale pointer */ }
      document.body.classList.add("hm-rail-dragging");
      if (prefs.width !== "fill") { prefs.width = "fill"; document.documentElement.setAttribute("data-hm-width", "fill"); paintWidth(); }
      e.preventDefault();
    });
    railGrip.addEventListener("pointermove", move);
    function stop() {
      if (!dragging) return;
      dragging = false;
      document.body.classList.remove("hm-rail-dragging");
      save(); positionRail();
    }
    railGrip.addEventListener("pointerup", stop);
    railGrip.addEventListener("pointercancel", stop);
    railGrip.addEventListener("dblclick", function () {
      prefs.railw = 0; prefs.width = "normal"; save(); applyAll(); paintWidth();
    });
    document.body.appendChild(railGrip);
  }

  function positionRail() {
    if (!railBtn) return;
    var sb = document.querySelector("#quarto-sidebar");
    var open = prefs.rail !== "closed";
    var w = sb && open ? Math.round(sb.getBoundingClientRect().width) : 0;
    railBtn.style.insetInlineStart = w + "px";
    if (railGrip) railGrip.style.insetInlineStart = w + "px";
    railBtn.textContent = open ? "\\u2039" : "\\u203A";
    railBtn.setAttribute("aria-expanded", open ? "true" : "false");
    railBtn.setAttribute("title", (open ? "Hide" : "Show") + " chapter list  (\\\\)");
  }

  function toggleRail() {
    prefs.rail = prefs.rail === "closed" ? "open" : "closed";
    save(); applyAll();
  }

  /* ── Controls ───────────────────────────────────────────────── */

  var themeBtn, widthBtn, splitBtn;

  function paintTheme() { if (themeBtn) themeBtn.textContent = prefs.theme === "dark" ? "Day" : "Night"; }
  function paintWidth() { if (widthBtn) widthBtn.textContent = prefs.width.charAt(0).toUpperCase() + prefs.width.slice(1); }

  function buildTools() {
    var bar = el("div", { id: "hm-progress" });
    document.body.appendChild(bar);

    railBtn = el("button", {
      id: "hm-rail-toggle", type: "button",
      "aria-controls": "quarto-sidebar", "aria-label": "Toggle chapter list"
    });
    railBtn.addEventListener("click", toggleRail);
    document.body.appendChild(railBtn);

    var tools = el("div", { id: "hm-tools", role: "toolbar", "aria-label": "Reading controls" });

    themeBtn = el("button", { class: "hm-btn", type: "button", title: "Day / night  (t)" });
    paintTheme();
    themeBtn.addEventListener("click", function () {
      prefs.theme = prefs.theme === "dark" ? "light" : "dark";
      save(); applyAll(); paintTheme();
    });
    tools.appendChild(themeBtn);
    tools.appendChild(el("span", { class: "hm-sep" }));

    var smaller = el("button", { class: "hm-btn", type: "button", title: "Smaller text  (-)" }, "A\\u2212");
    var bigger  = el("button", { class: "hm-btn", type: "button", title: "Larger text  (+)" }, "A+");
    smaller.addEventListener("click", function () { bump(-1); });
    bigger.addEventListener("click", function () { bump(1); });
    tools.appendChild(smaller); tools.appendChild(bigger);
    tools.appendChild(el("span", { class: "hm-sep" }));

    widthBtn = el("button", { class: "hm-btn", type: "button", title: "Reading width  (w)" });
    paintWidth();
    widthBtn.addEventListener("click", function () { cycleWidth(); });
    tools.appendChild(widthBtn);
    tools.appendChild(el("span", { class: "hm-sep" }));

    splitBtn = el("button", { class: "hm-btn", id: "hm-split-btn", type: "button", title: "Read two notes side by side  (s)" }, "Split");
    splitBtn.addEventListener("click", function () { toggleSplit(); });
    if (!EMBED) tools.appendChild(splitBtn);

    var keys = el("button", { class: "hm-btn", type: "button", title: "Keyboard shortcuts  (?)" }, "?");
    keys.addEventListener("click", function () { sheet.classList.toggle("hm-show"); });
    tools.appendChild(keys);

    // Dell top banner: black strip across the reading column with the controls on the
    // left, the site name, and the chapter code in Dell red on the right.
    var host = document.querySelector("#quarto-document-content") || document.querySelector("main.content") || document.body;
    var banner = el("div", { id: "hm-banner" });
    banner.appendChild(tools);
    banner.appendChild(el("span", { class: "hm-brand" }, "Saarland University \u00B7 5G NR Teaching Knowledge Base"));
    var h1 = document.querySelector("#title-block-header .title, main.content h1");
    var code = /^\\s*((?:STAR|UNI)-\\d+)/i.exec(h1 ? h1.textContent : "");
    banner.appendChild(el("span", { class: "hm-code" }, code ? code[1].toUpperCase() : "5G NR"));
    host.insertBefore(banner, host.firstChild);

    var top = el("button", { id: "hm-top", type: "button", title: "Back to top" }, "Top");
    top.addEventListener("click", function () { window.scrollTo({ top: 0, behavior: "smooth" }); });
    document.body.appendChild(top);

    var sheet = el("div", { id: "hm-keys" });
    var inner = el("div", { class: "hm-sheet" });
    inner.appendChild(el("h2", {}, "Keyboard shortcuts"));
    var dl = el("dl");
    [["\\\\", "Show or hide the chapter list"],
     ["t", "Day / night"],
     ["w", "Cycle reading width"],
     ["+ / -", "Text size"],
     ["[ / ]", "Previous / next chapter"],
     ["a", "Abbreviation lookup"],
     ["s", "Second reading window (Alt-click a chapter to open it there)"],
     ["click a figure", "View it at full size"],
     ["drag the rail edge", "Resize the chapter list (double-click resets)"],
     ["g then t", "Back to top"],
     ["?", "This sheet"]].forEach(function (row) {
      dl.appendChild(el("dt", {}, row[0]));
      dl.appendChild(el("dd", {}, row[1]));
    });
    inner.appendChild(dl);
    sheet.appendChild(inner);
    sheet.addEventListener("click", function () { sheet.classList.remove("hm-show"); });
    document.body.appendChild(sheet);

    return { progress: bar, top: top, sheet: sheet };
  }

  function bump(d) {
    var s = ["s", "m", "l"];
    var i = Math.min(2, Math.max(0, s.indexOf(prefs.size) + d));
    prefs.size = s[i]; save(); applyAll();
  }

  function cycleWidth() {
    var ws = ["narrow", "normal", "wide", "fill"];
    prefs.width = ws[(ws.indexOf(prefs.width) + 1) % ws.length];
    save(); applyAll(); paintWidth();
  }

  /* ── Chapter order ──────────────────────────────────────────── */

  function chapterLinks() {
    var out = [], seen = {};
    var nodes = document.querySelectorAll("#quarto-sidebar a.sidebar-item-text[href], #quarto-sidebar a[href].sidebar-link");
    for (var i = 0; i < nodes.length; i++) {
      var a = nodes[i], href = a.getAttribute("href"), url;
      if (!href || href.charAt(0) === "#") continue;
      try { url = new URL(href, location.href); } catch (e) { continue; }
      // Quarto writes absolute hrefs, so filter by origin rather than by the
      // presence of a scheme, and keep only real pages (not the .yml manifest).
      if (url.origin !== location.origin) continue;
      if (!/(\\.html?|\\/)$/i.test(url.pathname)) continue;
      if (seen[url.pathname]) continue;
      seen[url.pathname] = 1;
      out.push({ href: a.href, path: url.pathname, title: (a.textContent || "").trim() });
    }
    return out;
  }

  var chapters = [], hereIndex = -1;

  function buildChapterNav() {
    chapters = chapterLinks();
    for (var i = 0; i < chapters.length; i++) {
      if (chapters[i].path === location.pathname) { hereIndex = i; break; }
    }
    if (hereIndex < 0) return;
    var prev = chapters[hereIndex - 1], next = chapters[hereIndex + 1];
    if (!prev && !next) return;

    var main = document.querySelector("#quarto-document-content") || document.querySelector("main.content");
    if (!main) return;

    var nav = el("nav", { id: "hm-chapter-nav", "aria-label": "Chapter navigation" });
    [[prev, "Previous", "hm-prev"], [next, "Next", "hm-next"]].forEach(function (p) {
      if (!p[0]) { nav.appendChild(el("span", { class: "hm-navlink", style: "visibility:hidden" })); return; }
      var a = el("a", { class: "hm-navlink " + p[2], href: p[0].href });
      a.appendChild(el("span", { class: "hm-dir" }, p[1]));
      a.appendChild(el("span", { class: "hm-title" }, p[0].title));
      nav.appendChild(a);
    });
    main.appendChild(nav);
  }

  function go(delta) {
    if (hereIndex < 0) return;
    var t = chapters[hereIndex + delta];
    if (t) location.href = t.href;
  }

  /* ── Reading time ───────────────────────────────────────────── */

  function readingTime() {
    var main = document.querySelector("#quarto-document-content") || document.querySelector("main.content");
    if (!main) return;
    var words = (main.innerText || "").trim().split(/\\s+/).length;
    if (words < 200) return;
    var mins = Math.max(1, Math.round(words / 210));
    var chip = el("p", { id: "hm-readtime" }, words.toLocaleString() + " words \\u00B7 about " + mins + " min");
    var title = document.querySelector("#title-block-header");
    if (title && title.parentNode) title.parentNode.insertBefore(chip, title.nextSibling);
    else main.insertBefore(chip, main.firstChild);
  }

  /* ── Heading anchors (Quarto's own, with copy added) ────────── */

  function anchors() {
    var links = document.querySelectorAll("#quarto-document-content .anchorjs-link");
    for (var i = 0; i < links.length; i++) {
      (function (a) {
        a.setAttribute("title", "Copy link to this section");
        a.addEventListener("click", function () {
          var href = a.getAttribute("href") || "";
          if (!navigator.clipboard || href.charAt(0) !== "#") return;
          navigator.clipboard
            .writeText(location.origin + location.pathname + href)
            .catch(function () { /* clipboard blocked: the jump still works */ });
        });
      })(links[i]);
    }
  }

  /* ── Progress + back-to-top ─────────────────────────────────── */

  function scrollWatch(ui) {
    var ticking = false;
    function update() {
      var h = document.documentElement;
      var max = h.scrollHeight - h.clientHeight;
      var pct = max > 0 ? (h.scrollTop / max) * 100 : 0;
      ui.progress.style.width = pct.toFixed(2) + "%";
      ui.top.classList.toggle("hm-show", h.scrollTop > 600);
      ticking = false;
    }
    window.addEventListener("scroll", function () {
      if (!ticking) { ticking = true; window.requestAnimationFrame(update); }
    }, { passive: true });
    update();
  }

  /* ── Keyboard ───────────────────────────────────────────────── */

  function keyboard(ui) {
    var lastG = 0;
    document.addEventListener("keydown", function (e) {
      var t = e.target;
      if (t && (t.tagName === "INPUT" || t.tagName === "TEXTAREA" || t.isContentEditable)) return;
      if (e.metaKey || e.ctrlKey || e.altKey) return;

      if (e.key === "g") { lastG = Date.now(); return; }
      if (e.key === "t" && Date.now() - lastG < 700) {
        lastG = 0; window.scrollTo({ top: 0, behavior: "smooth" }); e.preventDefault(); return;
      }

      switch (e.key) {
        case "\\\\": toggleRail(); break;
        case "t": prefs.theme = prefs.theme === "dark" ? "light" : "dark"; save(); applyAll(); paintTheme(); break;
        case "w": cycleWidth(); break;
        case "+": case "=": bump(1); break;
        case "-": bump(-1); break;
        case "[": go(-1); break;
        case "]": go(1); break;
        case "?": ui.sheet.classList.toggle("hm-show"); break;
        case "a": abbrFocus(); break;
        case "s": toggleSplit(); break;
        case "Escape": ui.sheet.classList.remove("hm-show"); if (abbrPanel && !abbrPanel.classList.contains("hm-inline")) abbrToggle(false); break;
        default: return;
      }
      e.preventDefault();
    });
  }

  /* ── Parallel reading: a second note in a right-hand window ── */

  var SPLIT_KEY = "hm-split";
  var splitPane, splitFrame, splitSelect;

  function embedUrl(href) {
    var u = new URL(href, location.href);
    u.searchParams.set("embed", "1");
    return u.href;
  }

  function loadSplit(href) {
    if (!splitFrame) return;
    var u = new URL(href, location.href);
    u.searchParams.delete("embed");
    splitFrame.src = embedUrl(u.href);
    if (splitSelect) {
      for (var i = 0; i < splitSelect.options.length; i++) {
        if (new URL(splitSelect.options[i].value, location.href).pathname === u.pathname) { splitSelect.selectedIndex = i; break; }
      }
    }
    try { sessionStorage.setItem(SPLIT_KEY, u.href); } catch (e) { /* non-fatal */ }
  }

  function toggleSplit(open, href) {
    if (EMBED || !splitPane) return;
    var on = open == null ? document.documentElement.getAttribute("data-hm-split") !== "1" : open;
    if (on) {
      document.documentElement.setAttribute("data-hm-split", "1");
      var target = href;
      if (!target) { try { target = sessionStorage.getItem(SPLIT_KEY); } catch (e) { target = null; } }
      if (!target) { var n = chapters[hereIndex + 1] || chapters[0]; target = n ? n.href : location.href; }
      loadSplit(target);
    } else {
      document.documentElement.removeAttribute("data-hm-split");
      splitFrame.src = "about:blank";
      try { sessionStorage.removeItem(SPLIT_KEY); } catch (e) { /* non-fatal */ }
    }
    if (splitBtn) { splitBtn.setAttribute("aria-pressed", on ? "true" : "false"); splitBtn.textContent = on ? "Single" : "Split"; }
  }

  function buildSplit() {
    if (EMBED) return;
    splitPane = el("aside", { id: "hm-split", "aria-label": "Second reading window" });
    var head = el("header");
    head.appendChild(el("span", { class: "hm-split-label" }, "Second note"));
    splitSelect = el("select", { "aria-label": "Choose the note for the second window" });
    if (!chapters.length) chapters = chapterLinks();
    chapters.forEach(function (c) {
      var o = el("option", { value: c.href }, c.title);
      splitSelect.appendChild(o);
    });
    splitSelect.addEventListener("change", function () { loadSplit(splitSelect.value); });
    head.appendChild(splitSelect);
    var swap = el("button", { class: "hm-btn", type: "button", title: "Swap the two windows" }, "Swap");
    swap.addEventListener("click", function () {
      var current = splitSelect.value;
      try { sessionStorage.setItem(SPLIT_KEY, location.href); } catch (e) { /* non-fatal */ }
      location.href = current;
    });
    head.appendChild(swap);
    var close = el("button", { class: "hm-btn", type: "button", title: "Close the second window  (s)" }, "\u00D7");
    close.addEventListener("click", function () { toggleSplit(false); });
    head.appendChild(close);
    splitPane.appendChild(head);
    splitFrame = el("iframe", { title: "Second reading window", loading: "lazy" });
    splitPane.appendChild(splitFrame);
    var grip = el("div", { id: "hm-split-grip", role: "separator", "aria-orientation": "vertical", title: "Drag to resize" });
    var dragging = false;
    grip.addEventListener("pointerdown", function (e) { dragging = true; try { grip.setPointerCapture(e.pointerId); } catch (err) {} e.preventDefault(); });
    grip.addEventListener("pointermove", function (e) {
      if (!dragging) return;
      var w = Math.max(30, Math.min(70, Math.round((1 - e.clientX / window.innerWidth) * 100)));
      document.documentElement.style.setProperty("--hm-split-w", w + "vw");
    });
    grip.addEventListener("pointerup", function () { dragging = false; });
    grip.addEventListener("pointercancel", function () { dragging = false; });
    splitPane.appendChild(grip);
    document.body.appendChild(splitPane);

    // Alt-click any chapter link to open it in the second window.
    document.addEventListener("click", function (e) {
      if (!e.altKey) return;
      var a = e.target && e.target.closest ? e.target.closest("#quarto-sidebar a[href], #quarto-document-content a[href]") : null;
      if (!a) return;
      var u; try { u = new URL(a.href); } catch (err) { return; }
      if (u.origin !== location.origin || !/(\\.html?|\\/)$/i.test(u.pathname)) return;
      e.preventDefault();
      toggleSplit(true, u.href);
    });

    var saved = null;
    try { saved = sessionStorage.getItem(SPLIT_KEY); } catch (e) { /* non-fatal */ }
    if (saved && window.matchMedia("(min-width: 992px)").matches) toggleSplit(true, saved);
  }

  // Inside the second window every internal link keeps the window in embedded mode.
  function embedLinks() {
    if (!EMBED) return;
    document.addEventListener("click", function (e) {
      var a = e.target && e.target.closest ? e.target.closest("a[href]") : null;
      if (!a) return;
      var u; try { u = new URL(a.href); } catch (err) { return; }
      if (u.origin !== location.origin) { a.target = "_blank"; return; }
      if (u.pathname === location.pathname && u.hash) return;
      if (/(\\.html?|\\/)$/i.test(u.pathname)) { u.searchParams.set("embed", "1"); a.href = u.href; }
    }, true);
  }

  /* ── Abbreviation lookup ────────────────────────────────────── */

  var abbrPanel, abbrInput, abbrList, abbrBtn;

  function esc(t) { return String(t).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }

  function markHit(text, q) {
    if (!q) return esc(text);
    var i = text.toLowerCase().indexOf(q.toLowerCase());
    if (i < 0) return esc(text);
    return esc(text.slice(0, i)) + "<mark>" + esc(text.slice(i, i + q.length)) + "</mark>" + esc(text.slice(i + q.length));
  }

  function abbrSearch(q) {
    var data = window.HM_ABBR || [];
    q = q.trim();
    var ql = q.toLowerCase();
    var hits = [];
    for (var i = 0; i < data.length; i++) {
      var d = data[i], a = d.a.toLowerCase(), score = -1;
      if (!q) score = 0;
      else if (a === ql) score = 5;
      else if (a.replace(/[^a-z0-9]/g, "") === ql.replace(/[^a-z0-9]/g, "")) score = 4;
      else if (a.indexOf(ql) === 0) score = 3;
      else if (a.indexOf(ql) >= 0) score = 2;
      else if (d.t.toLowerCase().indexOf(ql) >= 0) score = 1;
      else if (ql.length >= 3 && d.e.toLowerCase().indexOf(ql) >= 0) score = 0.5;
      if (score >= 0) hits.push([score, d]);
    }
    hits.sort(function (x, y) { return y[0] - x[0] || x[1].a.localeCompare(y[1].a); });
    if (!q) return [];
    return hits.slice(0, 5).map(function (h) { return h[1]; });
  }

  function abbrRender(panel) {
    panel = panel || document.querySelector("#hm-abbr");
    if (!panel) return;
    var input = panel.querySelector("input"), list = panel.querySelector("ol"), hint = panel.querySelector(".hm-abbr-hint");
    if (!input || !list || !hint) return;
    var q = input.value;
    var rows = abbrSearch(q);
    list.innerHTML = "";
    hint.textContent = q.trim()
      ? (rows.length ? "" : "No entry for \u201C" + q.trim() + "\u201D.")
      : (window.HM_ABBR || []).length + " terms. Type an abbreviation.";
    rows.forEach(function (d) {
      var li = document.createElement("li");
      li.innerHTML = '<span class="hm-abbr-key">' + markHit(d.a, q.trim()) + '</span>' +
                     '<span class="hm-abbr-term">' + markHit(d.t, q.trim()) + '</span>' +
                     '<p class="hm-abbr-exp">' + esc(d.e) + '</p>' +
                     (d.l ? '<p class="hm-abbr-loc">' + esc(d.l) + '</p>' : "");
      list.appendChild(li);
    });
  }

  function abbrToggle(open) {
    var show = open == null ? !abbrPanel.classList.contains("hm-show") : open;
    abbrPanel = document.querySelector("#hm-abbr") || abbrPanel;
    abbrPanel.classList.toggle("hm-show", show);
    if (abbrBtn) abbrBtn.setAttribute("aria-expanded", show ? "true" : "false");
    if (show) { abbrRender(abbrPanel); var inp = abbrPanel.querySelector("input"); setTimeout(function () { inp.focus(); inp.select(); }, 0); }
  }

  function buildAbbr() {
    if (!window.HM_ABBR || !window.HM_ABBR.length) return;
    var margin = document.querySelector("#quarto-margin-sidebar");
    var inline = !!margin && window.matchMedia("(min-width: 992px)").matches;

    abbrPanel = el("aside", { id: "hm-abbr", "aria-label": "Abbreviation lookup" });
    var head = el("header");
    head.appendChild(el("h2", {}, "Abbreviation lookup"));
    if (!inline) {
      var close = el("button", { class: "hm-btn", type: "button", title: "Close  (Esc)" }, "\u00D7");
      close.addEventListener("click", function () { abbrToggle(false); });
      head.appendChild(close);
    }
    abbrPanel.appendChild(head);
    abbrInput = el("input", { type: "search", placeholder: "e.g. BWP", autocomplete: "off", spellcheck: "false", "aria-label": "Abbreviation" });
    abbrPanel.appendChild(abbrInput);
    // Delegated: Quarto re-lays the margin sidebar after load, so the panel
    // the reader sees may be a clone of the one built here.
    document.addEventListener("input", function (e) {
      var panel = e.target && e.target.closest ? e.target.closest("#hm-abbr") : null;
      if (panel) abbrRender(panel);
    });
    document.addEventListener("keydown", function (e) {
      var panel = e.target && e.target.closest ? e.target.closest("#hm-abbr") : null;
      if (panel && e.key === "Escape") { if (!inline) abbrToggle(false); else e.target.blur(); e.stopPropagation(); }
    }, true);
    abbrPanel.appendChild(el("p", { class: "hm-abbr-hint" }));
    abbrList = el("ol");
    abbrPanel.appendChild(abbrList);

    if (inline) {
      abbrPanel.classList.add("hm-inline");
      margin.appendChild(abbrPanel);
      abbrRender(abbrPanel);
      return;
    }
    abbrBtn = el("button", { id: "hm-abbr-btn", type: "button", "aria-controls": "hm-abbr", "aria-expanded": "false",
                             title: "Abbreviation lookup  (a)" }, "Abbreviations");
    abbrBtn.addEventListener("click", function () { abbrToggle(); });
    document.body.appendChild(abbrBtn);
    document.body.appendChild(abbrPanel);
  }

  function abbrFocus() {
    if (!abbrPanel) return;
    var all = document.querySelectorAll("#hm-abbr"), panel = abbrPanel;
    for (var i = 0; i < all.length; i++) { if (all[i].offsetParent !== null) { panel = all[i]; break; } }
    var inp = panel.querySelector("input");
    if (panel.classList.contains("hm-inline")) { inp.focus(); inp.select(); }
    else abbrToggle(true);
  }

  /* ── Go ─────────────────────────────────────────────────────── */

  function init() {
    var ui = buildTools();
    buildGrip();
    buildAbbr();
    applyAll();
    tagCallouts();
    tagCaptions();
    tagLeads();
    tagStages();
    tagHeadings();
    document.querySelectorAll('main.content div.sourceCode:has(code.matlab), main.content div.sourceCode:has(pre.matlab)').forEach(function (block) {
      var label = el("div", {class: "hm-code-label"});
      label.appendChild(el("span", {}, "MATLAB CODE"));
      block.parentNode.insertBefore(label, block);
      block.setAttribute("data-hm-src", "matlab");
      block.querySelectorAll('span.va').forEach(function (token) {
        if (token.nextSibling && /^\\s*\\(/.test(token.nextSibling.textContent)) token.classList.add('hm-code-function');
      });
    });
    buildChapterNav();
    readingTime();
    buildKey();
    buildSplit();
    embedLinks();
    lightbox();
    anchors();
    scrollWatch(ui);
    keyboard(ui);
    window.addEventListener("resize", positionRail, { passive: true });
    setTimeout(positionRail, 300);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
"""
