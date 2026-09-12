#!/usr/bin/env bash
# scripts/move-content.sh — phase 2: bring the Jekyll pages and posts into content/.
#
# Rule 6 applies: the words are the author's. This script MOVES text and fixes
# syntax only. Every transformation it performs is listed here:
#
#   posts      {% highlight LANG [linenos] %} ... {% endhighlight %}  ->  ```LANG ... ```
#              "####Title" -> "#### Title"   (Redcarpet made that a heading; CommonMark
#              needs the space or prints the hashes)
#              a lone "<br>" line that FOLLOWS a blank line gets a blank line after
#              it (there it opens an HTML block that swallows the Markdown after
#              it; Redcarpet did not). A "<br>" inside a paragraph — address and
#              name lists — is left alone, so those stay single-spaced.
#              an indented line that starts with a tag loses its indentation:
#              4+ spaces at the start of a block is an indented CODE block in
#              CommonMark, so the contact page's pretty-printed HTML rendered as
#              source. Only lines beginning with "<" are touched; Markdown list
#              nesting (which needs its indentation) never starts with "<".
#              a title containing "&#58;" (Jekyll's YAML-safe colon) becomes ":"
#              in a quoted YAML string; Hugo would otherwise show the entity
#              two posts get `url:` pinned (Hugo reads the dots in their names as
#              file extensions and truncates the slug)
#   all .md    the two Redcarpet-isms above are fixed in fragments as well
#   research   the five research pages are blog posts now (see research_post below)
#   fragments  _includes/*.md were pulled into pages via
#              {% capture %}{% include X.md %}{% endcapture %}{{ … | markdownify }}.
#              Hugo has no include-and-markdownify; the fragment body is inlined
#              into the page's content file at the same spot. Words unchanged.
#   home, contact  NOT generated any more (2026-09-11): both are hand-written
#              from the author's new profile and contact details. The old
#              bodies remain in the archive.
#   teaching   every course title gets an [archived] tag (author's call);
#              "slides | handouts-4pp | …" link rows become tables
#              (scripts/teaching-tables.py; author's call, presentation only).
#   publications  front matter only; the list is rendered from data/publications.yaml
#              (see scripts/bib2yaml.py). The 2015 hand-written table is retired.
#   teaching   front-matter title had a stray "]" — removed. Nothing else.
#
# Idempotent: overwrites its own outputs, touches nothing else.

set -euo pipefail
export LC_ALL=C
export SELF="${BASH_SOURCE[0]}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # repo root, whatever the cwd
SRC="${SRC:-${HOME}/git/archive/jekyll-src/src}"
OUT="${OUT:-${ROOT}/content}"
[[ -d "${SRC}/_posts" ]] || { echo "source not found: ${SRC}" >&2; exit 2; }

