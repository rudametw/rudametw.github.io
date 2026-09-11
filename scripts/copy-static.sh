#!/usr/bin/env bash
# scripts/copy-static.sh — bring the old site's served, non-page files into static/.
#
# Idempotent: re-running copies only what is missing (cp -n). Never deletes.
# Source is the read-only jekyll-final worktree; its ROOT is the built site.
#
# What comes across and why (decisions recorded in CLAUDE.md, 2026-09-11):
#   docs/          everything          all /docs/* are keepers (author ruling)
#   teaching/      course material     PDFs are URL-contract items; .ods/.sql are
#                                      the exercises those PDFs refer to
#   research/      PDFs                contract items
#   img/           web images          pages reference them; .xcf GIMP sources
#                                      are not web content and stay behind
#   photos/        NOT copied          6 blog-post images were copied by hand
#                                      earlier; the galleries are retired
#   root files     favicon, robots, Google verification, .nojekyll,
#                  projet-al redirect stub (served verbatim)
#
# Deliberately left behind: fancybox/ font-awesome/ fonts/ assets/ (rule 1b —
# Bootstrap/jQuery/fancybox go away), *.py/*.sh author tooling under teaching/,
# advancedsettings.xml (a Kodi config that was never site content), the built
# HTML pages (content phase), sitemap.xml (Hugo generates it).

set -euo pipefail
export LC_ALL=C

SRC="${SRC:-${HOME}/git/archive/jekyll-src}"
DST="${DST:-static}"

[[ -d "${SRC}/docs" ]] || { echo "source not found: ${SRC}" >&2; exit 2; }

n=0
copy() {  # copy <relative path>
  local rel="$1"
  mkdir -p "${DST}/$(dirname "${rel}")"
  if cp -n "${SRC}/${rel}" "${DST}/${rel}"; then n=$((n+1)); fi
}

# docs/: every file, whatever the extension — except diverse-logo-pngs.zip
# (16 MB, author dropped it 2026-09-11; the svg and fonts kits stay).
while IFS= read -r f; do copy "${f#"${SRC}"/}"; done < <(
  find "${SRC}/docs" -type f ! -name 'diverse-logo-pngs.zip'
)

# teaching/ and research/: documents and exercise files, not pages or tooling.
while IFS= read -r f; do copy "${f#"${SRC}"/}"; done < <(
  find "${SRC}/teaching" "${SRC}/research" -type f \
    \( -name '*.pdf' -o -name '*.ods' -o -name '*.sql' -o -name '*.zip' \)
)

# img/: web images only.
while IFS= read -r f; do copy "${f#"${SRC}"/}"; done < <(
  find "${SRC}/img" -type f ! -name '*.xcf'
)

# Root files served verbatim.
for f in favicon.ico google462956b09535940b.html .nojekyll projet-al/index.html; do
  copy "$f"
done

# robots.txt: the old one advertised the http:// sitemap. Same file, https.
mkdir -p "${DST}"
if [[ ! -f "${DST}/robots.txt" ]]; then
  sed 's|http://rudametw.github.io|https://rudametw.github.io|' "${SRC}/robots.txt" > "${DST}/robots.txt"
  n=$((n+1))
fi

echo "copied ${n} new file(s) into ${DST}/"
echo "static/ now holds $(find "${DST}" -type f | wc -l) files, $(du -sh "${DST}" | cut -f1)"
