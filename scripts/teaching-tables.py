#!/usr/bin/env python3
"""Turn "slides | handouts-4pp | handouts-6pp | …" link paragraphs into tables.

Filter: Markdown in, Markdown out (stdin -> stdout). Used by move-content.sh on
the teaching page only. Author's call (2026-09-11): the course-material link
lists wrapped unpredictably as "a.pdf | a-handouts-4pp.pdf | …" text.

A paragraph is a candidate when it contains only links and "|" separators, has
two or more links, and every link after the first is a handout variant of the
first: its text either matches "handouts-Npp" or contains "handout". Anything
else (TD lists, mixed rows, single links) is passed through untouched — the
words are the author's, only the presentation of these rows changes.

Consecutive candidates become one <table class="course-files">; each row is:
  <th>  base name (first link text, ".pdf" stripped)
  <td>  the first link, labelled "Diapos"
  <td>  each variant, labelled "N / page" or its own text minus the base prefix
"""
import re, sys

LINK = re.compile(r'\[([^\]]+)\]\(([^)\s]+)\)')

def label(base, text, first):
    if first:
        return "Diapos"
    m = re.search(r'handouts-(\d+)pp', text)
    if m:
        return f"{m.group(1)} / page"
    t = re.sub(r'\.pdf$', '', text, flags=re.I)
    t = t[len(base):].strip(" -_") if t.lower().startswith(base.lower()) else t
    return t or "Handouts"

def candidate(par):
    links = LINK.findall(par)
    if len(links) < 2 or not re.fullmatch(r'[\s|]*', LINK.sub('', par)):
        return None
    if not all(re.search(r'handout', t, re.I) for t, _ in links[1:]):
        return None
    return links

def row(links):
    base = re.sub(r'\.pdf$', '', links[0][0], flags=re.I).strip()
    cells = ''.join(f'<td><a href="{u}">{label(base, t, i == 0)}</a></td>'
                    for i, (t, u) in enumerate(links))
    return f'<tr><th scope="row">{base}</th>{cells}</tr>'

def split_heading(part):
    """A row written directly under a '### Heading' line, with no blank line
    between, arrives in the same block. Peel the heading lines off."""
    lines = part.split('\n')
    i = 0
    while i < len(lines) and (not lines[i].strip() or lines[i].lstrip().startswith('#')):
        i += 1
    return '\n'.join(lines[:i]), '\n'.join(lines[i:])

def main():
    src = sys.stdin.read()
    parts = re.split(r'(\n[ \t]*\n)', src)          # keep the blank-line separators
    out, rows = [], []
    def flush():
        if rows:
            # Blank lines on both sides: in CommonMark an HTML block runs until a
            # blank line, so anything glued to </table> would render as raw text.
            out.append('\n\n<table class="course-files">\n' + '\n'.join(rows) + '\n</table>\n\n')
            rows.clear()
    for part in parts:
        if not part.strip():
            if not rows:
                out.append(part)
            continue                                    # blank between rows: swallowed
        heading, body = split_heading(part)
        links = candidate(body) if body.strip() else None
        if links:
            if heading.strip():
                flush(); out.append(heading + '\n')
            rows.append(row(links))
        else:
            flush(); out.append(part)
    flush()
    text = ''.join(out)
    sys.stdout.write(re.sub(r'\n{3,}', '\n\n', text))

if __name__ == '__main__':
    main()
