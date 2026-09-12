#!/usr/bin/env bash
# scripts/hal-diff.sh — HAL deposits that match the author's NAME but are not tied
# to the author's IdHAL person id. Those are the ones to claim in HAL:
#   hal.science -> Mon espace -> Mon IdHAL -> "Formes auteur" -> add the unlinked
#   author form (or "Réclamer la propriété" on the deposit). After that, the next
#   fetch-hal-bibtex.sh import picks them up automatically.
#
#   ./scripts/hal-diff.sh            # prints the missing deposits
set -euo pipefail
ID="${HAL_AUTHOR_ID:-16377}"
NAME="${HAL_LAST_NAME:-Rudametkin}"
API="https://api.archives-ouvertes.fr/search/"
by_id=$(curl -fsSL "${API}?q=authIdPerson_i:${ID}&fl=halId_s&rows=5000&wt=json")
by_name=$(curl -fsSL "${API}?q=authLastName_t:${NAME}&fl=halId_s,title_s,producedDateY_i,docType_s,authFullName_s,authIdPerson_i&rows=5000&wt=json&sort=producedDateY_i%20desc")
python3 - "$by_id" "$by_name" "$NAME" <<'PY'
import json, sys
ids = {d["halId_s"] for d in json.loads(sys.argv[1])["response"]["docs"]}
docs = json.loads(sys.argv[2])["response"]["docs"]
name = sys.argv[3].lower()
missing = [d for d in docs if d["halId_s"] not in ids]
print(f"{len(docs)} deposits match the name, {len(ids)} are tied to the IdHAL, {len(missing)} to check:\n")
for d in missing:
    forms = [a for a in d.get("authFullName_s", []) if name in a.lower()]
    print(f"  {d['halId_s']:14s} {d.get('producedDateY_i','')}  {d.get('docType_s',''):9s} {d.get('title_s',[''])[0][:70]}")
    print(f"  {'':14s} author form(s) to claim: {forms}   https://hal.science/{d['halId_s']}")
PY
