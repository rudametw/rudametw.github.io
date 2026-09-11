#!/usr/bin/env bash
# check-urls.sh — verify the Hugo build preserves every URL the old Jekyll site served.
#
# Three modes:
#   ./check-urls.sh --inventory-archive   build urls-before.txt offline from the
#                                         `jekyll-final` worktree (preferred)
#   ./check-urls.sh --inventory           build urls-before.txt from the LIVE
#                                         sitemap.xml + a live crawl (needs network)
#   ./check-urls.sh                       verify public/ against urls-before.txt
#
# Exit 0 = contract satisfied. Exit 1 = missing URLs.

set -euo pipefail

# comm(1) requires both inputs sorted in the SAME collation as the sort that
# produced them. Pin it so the script behaves identically under any locale.
export LC_ALL=C

SITE_URL="${SITE_URL:-https://rudametw.github.io}"
PUBLIC_DIR="${PUBLIC_DIR:-public}"
CONTRACT="${CONTRACT:-urls-before.txt}"
ORPHANS="${ORPHANS:-urls-orphans.txt}"
CRAWL_DIR="${CRAWL_DIR:-${HOME}/git/archive/old-site-crawl}"
ARCHIVE="${ARCHIVE:-${HOME}/git/archive/jekyll-src}"

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
amber() { printf '\033[33m%s\033[0m\n' "$*"; }

# Percent-decode, so a sitemap's /docs/A%20B.pdf compares equal to the file
# `A B.pdf` that `find` reports. Applied to both sides of every comparison.
urldecode() {
  sed -e 's|%\([0-9A-Fa-f][0-9A-Fa-f]\)|\\x\1|g' \
      -e 's|\\\\|\\\\\\\\|g' \
  | while IFS= read -r line; do printf '%b\n' "${line}"; done
}

# Normalise a path to its canonical served form:
#   https://host/foo/index.html -> /foo/
#   http://host/foo/            -> /foo/      (scheme-insensitive: see below)
#   /foo.html                   -> /foo.html  (kept: it is a distinct served URL)
#   /                           -> /
#
# The scheme and host are stripped by pattern, NOT by matching ${SITE_URL}.
# Jekyll's _config.yml declared `url: http://rudametw.github.io`, so every <loc>
# in the generated sitemap is http://, while the site is served over https with
# a 301 from http. Anchoring on ${SITE_URL} left all 218 sitemap entries
# unstripped and the contract file full of `/http://rudametw.github.io/...`.
# The contract is a set of PATHS; scheme and host are not part of it.
normalise() {
  sed -e 's|^[a-zA-Z][a-zA-Z0-9+.-]*://[^/]*||' \
      -e 's|index\.html$||' \
      -e 's|^$|/|' \
      -e 's|^\([^/]\)|/\1|' \
  | urldecode
}

# Vendored third-party junk. Never site content, even where it was served and
# (for /fancybox/demo/) even where jekyll-sitemap listed it. Dropped from the
# contract on the author's instruction: Bootstrap, jQuery and fancybox all go
# away under hard constraint 1b, so preserving their demo pages is pointless.
prune_vendor() {
  grep -v -e '^/fancybox/' -e '^/font-awesome/' -e '^/node_modules/'
}

# sitemap.xml cannot appear in its own <loc> list, so it always looks like an
# orphan. It is not one — Hugo generates it. Drop it from the orphan report only.
prune_orphan_noise() {
  grep -v -e '^/sitemap\.xml$'
}

write_contract() {
  local all="$1" orphans="$2"
  printf '%s\n' "${all}" | sort -u > "${CONTRACT}"
  printf '%s\n' "${orphans}" | grep . | prune_orphan_noise > "${ORPHANS}" || : > "${ORPHANS}"

  green "Wrote ${CONTRACT} ($(grep -c . "${CONTRACT}") URLs)"
  if [[ -s "${ORPHANS}" ]]; then
    amber "Wrote ${ORPHANS} ($(grep -c . "${ORPHANS}") URLs served but not in sitemap)"
    amber "  -> review these by hand: keep, redirect via aliases, or drop."
  else
    green "No orphans."
  fi
}

