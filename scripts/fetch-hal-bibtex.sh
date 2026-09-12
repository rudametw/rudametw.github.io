#!/usr/bin/env bash
# scripts/fetch-hal-bibtex.sh — download the author's publications from HAL as BibTeX.
#
#   ./scripts/fetch-hal-bibtex.sh            # writes <repo>/publications.bib
#   ./scripts/bib2yaml.py                    # then: publications.bib -> data/publications.yaml
# (or ./scripts/update-publications-from-hal.sh for both). Runs from any cwd.
#
# Run by the author, by hand, when HAL has something new. Never by CI (rule 2).
# authIdPerson_i is the HAL author id from the profile's search URL.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # repo root, whatever the cwd
AUTHOR_ID="${HAL_AUTHOR_ID:-16377}"
OUT="${1:-${ROOT}/publications.bib}"
URL="https://api.archives-ouvertes.fr/search/?q=authIdPerson_i:${AUTHOR_ID}&wt=bibtex&rows=5000&sort=producedDate_tdate%20desc"
curl -fsSL --max-time 120 "$URL" -o "${OUT}.tmp"
n=$(grep -c '^@' "${OUT}.tmp" || true)
if (( n == 0 )); then echo "no entries in the HAL response; kept the old ${OUT}" >&2; rm -f "${OUT}.tmp"; exit 1; fi
mv "${OUT}.tmp" "$OUT"
echo "wrote ${OUT}: ${n} entries"