# front_matter <file>  — print the YAML block of a Jekyll page, delimiters included
front_matter() { awk 'NR==1 && /^---/{p=1; print; next} p && /^---/{print; exit} p{print}' "$1"; }
# lille_era <fm>       — adds `archived: lille` to a front-matter block. The
#                        research, teaching and contact pages were written at the
#                        University of Lille (Polytech Lille, Spirals), before the
#                        author moved to Rennes in September 2022. The template
#                        shows a notice; the words below it are untouched.
lille_era()    { sed '$i archived: lille'; }
# body <file>          — everything after the front matter
body()         { awk 'NR==1 && /^---/{p=1; next} p==1 && /^---/{p=2; next} p==2{print}' "$1"; }
# commonmark            — Redcarpet -> CommonMark syntax fixes, applied to every
#                        Markdown file that comes across. Fence-aware: nothing
#                        inside a ``` block is touched (bash comments start with #).
commonmark() {
  awk '
    /^```/            { infence = !infence; print; next }
    infence           { print; next }
    /^#{1,6}[^# ]/    { sub(/^#+/, "&" " ") }
    /^[[:space:]]+</  { sub(/^[[:space:]]+/, "") }
    { print }
    prevblank && /^<br>[[:space:]]*$/ { print "" }
    { prevblank = ($0 ~ /^[[:space:]]*$/) }
  '
}
# fragment <name>      — an _includes/*.md, words unchanged, syntax fixed
fragment()     { commonmark < "${SRC}/_includes/$1"; }

# `--lib`: only define the functions above (used by the teaching awk callback).
[[ "${1:-}" == "--lib" ]] && return 0 2>/dev/null

mkdir -p "${OUT}/blog" "${OUT}/teaching" "${OUT}/publications"

# ---------------------------------------------------------------- posts (12)
for f in "${SRC}"/_posts/*.md; do
  name=$(basename "$f")
  sed -E \
    -e 's/\{% *highlight +([A-Za-z0-9_+-]+)( +linenos)? *%\}/```\1/' \
    -e 's/\{% *endhighlight *%\}/```/' \
    "$f" | commonmark \
    | awk 'NR<=6 && /^title: .*&#[0-9]+;/ { gsub(/&#58;/, ":"); t = substr($0, 8); gsub(/\047/, "\047\047", t); $0 = "title: \047" t "\047" } { print }' \
    > "${OUT}/blog/${name}"
done
# Two slugs contain dots. Hugo reads them as file extensions and would emit
# Linux-webdav-box.html and Acrobat-reader-cannot-find-libEGL.html. Pin the URL.
sed -i '1a url: /blog/posts/2011.09.17/Linux-webdav-box.net.html' \
  "${OUT}/blog/2011-09-17-Linux-webdav-box.net.md"
sed -i '1a url: /blog/posts/2014.03.19/Acrobat-reader-cannot-find-libEGL.so.1-Fedora-20.html' \
  "${OUT}/blog/2014-03-19-Acrobat-reader-cannot-find-libEGL.so.1-Fedora-20.md"

cat > "${OUT}/blog/_index.md" <<'MD'
---
title: Blog
outputs: [HTML, RSS]   # the one feed on the site; see hugo.toml [outputs]
---
MD

# ------------------------------------------- research pages -> blog posts (2026-09-12)
# Author's call: the Research tab showed 2014-2015 Lille-era position offers and
# nothing current. Each page becomes a dated blog post (date = first commit of
# the fragment, from git history), tagged by topic, stamped `archived: lille`,
# with the old /research/... URL kept as an alias so the URL contract holds.
# Words unchanged. Syntax changes, per post:
#   - the first heading is dropped when it equals the post title (the template
#     prints the title), otherwise demoted one level ("Open Ph.D. Position")
#   - the Ph.D. pages' "<a href=X.pdf><h1>Title</h1></a>" becomes "[Title](/research/<dir>/X.pdf)"
#   - relative "X.pdf" links become absolute /research/<dir>/X.pdf (the PDFs are static)
#   - the index page's relative links point at the new posts
research_post() {  # <date> <slug> <fragment> <old dir> <title> <categories>
  local date="$1" slug="$2" frag="$3" dir="$4" title="$5" cats="$6" alias
  # Spelled out to index.html: the blog section has uglyURLs, and Hugo applies
  # that to a post's aliases too, so "/research/x/" would be written "/research/x.html".
  alias="/research/${dir:+$dir/}index.html"
  {
    printf -- '---\ntitle: "%s"\nplace: Lille, France\ncategories: [%s]\narchived: lille\naliases:\n  - %s\n---\n\n' "$title" "$cats" "$alias"
    fragment "$frag" \
      | python3 -c '
import re,sys
dir_, title = sys.argv[1], sys.argv[2]; s=sys.stdin.read()
# first heading: drop it when it is the title (the template prints the title),
# otherwise keep it one level down (e.g. "Open Ph.D. Position" above the summary)
lines=s.split("\n")
for i,l in enumerate(lines):
    if not l.strip() or l.lstrip().startswith("<!--"): continue
    m=re.match(r"^(#+)\s*(.*?)\s*$", l)
    if m:
        lines[i] = "" if m.group(2).lower()==title.lower() else "## "+m.group(2)
    break
s="\n".join(lines)
s=re.sub(r"<a href=\"([^\"/]+\.pdf)\">\s*<h1>\s*(.*?)\s*</h1>\s*</a>", lambda m: f"[{m.group(2)}](/research/{dir_}/{m.group(1)})", s, flags=re.S)
s=re.sub(r"(href=\"|\]\()([^\"/)#]+\.pdf)", lambda m: f"{m.group(1)}/research/{dir_}/{m.group(2)}", s)
sys.stdout.write(s)' "$dir" "$title"
  } > "${OUT}/blog/${date}-${slug}.md"
}
research_post 2015-01-15 cloud-monitoring-and-repair     cloud-dynamic-monitoring-and-repair.md cloud-monitoring-and-repair \
  "Dynamic monitoring to find and diagnose software bugs in cloud applications" "positions, phd, cloud, monitoring"
research_post 2015-01-15 dynamic-application-consistency dynamic-application-consistency.md     dynamic-application-consistency \
  "Static analysis and runtime monitoring to ensure the consistency of dynamic applications" "positions, phd, dynamic-software, static-analysis"
research_post 2014-09-11 dynamic-apps-for-cloud-computing dynamic-apps-cloud-computing.md       dynamic-apps-for-cloud-computing \
  "Applications Dynamiques pour le Cloud Computing" "positions, master, cloud, dynamic-software"
research_post 2014-10-24 optimisation-applications-cloud optimisation-applications-cloud.md     optimisation-applications-cloud \
  "Gestion et Optimisation d’Applications dans le Cloud" "positions, master, cloud, optimisation"
research_post 2014-09-11 open-positions                  research.md                            "" \
  "Open positions" "positions, phd, master"
# the index post linked its proposals by relative name; point them at the posts
sed -i -e 's|](optimisation-applications-cloud)|](/blog/posts/2014.10.24/optimisation-applications-cloud.html)|' \
       -e 's|](dynamic-apps-for-cloud-computing)|](/blog/posts/2014.09.11/dynamic-apps-for-cloud-computing.html)|' \
       -e 's|](dynamic-application-consistency)|](/blog/posts/2015.01.15/dynamic-application-consistency.html)|' \
       -e 's|](cloud-monitoring-and-repair)|](/blog/posts/2015.01.15/cloud-monitoring-and-repair.html)|' \
       "${OUT}/blog/2014-09-11-open-positions.md"

# -------------------------------------------------------------------- teaching
# Wrapper HTML kept; each capture/include/markdownify triple becomes the fragment
# itself, surrounded by blank lines so Goldmark renders the Markdown inside <div>.
{
  front_matter "${SRC}/teaching/index.html" | sed 's/Rudametkin\]$/Rudametkin/'
  body "${SRC}/teaching/index.html" | commonmark | awk -v src="${SRC}" '
    /\{% *capture my_include *%\}\{% *include / {
      match($0, /include +[^ %]+/); frag = substr($0, RSTART+8, RLENGTH-8)
      cmd = "bash -c '"'"'source " ENVIRON["SELF"] " --lib; commonmark'"'"' < " src "/_includes/" frag
      print ""; while ((cmd | getline line) > 0) print line; close(cmd); print ""
      next
    }
    /\{\{ *my_include *\| *markdownify *\}\}/ { next }
    { print }'
} | sed -E 's|^# (.+)$|# \1 <span class="tag tag-archived">archived in 2022</span>|' \
  | python3 "$(dirname "${BASH_SOURCE[0]}")/teaching-tables.py" \
  | python3 "$(dirname "${BASH_SOURCE[0]}")/teaching-esir.py" "$(dirname "${BASH_SOURCE[0]}")/fragments/teaching-esir.md" > "${OUT}/teaching/_index.md"
# ^ every Lille course title gets the pill (author: "archived in 2022"); the
#   page-level notice was dropped on 2026-09-12 at the author's request.
#   scripts/fragments/teaching-esir.md is the author-owned ESIR entry.

# ---------------------------------------------------------------- publications
# Since 2026-09-12 the list comes from data/publications.yaml (fetch-hal-bibtex.sh +
# bib2yaml.py) and layouts/publications/section.html; the 2015 hand-written table
# from src/publications/index.html is retired (its non-HAL entries were moved into
# the YAML by hand). This page is just the section's front matter.
cat > "${OUT}/publications/_index.md" <<'MD'
---
title: Publications
description: "Publications of Walter Rudametkin: journal and conference papers, theses, demonstrations and talks. Kept in sync with HAL."
---
MD

# ------------------------------------------------------------------------ home
# content/_index.html is HAND-WRITTEN since 2026-09-11 (profile rewritten by the
# author's brief: Rennes / IRISA / Inria / IUF, privacy & security focus). The old
# Jekyll body is no longer copied. Do not add it back here.

echo "content/ now:"; find "${OUT}" -type f | sort | sed 's/^/  /'
echo "leftover Liquid (must be empty):"; grep -rnE '\{%|\{\{' "${OUT}" || echo "  none"
