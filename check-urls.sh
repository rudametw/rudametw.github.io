#!/usr/bin/env bash
# check-urls.sh — verify the Hugo build preserves every URL the old Jekyll site served.
#
# Two modes:
#   ./check-urls.sh --inventory   build urls-before.txt from sitemap.xml + a live crawl
#   ./check-urls.sh               verify public/ against urls-before.txt  (default)
#
# Exit 0 = contract satisfied. Exit 1 = missing URLs.

set -euo pipefail

SITE_URL="${SITE_URL:-https://rudametw.github.io}"
PUBLIC_DIR="${PUBLIC_DIR:-public}"
CONTRACT="${CONTRACT:-urls-before.txt}"
ORPHANS="${ORPHANS:-urls-orphans.txt}"
CRAWL_DIR="${CRAWL_DIR:-${HOME}/git/archive/old-site-crawl}"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
amber() { printf '\033[33m%s\033[0m\n' "$*"; }

# Normalise a path to its canonical served form:
#   /foo/index.html -> /foo/
#   /foo.html       -> /foo.html   (kept: it is a distinct served URL)
#   /               -> /
normalise() {
  sed -e 's|^'"${SITE_URL}"'||' \
      -e 's|index\.html$||' \
      -e 's|^$|/|' \
      -e 's|^\([^/]\)|/\1|'
}

build_inventory() {
  command -v wget >/dev/null || { red "wget required"; exit 2; }

  echo "==> Fetching sitemap.xml"
  local sitemap_urls
  sitemap_urls=$(curl -fsSL "${SITE_URL}/sitemap.xml" \
    | grep -o '<loc>[^<]*</loc>' \
    | sed -e 's|<loc>||' -e 's|</loc>||' \
    | normalise | sort -u) || { red "sitemap.xml unreachable"; exit 2; }

  echo "==> Crawling ${SITE_URL} -> ${CRAWL_DIR}"
  if [[ -d "${CRAWL_DIR}" ]]; then
    # The crawl doubles as the archived rendering oracle. Refuse to clobber it
    # unless the caller explicitly asks for a re-crawl.
    if [[ "${RECRAWL:-0}" != "1" ]]; then
      amber "${CRAWL_DIR} already exists; reusing it."
      amber "  -> to fetch a fresh copy: RECRAWL=1 $0 --inventory"
    else
      amber "RECRAWL=1: replacing ${CRAWL_DIR}"
      rm -rf "${CRAWL_DIR:?refusing to rm with empty CRAWL_DIR}"
      wget --mirror --no-parent --quiet --adjust-extension \
           --reject-regex '\.(jpg|jpeg|png|gif|svg|pdf|zip|mp4|webp)$' \
           -P "${CRAWL_DIR}" "${SITE_URL}/" || true
    fi
  else
    wget --mirror --no-parent --quiet --adjust-extension \
         --reject-regex '\.(jpg|jpeg|png|gif|svg|pdf|zip|mp4|webp)$' \
         -P "${CRAWL_DIR}" "${SITE_URL}/" || true
  fi

  local crawl_urls
  crawl_urls=$(find "${CRAWL_DIR}" -name '*.html' \
    | sed "s|^${CRAWL_DIR}/[^/]*||" \
    | normalise | sort -u)

  # Contract = sitemap ∪ crawl. Orphans = crawl \ sitemap (stale files left behind
  # by years of `cp -uvarf` never deleting anything).
  printf '%s\n%s\n' "${sitemap_urls}" "${crawl_urls}" | sort -u > "${CONTRACT}"
  comm -13 <(printf '%s\n' "${sitemap_urls}") <(printf '%s\n' "${crawl_urls}") > "${ORPHANS}"

  green "Wrote ${CONTRACT} ($(wc -l < "${CONTRACT}") URLs)"
  if [[ -s "${ORPHANS}" ]]; then
    amber "Wrote ${ORPHANS} ($(wc -l < "${ORPHANS}") URLs served but not in sitemap)"
    amber "  -> review these by hand: keep, redirect via aliases, or drop."
  fi
}

verify() {
  [[ -f "${CONTRACT}" ]] || { red "${CONTRACT} not found. Run: $0 --inventory"; exit 2; }
  [[ -d "${PUBLIC_DIR}" ]] || { red "${PUBLIC_DIR}/ not found. Run: hugo --minify"; exit 2; }

  local built
  built=$(find "${PUBLIC_DIR}" \( -name '*.html' -o -name '*.xml' -o -name '*.pdf' \) \
    | sed "s|^${PUBLIC_DIR}||" | normalise | sort -u)

  # Hugo writes alias stubs as real files, so they appear in `built` automatically.
  local missing
  missing=$(comm -23 "${CONTRACT}" <(printf '%s\n' "${built}") || true)

  local n_contract n_built n_missing
  n_contract=$(wc -l < "${CONTRACT}")
  n_built=$(printf '%s\n' "${built}" | wc -l)
  n_missing=$(printf '%s' "${missing}" | grep -c . || true)

  echo "contract: ${n_contract}  built: ${n_built}  missing: ${n_missing}"

  if (( n_missing > 0 )); then
    red "MISSING (${n_missing}):"
    printf '%s\n' "${missing}" | sed 's/^/  MISSING /'
    echo
    amber "Fix by adding to the relevant page's front matter:"
    amber "  aliases:"
    amber "    - /the/missing/path/"
    amber "Do NOT edit ${CONTRACT}."
    return 1
  fi

  green "All ${n_contract} contract URLs present."

  # Informational: pages we now serve that did not exist before. Usually fine
  # (taxonomy pages, pagination), but worth a glance for accidental duplicates.
  local added
  added=$(comm -13 "${CONTRACT}" <(printf '%s\n' "${built}") || true)
  if [[ -n "${added}" ]]; then
    echo "new URLs (informational): $(printf '%s' "${added}" | grep -c .)"
  fi
  return 0
}

case "${1:-}" in
  --inventory) build_inventory ;;
  ""|--verify) verify ;;
  *) echo "usage: $0 [--inventory|--verify]"; exit 2 ;;
esac
