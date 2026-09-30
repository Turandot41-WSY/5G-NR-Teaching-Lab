"""Explicit Obsidian semantics shared by every public Markdown export."""
import re

ALIASES = {'author': 'important', 'failure': 'warning', 'reading': 'note',
           'info': 'note', 'tip': 'note', 'example': 'note', 'sharetechnote': 'engineering'}
KINDS = {'important', 'warning', 'note', 'book', 'spec', 'engineering', 'matlab', 'result'}


def protect_code(text):
    """Hide fenced and inline code while Markdown extensions are converted."""
    saved = []
    pattern = re.compile(r'(?m)^ {0,3}(`{3,}|~{3,})[^\n]*\n[\s\S]*?^ {0,3}\1[ \t]*(?=\n|$)|(`+)[^`]*?\2')
    def hold(match):
        saved.append(match.group())
        return f'ANNOTATIONCODEPLACEHOLDER{len(saved)-1}END'
    return pattern.sub(hold, text), saved


def restore_code(text, saved):
    for i, value in enumerate(saved):
        text = text.replace(f'ANNOTATIONCODEPLACEHOLDER{i}END', value)
    return text


def convert(text):
    text, code = protect_code(text)
    # Balanced brackets preserve links, wikilinks and array subscripts.
    marker = re.compile(r'(?<![\\\w])!(important|warning|note)\[')
    parts, cursor = [], 0
    for match in marker.finditer(text):
        if match.start() < cursor:
            continue
        depth, end = 1, match.end()
        while end < len(text) and depth:
            if text[end] == '\\':
                end += 2
                continue
            if text[end] == '[': depth += 1
            if text[end] == ']': depth -= 1
            end += 1
        if depth:
            line = text.count('\n', 0, match.start()) + 1
            raise ValueError(f'Unclosed !{match[1]}[...] annotation at line {line}')
        body = text[match.end():end-1]
        before = text[text.rfind('\n', 0, match.start())+1:match.start()]
        after = text[end:text.find('\n', end) if '\n' in text[end:] else len(text)]
        if not before.strip() and not after.strip():
            replacement = f'\n:::: {{.hm-annotation data-hm-kind="{match[1]}"}}\n\n{body}\n\n::::\n'
        else:
            if '\n' in body:
                raise ValueError('A multiline annotation must occupy its own paragraph')
            replacement = f'[{body}]{{.hm-inline-annotation data-hm-kind="{match[1]}"}}'
        parts.extend((text[cursor:match.start()], replacement))
        cursor = end
    parts.append(text[cursor:])
    lines, output, i = ''.join(parts).splitlines(), [], 0
    header = re.compile(r'^\s*> \[!(\w+)\][-+]?\s*(.*)$')
    while i < len(lines):
        m = header.match(lines[i])
        if not m:
            output.append(lines[i]); i += 1; continue
        kind = ALIASES.get(m[1].lower(), m[1].lower())
        if kind not in KINDS: kind = 'note'
        title = m[2].replace('"', "'")
        base = kind if kind in ('important', 'warning') else 'note'
        output.extend(('', f'::: {{.callout-{base} data-hm-kind="{kind}" title="{title}"}}'))
        i += 1
        while i < len(lines) and not header.match(lines[i]):
            if re.match(r'^\s*>', lines[i]):
                output.append(re.sub(r'^\s*> ?', '', lines[i])); i += 1
            elif not lines[i].strip():
                output.append(''); i += 1
            else:
                break
        output.extend((':::', ''))
    return restore_code('\n'.join(output) + '\n', code)
