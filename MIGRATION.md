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

---

## 2026-09-11 (later) — Phase 1: scaffold + `hugo.toml` — DONE

Author's brief: "perform all reasonable actions and take decisions for me."
Decisions taken are marked **[decided]** and can be reversed cheaply.

### Done

- **`hugo.toml`** reproducing the old URL scheme. Verified by building two real
  posts (the ones with capitals and a dot in the name): 10/10 blog URLs matched
  the contract byte-for-byte, then the test posts were removed again. Findings
  baked into the config: `:filename` fills date *and* case-preserved slug;
  `uglyURLs` per section supplies the `.html`; `capitalizeListTitles = false`
  because Hugo's "Bug" title otherwise leaks into `/blog/categories/Bug/`;
  taxonomy stays `categories` so Jekyll front matter is untouched, with the
  `/blog/` prefix coming from taxonomy/term permalinks. Zero build warnings.
- **`layouts/{baseof,single,list}.html`** — deliberately unstyled stubs so every
  page renders. Phase 3 replaces them.
- **`content/photos/_index.md`** — the retire page with 8 aliases. All 9 photo
  URLs resolve. Body is one placeholder line marked `TODO(author)`.
- **`scripts/copy-static.sh`** — reviewable, idempotent, never deletes. Ran it:
  288 files / 123 MB into `static/`.
- **`check-urls.sh`** — sweep now also takes teaching `.ods/.sql/.zip` exercise
  files; `advancedsettings.xml` pruned. Contract **225**, worklist **5**.

### Verification

```
hugo --minify --cleanDestinationDir && ./check-urls.sh
contract: 225  built: 189  missing: 38
```

**All 38 MISSING are content pages** — phase 2's exact worklist: 29 blog (12
posts, 16 categories, `/blog/`), 5 research, `/teaching/`, `/publications/`,
`/contact/`, `/CICOMP/`. Every static contract item (187) passes.

### [decided] this session

- `/CICOMP/` (a stale 35 KB copy of an old home page) → alias to `/` in phase 2.
- `/projet-al/` (meta-refresh to a Google Doc) → served verbatim from `static/`.
- `/advancedsettings.xml` (Kodi config) → dropped from contract and site.
- Teaching `.ods/.sql` exercise files → kept, copied, in contract; same
  reasoning as `/docs/`.
- The three `_old`/`.old` teaching PDFs → copied and served (10.4 MB); left on
  the worklist in case the author wants them gone.
- `img/*.xcf` GIMP sources (8 files, 3.1 MB) → not copied. Not web content.
- `robots.txt` → same file, sitemap URL flipped to https.
- RSS: one feed for `/blog/` only; none for home, categories, or terms.

### Found, for the author

- **`2011-09-17-Linux-webdav-box.net.md` needs `url:` pinned** in front matter
  or Hugo eats the `.net`. Recorded in CLAUDE.md; applies in phase 2.
- `diverse-logo-pngs.zip` alone is 16 MB of the 123 MB. Fine for Pages; noted.

### Next — phase 2 (content move)

12 posts (+ the `url:` pin), `index.html` → `content/_index.md` with the
`/CICOMP/` alias, the `_includes/*.md` content fragments → `content/{contact,
research,teaching,publications}/`, and the 5 research pages. Then
`./check-urls.sh` should read `missing: 0`.
Write it as a reviewable script per working style.

---

## 2026-09-11 (later still) — Phase 2: content move — DONE

```
hugo --minify --cleanDestinationDir && ./check-urls.sh
contract: 224  built: 226  missing: 0      (new: /blog/categories/, /blog/index.xml)
```

Plus automated checks over the rendered site: 0 broken local links, 0 unrendered
Markdown outside code blocks, 0 leftover Liquid. Fragment prose diffed verbatim
against `_includes/` (contact is byte-identical; the others differ only by the
two syntax fixes below, auditable with `diff`).

### Done

- `scripts/move-content.sh` (reviewable, idempotent) produced all 23 content
  files; its header lists every transformation. **Edit the script, not `content/`.**
- `diverse-logo-pngs.zip` removed from `static/`, `copy-static.sh` and the
  contract (author). Contract 225 → 224. `static/` is 287 files / 107 MB.

### Found and fixed on the way

- **Hugo ≥ 0.163 denies `.html` content files.** `[security] allowContent =
  ['! ^text/org$']`. My first attempt used a positive pattern, which replaced the
  default and locked Markdown out — keep it negations-only.
- **A second dotted slug**: `…libEGL.so.1-Fedora-20` — pinned like the `.net` one.
- **Redcarpet → CommonMark**: `####Title` without a space (80 occurrences) and a
  lone `<br>` line swallowing the Markdown after it (31). Fixed by a fence-aware
  awk filter so `#comments` in code blocks are untouched.
- **RSS leaked onto every section** (`section = ["HTML","RSS"]` applies to
  contact/, research/…). Now off globally, on for `/blog/` via front matter.

### Decisions taken

- Teaching page keeps its Bootstrap-grid wrapper HTML in content for now; phase 3
  restyles it. Its front-matter title had a stray `]` — removed.
