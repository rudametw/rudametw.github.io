#!/usr/bin/env bash
# scripts/update-publications-from-hal.sh — refresh the publication list from HAL.
# Runs from any directory; outputs land in the repository root and data/.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${HERE}/fetch-hal-bibtex.sh" && "${HERE}/bib2yaml.py"
