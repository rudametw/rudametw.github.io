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

**Regenerated the contract.** `urls-before.txt` replaced the corrupt 260 with 218
real URLs; `urls-orphans.txt` went from a meaningless 50 to 7 real ones. Both
counts moved again later in the session — see below.

**Wrote `STALE-CONTENT.md`** — the report CLAUDE.md asks for. 55 distinct lines
across 12 files. Report only; not fixed.

**Settled the publications question.** `publications.json` is dead data,
referenced from nowhere. Source of truth is `src/publications/index.html`.
See the Publications section of CLAUDE.md.

### Decisions taken (author, 2026-09-11)

- **Vendor junk pruned from the contract.** `prune_vendor()` filters `/fancybox/`,
  `/font-awesome/`, `/node_modules/` on both the sitemap and built-output sides,
  dropping the two `/fancybox/demo/` pages jekyll-sitemap had listed as content.
- **Photos are not being migrated.** `jekyll-gallery-generator` skipped, not
  replaced. Verified its output is confined to `/photos/`. Retires the 569 MB /
  1 GB Pages-limit problem.
- **The 9 `/photos/` URLs stay in the contract**, served by a **retire-notice page
  with the 8 gallery URLs as `aliases:`**. Front matter drafted in CLAUDE.md; not
  built, phase 1 has not started.
- **The 6 photo files the blog post embeds were copied** into `static/photos/`,
  byte-identical, 3.0 MB. The only photo files that belong in `static/`.
- **`Photos` comes out of the nav** when navbar/footer are ported (phase 3).
  The retire page still resolves; it just is not advertised.
- **All `/docs/*` are keepers.** Links there are shared directly, so absence from
  a page proves nothing. `/docs/` is filtered from the orphan worklist, never
  from the contract.

### Contract size over the session

`260` (corrupt) -> `218` (repaired) -> `216` (vendor pruned) -> **`220`**
(`/docs/` swept in full). Orphan worklist: `50` -> `7` -> **`6`**.

### Found while acting on the `/docs/` ruling

- **4 served files were missing from the contract.** The sweep matched
  `*.html`/`*.pdf`/`*.xml` only, so three `diverse-logo/*.zip` and
  `bibtex/Rudametkin10.bib` were live URLs the contract did not cover.
  `served_urls()` now takes every file under `docs/` whatever its extension.
- **`/docs/ICPS08-demo-NFCMuseum-cr.pdf` is a broken link on the live site.**
  `publications/index.html` links it; the file exists nowhere in the archive.
  Pre-existing 404, not introduced by the migration. Reported, not fixed.

### Open questions for the author

1. **5 `/docs/` files that no page links** — all preserved, but invisible from the
   site, so worth confirming each is still wanted:
   `RUDAMETKIN_HDR.pdf` (the HDR thesis — arguably belongs on Publications),
   `Developing_Adaptable_Components_Using_Dynamic_Languages.pdf`, and the three
   `diverse-logo/*.zip`.
2. **`/docs/ICPS08-demo-NFCMuseum-cr.pdf`** — supply the file, or drop the link
   from the publications page?
3. **The 6 remaining orphans.** Note
   `/research/water-quality-datascience/M2-Water-quality-datascience.pdf` sits
   under `/research/`, so the `/docs/` ruling does not cover it.
   `/advancedsettings.xml` is a Kodi config file. `/projet-al/` is a meta-refresh
   to a Google Doc. Three are `*_old.pdf` / `*.old.pdf` teaching files.
4. **The publication list stops at 2015** — author updates by hand; HAL and
   Scholar links recorded in CLAUDE.md.
5. **Retire-notice body text** for `/photos/` — the author's words (rule 6).

### Next — phase 1 (scaffold), NOT STARTED

Explicitly deferred at the author's instruction. When it resumes:

- `hugo.toml` with the permalink scheme. It is
  `/blog/posts/:year.:month.:day/:title.html`, **not** Jekyll's default. Needs
  `uglyURLs` for blog, and case-preserving slugs (live URLs have capitals).
- Taxonomy `category = "blog/categories"` to replace the Ruby plugin, 16 terms.
- Copy 162 PDFs (75 MB) to `static/` at identical paths — contract items.
- `content/photos/_index.md` retire notice with its 8 aliases.
- Then `hugo --minify && ./check-urls.sh` and iterate to zero MISSING.

### Environment note

`hugo` v0.166.0+extended is on the host PATH at `~/.local/bin/hugo` (installed in
the `arch` distrobox, exported with `distrobox-export`). Plain `hugo` works from
any shell. If it ever disappears from PATH, re-check that export.