- Publications: old `scholar.google.fr` link replaced by the author's current
  Scholar URL; "Up-to-date publications" block with HAL + Scholar added at the
  top with a `TODO(author)` that the list stops at 2015.
- Home: content = body between navbar and footer includes only. Its 80-line
  inline `<style>` and the `<head>` meta are template → phase 3.

### For the author

- `/docs/ICPS08-demo-NFCMuseum-cr.pdf` is still a dead link on the publications
  page (pre-existing).
- Retire-page wording (`content/photos/_index.md`) is still a placeholder.

### Next — phase 3 (template port)

Port `_layouts/default.html`, `_includes/{head,navbar,footer,well}.html`,
`blog-post.html`, `category_index.html`, `blog/index.html` (the post loop) into
`layouts/`, replacing the phase-1 stubs. Hand-written CSS in `assets/css/`
replacing Bootstrap 3 + jQuery (rule 1b). Drop `Photos` from the nav. Output the
Liquid → Go translation table (working style). Use `~/git/archive/old-site-crawl/`
as the visual reference; `hugo server` for a live check.

---

## 2026-09-11 (evening) — Phases 3–6: templates, CSS, CI — DONE

```
hugo --minify --cleanDestinationDir && ./check-urls.sh
contract: 224  built: 227  missing: 0     (new: /blog/categories/, /blog/index.xml, /404.html)
```

0 broken local links; 0 remote assets, scripts or fonts anywhere in `public/`;
Photos absent from nav and footer; archived notice on the 7 Lille-era pages and
nowhere else; 12 posts on `/blog/`, "All Tags" identical to the 16 contract
categories.

### Author rulings applied

- **Home profile is stale → postponed.** Ported verbatim (minus the google+
  button). The author writes a new profile. `content/_index.html` still carries
  Bootstrap markup; the CSS shim lays it out until then.
- **`_includes/*` are Lille-era (pre-September 2022)** → stamped `archived: lille`
  by `move-content.sh`; `partials/archived.html` shows a one-line notice. Words
  untouched. `contact/` got the notice too but really needs the same rewrite as
  the profile — old e-mails and title.
- **google+ / brandyourself → removed** from footer (template) and home (script).

### Decisions taken

- Google Analytics (UA-48705379-1) dropped: UA was shut down by Google in 2024,
  so it was dead code plus a third-party script.
- Footer credit "Built using Jekyll, Bootstrap…" and the HTML 4.01 badge replaced
  — they would have been false. HAL and ORCID added to the "Find me" row.
- No JavaScript at all. The nav wraps instead of collapsing; the home page's
  animated scroll arrow (needed arrow.css + JS) is hidden.
- `blog/categories/` (index of categories) and `404.html` exist now; neither did
  before.

### Liquid → Go table

In CLAUDE.md, "layouts/ and assets/css/". Notable drift: All Tags is alphabetical
(was insertion order); the 2 posts without `<!--more-->` summarise by word count.

### Left for the author

1. New profile for `/` and new `/contact/` (stale employer, e-mails, title).
2. `content/photos/_index.md` wording (placeholder).
3. Publication list (stops at 2015) and the dead `ICPS08-demo-NFCMuseum-cr.pdf` link.
4. Enable Pages → Source → GitHub Actions, push `hugo-site`, watch the first run.
   The workflow has not executed yet (no network here). PyYAML is not installed
   locally, so the YAML was not machine-validated — it is 53 straightforward lines.
5. Once live, decide the fate of `master` (the Jekyll branch) — nothing has been
   force-pushed or deleted.
6. Remove the Bootstrap shim from `main.css` after rewriting home/teaching/publications.

---

## 2026-09-11 (night) — Visual pass with headless Chromium

The author compared screenshots (`COMPARE/`) and found the first CSS ugly: navy
bar, uncoloured hero buttons, poor hero type, stacked columns. Answer to "what
should I install?": nothing — `/usr/bin/chromium --headless` on the host gives
screenshots, which was the missing feedback loop. Tailwind was declined: rules
1b and 2 (no framework, no npm), and not needed.

### Bugs the screenshots exposed (would not show in URL/link checks)

- **Contact page rendered its HTML as a code block.** The fragment is
  pretty-printed with 4–16-space indentation; in CommonMark an indented line at
  block start is an indented *code* block. `commonmark()` now strips leading
  whitespace from lines that begin with `<`. Teaching lost its stray `</div>`
  leaks the same way (its wrapper now goes through the filter too).
- **Four post titles showed `&#58;` literally** — Jekyll's YAML-safe colon,
  escaped again by Hugo. Decoded to `:` and emitted as single-quoted YAML (one
  title contains double quotes). Bonus: `<title>` tags are now correct too.
- **Bootstrap column shim never applied**: `.row > [class*="col-"]` outranked
  `.col-lg-5`. Width rules are now `.row > .col-*`. Home, contact and teaching
  regained their two-column layouts.

### CSS redesigned to match the old site

