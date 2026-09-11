# Migration log

Handoff state across context windows. Newest session last.

---

## 2026-09-11 — Phase 0: audit, URL contract repair

Nothing has been scaffolded yet. No `hugo.toml`, no `content/`. Phase 1 is still
open.

### Done

**Fixed `check-urls.sh`.** Four bugs, the first of which invalidated the contract:

1. `normalise()` stripped the site prefix by matching `${SITE_URL}` (https), but
   Jekyll's `_config.yml` declares `url: http://rudametw.github.io`, so every
   `<loc>` in `sitemap.xml` is http. Nothing matched; the fallback rule prepended
   a slash, producing 210 lines of `/http://rudametw.github.io/...`. Scheme and
   host are now stripped by pattern. (Confirmed with the author: the live site
   serves https and 301s from http — the http in the sitemap is historical.)
2. No percent-decoding, so `/docs/APSCC-2010-Managing%20dynamic%20...pdf` never
   matched the on-disk file whose name contains literal spaces. Two publication
   PDFs would have read as MISSING forever. Both sides are decoded now.
3. `comm` ran under the ambient locale while inputs were sorted under another.
   Pinned `LC_ALL=C`.
4. The live crawl captured 50 of 218 URLs and the script reported no warning.
   It now warns when the crawl is under half the sitemap.

**Added `--inventory-archive`**, now the preferred mode: builds the contract
offline from the `jekyll-final` worktree. No network, and unlike wget's link
following it cannot silently miss a section.

**Regenerated the contract.** `urls-before.txt` is now 218 URLs (157 PDFs,
16 `.html`, 37 directory URLs, `sitemap.xml`), replacing the corrupt 260.
`urls-orphans.txt` is 7 real orphans, down from a meaningless 50.

**Wrote `STALE-CONTENT.md`** — the report CLAUDE.md asks for. 55 distinct lines
across 12 files. Report only; not fixed.

**Settled the publications question.** `publications.json` is dead data,
referenced from nowhere. Source of truth is `src/publications/index.html`.
See the Publications section of CLAUDE.md.

### Decisions taken (author, 2026-09-11)

- **Vendor junk pruned from the contract.** `prune_vendor()` now filters
  `/fancybox/`, `/font-awesome/`, `/node_modules/` on both the sitemap and
  built-output sides. Contract is **216 URLs**, down from 218 — the two
  `/fancybox/demo/` pages jekyll-sitemap had listed as site content.
- **Photos are not being migrated.** `jekyll-gallery-generator` is skipped, not
  replaced. Verified its output is confined to `/photos/`, so skipping costs
  nothing elsewhere. Retires the 569 MB / 1 GB Pages-limit problem.
- **The 9 `/photos/` gallery URLs stay in the contract.** Not pruned. They will
  report MISSING until served or aliased; that visibility is the point.
- **The 6 photo files the blog post embeds were copied** into `static/photos/`
  at their existing paths, verified byte-identical against the archive. 3.0 MB.
  These are the only files from the photo tree that belong in `static/`.
- **`Photos` comes out of the nav when navbar/footer are ported** (phase 3).
  See the porting rule in CLAUDE.md.

### Done this session

`static/photos/` — 6 files, 3.0 MB. The first content in the repo.

### Open questions for the author

1. **The 9 `/photos/` URLs** are kept but nothing serves them yet. Retire-notice
   page with the 8 gallery URLs aliased to it, plain 404, or redirect off-site?
   Until then they are the expected residual MISSING set.
2. **The 7 orphans** in `urls-orphans.txt` — keep, redirect, or drop?
   `/docs/RUDAMETKIN_HDR.pdf` looks like a keeper that was never linked.
   `/advancedsettings.xml` is a Kodi config file and looks like a stray.
   `/projet-al/` is a meta-refresh to a Google Doc.
   The three `*_old.pdf` / `*.old.pdf` teaching files are probably droppable.
3. **The publication list stops at 2015** — author updates by hand; HAL and
   Scholar links are recorded in CLAUDE.md for the "Up-to-date publications"
   block.

### Next — phase 1 (scaffold)

- `hugo.toml` with the permalink scheme. Note it is
  `/blog/posts/:year.:month.:day/:title.html`, **not** Jekyll's default. Needs
  `uglyURLs` for blog, and case-preserving slugs (live URLs have capitals).
- Taxonomy `category = "blog/categories"` to replace the Ruby plugin, 16 terms.
- Copy 162 PDFs (75 MB) to `static/` at identical paths — they are contract items.
- Then `hugo --minify && ./check-urls.sh` and iterate. Expect the 9 `/photos/`
  URLs as the residual MISSING set until question 1 is answered.

### Environment note

`hugo` v0.166.0+extended is on the host PATH at `~/.local/bin/hugo` (installed in
the `arch` distrobox, exported with `distrobox-export`). Plain `hugo` works from
any shell. If it ever disappears from PATH, re-check that export.