# Offline inventory from the pinned `jekyll-final` worktree. Preferred over the
# live crawl: it is the exact pre-migration state, needs no network, and unlike
# wget's link-following it cannot silently miss pages.
build_inventory_archive() {
  [[ -d "${ARCHIVE}" ]] || {
    red "${ARCHIVE} not found."
    red "Recreate with: git worktree add ${ARCHIVE} jekyll-final"
    exit 2
  }
  [[ -f "${ARCHIVE}/sitemap.xml" ]] || { red "${ARCHIVE}/sitemap.xml not found"; exit 2; }

  echo "==> Reading ${ARCHIVE}/sitemap.xml"
  local sitemap_urls
  sitemap_urls=$(grep -o '<loc>[^<]*</loc>' "${ARCHIVE}/sitemap.xml" \
    | sed -e 's|<loc>||' -e 's|</loc>||' \
    | normalise | prune_vendor | sort -u)

  # The worktree root is the *built* site as committed (the old `cp -uvarf`
  # flow). src/ is the Jekyll source and is not served.
  echo "==> Scanning built output at ${ARCHIVE}"
  local built_urls
  built_urls=$(cd "${ARCHIVE}" && find . \
      \( -path ./src -o -path ./.git \) -prune -o \
      \( -name '*.html' -o -name '*.pdf' -o -name '*.xml' \) -print \
    | sed 's|^\.||' | normalise | prune_vendor | sort -u)

  write_contract \
    "$(printf '%s\n%s\n' "${sitemap_urls}" "${built_urls}")" \
    "$(comm -13 <(printf '%s\n' "${sitemap_urls}") <(printf '%s\n' "${built_urls}"))"
}

build_inventory() {
  command -v wget >/dev/null || { red "wget required"; exit 2; }

  echo "==> Fetching sitemap.xml"
  local sitemap_urls
  sitemap_urls=$(curl -fsSL "${SITE_URL}/sitemap.xml" \
    | grep -o '<loc>[^<]*</loc>' \
    | sed -e 's|<loc>||' -e 's|</loc>||' \
    | normalise | prune_vendor | sort -u) || { red "sitemap.xml unreachable"; exit 2; }

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
      crawl
    fi
  else
    crawl
  fi

  local crawl_urls
  crawl_urls=$(find "${CRAWL_DIR}" \( -name '*.html' -o -name '*.pdf' \) \
    | sed "s|^${CRAWL_DIR}/[^/]*||" \
    | normalise | prune_vendor | sort -u)

  local n_crawl n_sitemap
  n_crawl=$(printf '%s\n' "${crawl_urls}" | grep -c . || true)
  n_sitemap=$(printf '%s\n' "${sitemap_urls}" | grep -c . || true)
  if (( n_crawl < n_sitemap / 2 )); then
    amber "Crawl found ${n_crawl} URLs but the sitemap lists ${n_sitemap}."
    amber "  -> wget's link-following missed pages; prefer --inventory-archive."
  fi

  # Contract = sitemap ∪ crawl. Orphans = crawl \ sitemap (stale files left behind
  # by years of `cp -uvarf` never deleting anything).
  write_contract \
    "$(printf '%s\n%s\n' "${sitemap_urls}" "${crawl_urls}")" \
    "$(comm -13 <(printf '%s\n' "${sitemap_urls}") <(printf '%s\n' "${crawl_urls}"))"
}

# Seed wget from the sitemap as well as the root, so a broken or JS-driven link
# cannot drop a whole section from the capture.
crawl() {
  local seeds
  seeds=$(mktemp)
  printf '%s\n' "${sitemap_urls}" | sed "s|^|${SITE_URL}|" > "${seeds}"
  wget --mirror --no-parent --quiet --adjust-extension \
       --reject-regex '\.(jpg|jpeg|png|gif|svg|zip|mp4|webp)$' \
       --input-file="${seeds}" \
       -P "${CRAWL_DIR}" "${SITE_URL}/" || true
  rm -f "${seeds}"
}

verify() {
  [[ -f "${CONTRACT}" ]] || { red "${CONTRACT} not found. Run: $0 --inventory-archive"; exit 2; }
  [[ -d "${PUBLIC_DIR}" ]] || { red "${PUBLIC_DIR}/ not found. Run: hugo --minify"; exit 2; }

  local built
  built=$(find "${PUBLIC_DIR}" \( -name '*.html' -o -name '*.xml' -o -name '*.pdf' \) \
    | sed "s|^${PUBLIC_DIR}||" | normalise | sort -u)

  # Hugo writes alias stubs as real files, so they appear in `built` automatically.
  local missing
  missing=$(comm -23 "${CONTRACT}" <(printf '%s\n' "${built}") || true)

  local n_contract n_built n_missing
  n_contract=$(grep -c . "${CONTRACT}" || true)
  n_built=$(printf '%s\n' "${built}" | grep -c . || true)
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
  --inventory-archive) build_inventory_archive ;;
  --inventory)         build_inventory ;;
  ""|--verify)         verify ;;
  *) echo "usage: $0 [--inventory-archive|--inventory|--verify]"; exit 2 ;;
esac
