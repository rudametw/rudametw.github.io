#!/usr/bin/env python3
"""publications.bib (HAL BibTeX) -> data/publications.yaml, preserving hand edits.

    ./scripts/fetch-hal-bibtex.sh && ./scripts/bib2yaml.py

Run by the author, by hand. No dependencies beyond the standard library.

Each entry in the YAML is flat. Two kinds of keys:

  from HAL (rewritten on every import):
      id, hal_id, title, authors, year, month, venue, address, doi, url, pdf, bibtype
  yours (kept across imports, never overwritten):
      type      journal | conference | workshop | chapter | thesis | hdr | report | other
                (guessed from HAL on first import; set it and the guess stops)
      rank      e.g. "CORE A*", "Rank A", "Q1"
      note      e.g. "Best paper award", "Invited paper", "Short paper"
      tags      list, free
      hide      true to keep an entry out of the page
      links     extra links: {slides: /docs/x.pdf, video: https://..., code: https://...}
      venue_short   e.g. "NDSS" — shown instead of the long booktitle when set

Entries that are not in HAL are fine: give them an `id` that does not start with
"hal-" (e.g. "manual-master-thesis") and no hal_id; they are kept as they are.
An entry that disappears from HAL is kept too (HAL sometimes drops versions);
delete it by hand if it is really gone.
"""
import re, sys, os, datetime

BIB = sys.argv[1] if len(sys.argv) > 1 else "publications.bib"
OUT = sys.argv[2] if len(sys.argv) > 2 else "data/publications.yaml"
MANUAL_KEYS = ("type", "rank", "note", "tags", "hide", "links", "venue_short")

# ---------------------------------------------------------------- BibTeX parsing
def parse_bib(text):
    entries = []
    for m in re.finditer(r'@(\w+)\s*\{\s*([^,\s]+)\s*,', text):
        kind, key = m.group(1).lower(), m.group(2)
        i, depth, start = m.end(), 1, m.end()
        while i < len(text) and depth:
            depth += {'{': 1, '}': -1}.get(text[i], 0); i += 1
        body = text[start:i-1]
        fields = {}
        for fm in re.finditer(r'(\w+)\s*=\s*(\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\}|"[^"]*"|[^,\n]+)\s*(?:,|$)', body, flags=re.S):
            fields[fm.group(1).lower()] = clean(fm.group(2))
        entries.append((kind, key, fields))
    return entries

LATEX = {r"\'e": "é", r"\`e": "è", r"\^e": "ê", r'\"e': "ë", r"\'a": "á", r"\`a": "à", r"\^a": "â",
         r"\'i": "í", r"\^i": "î", r'\"i': "ï", r"\'o": "ó", r"\^o": "ô", r'\"o': "ö", r"\'u": "ú",
         r"\`u": "ù", r"\^u": "û", r'\"u': "ü", r"\c{c}": "ç", r"\~n": "ñ", r"\&": "&", r"\_": "_",
         r"\%": "%", "--": "–", "---": "—", r"\'{e}": "é", r"\`{e}": "è", r"\^{e}": "ê", r'\"{o}': "ö",
         r'\"{u}': "ü", r"\'{a}": "á", r"\'{i}": "í", r"\'{o}": "ó", r"\'{u}": "ú", r"\~{n}": "ñ"}

def clean(v):
    v = v.strip()
    if v[:1] in '{"': v = v[1:-1]
    for k, r in sorted(LATEX.items(), key=lambda kv: -len(kv[0])): v = v.replace(k, r)
    v = re.sub(r'\{\\[a-zA-Z]+\s+([^{}]*)\}', r'\1', v)     # {\em x} -> x
    v = re.sub(r'\{\\[a-zA-Z]+\}', '', v)                   # {\ldots}
    v = v.replace('{', '').replace('}', '')
    return re.sub(r'\s+', ' ', v).strip()

def authors(s):
    out = []
    for a in re.split(r'\s+and\s+', s):
        a = a.strip()
        if ',' in a:
            last, first = [x.strip() for x in a.split(',', 1)]
            a = f"{first} {last}".strip()
        out.append(a)
    return out

