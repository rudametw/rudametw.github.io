#!/usr/bin/env bash
# scripts/move-content.sh — phase 2: bring the Jekyll pages and posts into content/.
#
# Rule 6 applies: the words are the author's. This script MOVES text and fixes
# syntax only. Every transformation it performs is listed here:
#
#   posts      {% highlight LANG [linenos] %} ... {% endhighlight %}  ->  ```LANG ... ```
#              "####Title" -> "#### Title"   (Redcarpet made that a heading; CommonMark
#              needs the space or prints the hashes)
#              a lone "<br>" line gets a blank line after it (in CommonMark a raw
#              HTML line opens a block that swallows the Markdown that follows,
#              until a blank line; Redcarpet did not)
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
#   fragments  _includes/*.md were pulled into pages via
#              {% capture %}{% include X.md %}{% endcapture %}{{ … | markdownify }}.
#              Hugo has no include-and-markdownify; the fragment body is inlined
#              into the page's content file at the same spot. Words unchanged.
#   home       the google+ social button is removed (author's call)
#   home       src/index.html carries its own <head>, navbar and footer. Only the
#              body between the navbar and footer includes is content; the rest
#              is template (phase 3). Aliases /CICOMP/ (a stale copy of an old
#              home page) here.
#   publications  hand-written HTML, copied as-is into an .html content file.
#              One addition the author asked for: an "Up-to-date publications"
#              block (HAL + Scholar) and a TODO that the list stops at 2015. The
#              old scholar.google.fr link is replaced by the author's current one.
#              The bare ORCID/Scholar links under the <h1> are removed — they
#              now live as buttons in that block (author's call, 2026-09-11).
#   teaching   front-matter title had a stray "]" — removed. Nothing else.
#
# Idempotent: overwrites its own outputs, touches nothing else.

set -euo pipefail
export LC_ALL=C
export SELF="${BASH_SOURCE[0]}"

SRC="${SRC:-${HOME}/git/archive/jekyll-src/src}"
OUT="${OUT:-content}"
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
    /^<br>[[:space:]]*$/ { print "" }
  '
}
# fragment <name>      — an _includes/*.md, words unchanged, syntax fixed
fragment()     { commonmark < "${SRC}/_includes/$1"; }

# `--lib`: only define the functions above (used by the teaching awk callback).
[[ "${1:-}" == "--lib" ]] && return 0 2>/dev/null

mkdir -p "${OUT}/blog" "${OUT}/contact" "${OUT}/research" "${OUT}/teaching" "${OUT}/publications"

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

# ------------------------------------------------- fragment pages: contact, research
{ front_matter "${SRC}/contact/index.html"  | lille_era; fragment contact.md;  } > "${OUT}/contact/_index.md"
{ front_matter "${SRC}/research/index.html" | lille_era; fragment research.md; } > "${OUT}/research/_index.md"
for pair in \
  "cloud-monitoring-and-repair:cloud-dynamic-monitoring-and-repair.md" \
  "dynamic-application-consistency:dynamic-application-consistency.md" \
  "dynamic-apps-for-cloud-computing:dynamic-apps-cloud-computing.md" \
  "optimisation-applications-cloud:optimisation-applications-cloud.md"
do
  page="${pair%%:*}"; frag="${pair##*:}"
  { front_matter "${SRC}/research/${page}/index.html" | lille_era; fragment "${frag}"; } > "${OUT}/research/${page}.md"
done

# -------------------------------------------------------------------- teaching
# Wrapper HTML kept; each capture/include/markdownify triple becomes the fragment
# itself, surrounded by blank lines so Goldmark renders the Markdown inside <div>.
{
  front_matter "${SRC}/teaching/index.html" | sed 's/Rudametkin\]$/Rudametkin/' | lille_era
  body "${SRC}/teaching/index.html" | commonmark | awk -v src="${SRC}" '
    /\{% *capture my_include *%\}\{% *include / {
      match($0, /include +[^ %]+/); frag = substr($0, RSTART+8, RLENGTH-8)
      cmd = "bash -c '"'"'source " ENVIRON["SELF"] " --lib; commonmark'"'"' < " src "/_includes/" frag
      print ""; while ((cmd | getline line) > 0) print line; close(cmd); print ""
      next
    }
    /\{\{ *my_include *\| *markdownify *\}\}/ { next }
    { print }'
} > "${OUT}/teaching/_index.md"

# ---------------------------------------------------------------- publications
{
  front_matter "${SRC}/publications/index.html"
  cat <<'HTML'

<!-- TODO(author): this list stops at 2015. Update it by hand; do not let a
     script backfill it. Up-to-date sources are the buttons just below. -->
<div class="up-to-date-publications">
  <strong>Up-to-date publications:</strong>
  <a class="btn" href="https://inria.hal.science/search/index/?q=%2A&amp;rows=30&amp;authIdPerson_i=16377&amp;sort=publicationDate_tdate+desc" rel="noopener noreferrer"><i class="icon icon-hal"></i>HAL</a>
  <a class="btn" href="https://scholar.google.com/citations?user=vJQGm9kAAAAJ&amp;hl=fr&amp;oi=ao" rel="noopener noreferrer"><i class="icon icon-scholar"></i>Scholar</a>
  <a class="btn" href="https://orcid.org/0000-0003-2903-7600" rel="noopener noreferrer"><i class="icon icon-orcid"></i>ORCID</a>
</div>
HTML
  # The body's own ORCID + Scholar lines (between the <h1>'s <hr> and the next
  # <hr>) moved into the box above; drop them, keep one <hr>. Author's call.
  body "${SRC}/publications/index.html" \
    | awk '/^<h1>/{h=1} h && /^<hr>/{n++; if(n==1){print; skip=1; next} if(n==2){skip=0; h=0; next}} !skip' \
    | sed 's|http://scholar.google.fr/citations?user=vJQGm9kAAAAJ;\?|https://scholar.google.com/citations?user=vJQGm9kAAAAJ\&hl=fr\&oi=ao|g'
} > "${OUT}/publications/_index.html"

# ------------------------------------------------------------------------ home
{
  cat <<'YAML'
---
title: "Walter Rudametkin | Official Home Page | Sitio Oficial"
description: "Walter Rudametkin | Welcome to Walter's home page. Research, projects, blog or send him an email."
aliases:
  - /CICOMP/
---
YAML
  # body between `{% include navbar.html %}` and `{% include footer.html %}`,
  # minus the google+ button (author: drop google+ and brandyourself).
  awk '/\{% *include navbar\.html *%\}/{p=1; next} /\{% *include footer\.html *%\}/{p=0} p' "${SRC}/index.html" \
    | awk '/<li><a href="https:\/\/www\.google\.com\/\+WalterRudametkin"/{skip=1} skip && /<\/li>/{skip=0; next} !skip' 
} > "${OUT}/_index.html"

echo "content/ now:"; find "${OUT}" -type f | sort | sed 's/^/  /'
echo "leftover Liquid (must be empty):"; grep -rnE '\{%|\{\{' "${OUT}" || echo "  none"