Light navbar (#f8f8f8, grey links, subtle active), photo hero with white
uppercase letter-spaced buttons and text-shadow, 16px body, 46rem prose column,
Bootstrap-3 link blue, photo "Find me" banner (bay2-2-optimized.jpg), inline
`code` styled like Bootstrap. ~140 lines. Fonts: Lato first in the stack for
optional self-hosting, Helvetica/Arial fallback (what the old site used when the
Google font did not load).

### Still the author's

Profile/contact text (stale), retire-page wording, publication list; optionally
download Lato (OFL) into `static/fonts/` for the original typeface.

---

## 2026-09-11 (late) — Design round 2: fonts, icons, spacing, publications box

Author's punch list, all done and verified by screenshot:

- **Gap between navbar and hero** — one bug caused both this *and* the missing
  gap on /blog/: `.wrap { padding: 0 1rem }` (a class) beat `main { padding-block }`
  (an element), so pages with `.wrap` had no top padding while the home `<main>`
  (no `.wrap`) had it. `.wrap` now sets `padding-inline` only; `#home main` is 0.
- **Bold group titles on /publications/** — headings were `font-weight: 500`,
  which Lato/Arial lack, so it fell to 400. Now 700.
- **ORCID/HAL/Scholar regrouped** as buttons in the green box; the bare links
  under the `<h1>` are cut by `move-content.sh` (author's call). "Scholar", not
  "Google Scholar", here and in the footer.
- **Glyphs back** on hero and footer buttons — see CLAUDE.md "Fonts and icons".
- **Lato self-hosted** from the author's `Lato.zip`.

Also, under "make it modern but light": sticky navbar; dark gradient over the
hero photo so the type reads; `theme-color` and OpenGraph meta.

### Recommendations not implemented (design decisions for the author)

1. **Home hero**: swap the fishing photo for a portrait + two-line bio + the three
   buttons. Says "researcher" before "hobbies"; also makes the profile rewrite
   the natural moment to do it.
2. **"Recent publications" on the home page**, 5 items, fed from a HAL BibTeX
   export through the `bib2yaml` idea that was shelved — the one place a small
   data pipeline would pay for itself.
3. **Publications page as a list with a year column and type filters** instead of
   the 2013 `<TABLE>` markup; static, no JS needed for the layout.
4. **Dark mode** via `prefers-color-scheme` — ~15 lines with the existing tokens.
5. **Mobile nav**: a `<details>` disclosure instead of wrapping to two rows.
6. **Contrast**: nav links `#777` on `#f8f8f8` are borderline (≈4.3:1); `#666` passes.
7. **WOFF2** for Lato (needs `fonttools`), `loading="lazy"` on content images
   (belongs in the rewritten home page, not in a template).

---

## 2026-09-11 (night, round 3) — Profile rewrite, dark mode, mobile nav, fonts, teaching

### Profile (the MAJOR item)

`content/_index.html` and `content/contact/_index.html` are now **hand-written
from the author's `PROFILE/` notes** (gitignored) and no longer generated by
`move-content.sh`. Focus: software engineering for privacy and security — browser
and device fingerprinting, Am I Unique, software diversity. Kept from the old
site: previous positions, the PhD/master's theses and defence slides, the HDR
manuscript, the main links. Dropped: component-model figures, the Polytech Lille
and Inria Lille photos, the old "Education" essay (condensed into the timeline).

Structure: hero (ocean photo, shorter, no haze) → About + "At a glance" →
Research (3 cards) → recognition strip → Career timeline → Get in touch.

**TODO(author) — four facts came only from the Gemini dossier**, flagged in an
HTML comment at the top of `content/_index.html`: HDR 2021; IUF member since
2022; the project names FP-Stalker / FP-Scanner / DrawnApart; Am I Unique "since
2014". Everything else is from the short bio, the contact note, or the old site.
The contact-page portrait is the old one (TODO: newer photo).

### Punch list

- **Dark mode** — `prefers-color-scheme`, light default, tokens only. Verified
  by injecting the dark token block into built pages (Chromium's
  `--force-dark-mode` does not affect `prefers-color-scheme`).
- **Mobile nav** — CSS-only disclosure (checkbox + label); open state verified.
- **Navbar** — 44px, all bold, `#666`.
- **Fonts** — Lato as WOFF (192 KB, was 376 KB TTF). WOFF2 needs `python-brotli`.
- **Hero** — shorter (`clamp(18rem, 52vh, 28rem)`), overlay reduced to a bottom
  gradient under the text. Checked at 400px.
- **Teaching** — `archived` pill on every course title; *slides | handouts* rows
  → tables via `scripts/teaching-tables.py` (28 rows, 5 tables); other link lists
  single-spaced. Two filter bugs found by screenshot and fixed: the table's HTML
  block swallowed the following Markdown until a blank line, and rows written
  directly under a heading were not recognised.

### Left for the author

1. Verify the four Gemini-sourced facts above; expand the Android sentence if wanted.
2. A recent portrait for `/contact/` (and optionally the home page).
3. Photos retire-page wording; publication list (stops at 2015); the dead
   `ICPS08-demo-NFCMuseum-cr.pdf` link.
4. Push `hugo-site`, set Pages → Source → GitHub Actions, watch the first run.