MONTHS = {m.lower(): i for i, m in enumerate(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"], 1)}

def guess_type(kind, f):
    venue = (f.get('booktitle', '') + ' ' + f.get('journal', '') + ' ' + f.get('note', '')).lower()
    if kind == 'article':       return 'journal'
    if kind == 'inproceedings': return 'workshop' if 'workshop' in venue else 'conference'
    if kind in ('incollection', 'inbook'): return 'chapter'
    if kind == 'phdthesis':     return 'hdr' if ('habilitation' in venue or 'hdr' in venue or 'habilitation' in f.get('title','').lower()) else 'thesis'
    if kind == 'mastersthesis': return 'thesis'
    if kind in ('techreport', 'report'): return 'report'
    return 'other'

def to_entry(kind, key, f):
    e = {
        'id': f.get('hal_id', key),
        'hal_id': f.get('hal_id', key if key.startswith(('hal-', 'tel-', 'inria-')) else ''),
        'bibtype': kind,
        'title': f.get('title', ''),
        'authors': authors(f.get('author', '')),
        'year': int(re.search(r'\d{4}', f.get('year', '0')).group(0)) if re.search(r'\d{4}', f.get('year', '')) else 0,
        'month': MONTHS.get(f.get('month', '').lower()[:3], 0),
        'venue': f.get('booktitle') or f.get('journal') or f.get('school') or f.get('publisher') or f.get('note') or '',
        'address': f.get('address', ''),
        'doi': f.get('doi', ''),
        'url': f.get('url', ''),
        'pdf': f.get('pdf', ''),
    }
    e['type'] = guess_type(kind, f)
    return e

# ---------------------------------------------------------------- tiny YAML io
def yq(s):
    s = str(s)
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'

def dump(entries, out):
    lines = ["# data/publications.yaml — generated by scripts/bib2yaml.py from publications.bib",
             f"# (HAL, {datetime.date.today()}). HAL fields are rewritten on import; these are yours",
             "# and survive: type, rank, note, tags, hide, links, venue_short. See the script header.", ""]
    for e in entries:
        lines.append(f"- id: {yq(e['id'])}")
        for k in ('hal_id', 'bibtype', 'type', 'title'):
            if e.get(k): lines.append(f"  {k}: {yq(e[k])}")
        if e.get('authors'):
            lines.append("  authors:")
            lines += [f"    - {yq(a)}" for a in e['authors']]
        for k in ('year', 'month'):
            if e.get(k): lines.append(f"  {k}: {int(e[k])}")
        for k in ('venue', 'venue_short', 'address', 'rank', 'note', 'doi', 'url', 'pdf'):
            if e.get(k): lines.append(f"  {k}: {yq(e[k])}")
        if e.get('tags'):
            lines.append("  tags: [" + ", ".join(yq(t) for t in e['tags']) + "]")
        if e.get('hide'): lines.append("  hide: true")
        if e.get('links'):
            lines.append("  links:")
            lines += [f"    {k}: {yq(v)}" for k, v in e['links'].items()]
        lines.append("")
    os.makedirs(os.path.dirname(out) or '.', exist_ok=True)
    with open(out, 'w', encoding='utf-8') as fh: fh.write("\n".join(lines))

def load_existing(path):
    """Minimal reader for the file this script writes (flat entries, known keys)."""
    if not os.path.exists(path): return {}
    entries, cur, key = {}, None, None
    for raw in open(path, encoding='utf-8'):
        line = raw.rstrip('\n')
        if not line.strip() or line.lstrip().startswith('#'): continue
        if line.startswith('- id:'):
            cur = {'id': unq(line.split(':', 1)[1])}; entries[cur['id']] = cur; key = None; continue
        if cur is None: continue
        m = re.match(r'^  (\w+):\s*(.*)$', line)
        if m:
            k, v = m.group(1), m.group(2).strip(); key = k
            if v == '': cur[k] = [] if k in ('authors',) else {}
            elif v.startswith('['): cur[k] = [unq(x) for x in re.findall(r'"(?:[^"\\]|\\.)*"|[^,\[\]\s]+', v[1:-1])]
            elif v == 'true': cur[k] = True
            elif v.isdigit(): cur[k] = int(v)
            else: cur[k] = unq(v)
            continue
        m = re.match(r'^    - (.*)$', line)
        if m and key: cur.setdefault(key, []).append(unq(m.group(1))); continue
        m = re.match(r'^    (\w+):\s*(.*)$', line)
        if m and key: cur.setdefault(key, {})[m.group(1)] = unq(m.group(2)); continue
    return entries

def unq(s):
    s = s.strip()
    if s[:1] == '"' and s[-1:] == '"': return s[1:-1].replace('\\"', '"').replace('\\\\', '\\')
    return s

# ---------------------------------------------------------------- merge
def main():
    text = open(BIB, encoding='utf-8').read()
    fresh = [to_entry(*t) for t in parse_bib(text)]
    old = load_existing(OUT)
    merged, seen = [], set()
    for e in fresh:
        if e['id'] in old:
            for k in MANUAL_KEYS:
                if k in old[e['id']]: e[k] = old[e['id']][k]
        merged.append(e); seen.add(e['id'])
    kept = [old[k] for k in old if k not in seen]          # manual entries + ones HAL dropped
    merged += kept
    order = {'journal': 0, 'conference': 1, 'workshop': 2, 'chapter': 3, 'hdr': 4, 'thesis': 5, 'report': 6, 'other': 7}
    merged.sort(key=lambda e: (-int(e.get('year') or 0), -int(e.get('month') or 0), order.get(e.get('type', 'other'), 9), e.get('title', '')))
    dump(merged, OUT)
    print(f"{len(fresh)} from HAL, {len(kept)} kept from the previous file, {len(merged)} total -> {OUT}")

if __name__ == '__main__':
    main()
