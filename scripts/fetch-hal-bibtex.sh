#!/usr/bin/env bash
# scripts/fetch-hal-bibtex.sh — download the author's publications from HAL as BibTeX.
#
#   ./scripts/fetch-hal-bibtex.sh            # writes publications.bib
#   ./scripts/bib2yaml.py                    # then: publications.bib -> data/publications.yaml
#
# Run by the author, by hand, when HAL has something new. Never by CI (rule 2).
# authIdPerson_i is the HAL author id from the profile's search URL.
set -euo pipefail
AUTHOR_ID="${HAL_AUTHOR_ID:-16377}"
OUT="${1:-publications.bib}"
URL="https://api.archives-ouvertes.fr/search/?q=authIdPerson_i:${AUTHOR_ID}&wt=bibtex&rows=5000&sort=producedDate_tdate%20desc"
curl -fsSL --max-time 120 "$URL" -o "${OUT}.tmp"
n=$(grep -c '^@' "${OUT}.tmp" || true)
if (( n == 0 )); then echo "no entries in the HAL response; kept the old ${OUT}" >&2; rm -f "${OUT}.tmp"; exit 1; fi
mv "${OUT}.tmp" "$OUT"
echo "wrote ${OUT}: ${n} entries"
