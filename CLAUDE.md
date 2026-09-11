# Project: rudametw.github.io — Jekyll → Hugo migration

## What this repo is

Personal academic site for Walter Rudametkin (Full Professor, University of Rennes /
IRISA). Sections: Home, Publications, Teaching, Research, Blog, Photos, Contact.
Served at https://rudametw.github.io/ via GitHub Pages.

We are porting it from Jekyll (broken, unmaintainable gem tree) to Hugo.

## Historical layout (being retired)

- `/`      — the *built* site, committed to git and served by Pages
- `/src`   — Jekyll sources
- `/src/update_site.sh` — `cp -uvarf _site/* ../` then commit+push

Consequence: `cp` never deleted, so `/` accumulated orphan HTML from years of
renames. Some of those orphans are live URLs not present in `sitemap.xml`.

## Target layout

Source at repo root on the orphan branch `hugo-site`. No built output in git. Pages
deploys from a GitHub Actions artifact. The old `master` branch and the
`jekyll-final` tag are preserved on GitHub; nothing is force-pushed.

```
hugo.toml
content/{_index.md,publications/,teaching/,research/,blog/,photos/,contact/}
layouts/            # ported from the old Jekyll _layouts/_includes, owned by us
assets/             # SCSS/CSS/JS
static/{img,docs}/
data/publications.yaml    # NOT USED - see Publications below
scripts/bib2yaml.py       # NOT USED - see Publications below
check-urls.sh
urls-before.txt     # the URL contract — see below
.github/workflows/hugo.yml
```

`public/` is gitignored and never committed.

## Hard constraints

1. **Do not install a theme.** No git submodules, no Hugo Modules, no
   `hugo new site --theme=...`. Templates are ported by hand and vendored into
   `layouts/`. Rationale: theme abandonment is the top cause of Hugo site rot on
   a 5–10 year horizon.
1b. **Styling decision: keep the structure, drop the framework.** The old site is
   a StartBootstrap template on Bootstrap 3 + jQuery (both EOL). Preserve the
   information architecture, nav, and content blocks; delete Bootstrap and jQuery.
   Replace with hand-written CSS in `assets/css/` using CSS grid/flex, custom
   properties, and `clamp()` for fluid type. No CSS framework, no CDN links, no
   `@import` from a remote. Target ~200 lines. Use
   `~/git/archive/old-site-crawl/` as the visual reference for what each page
   must still contain.
2. **Do not add npm, gem, or Python runtime dependencies to the build.** The build
   must be a single pinned `hugo` binary. (`scripts/bib2yaml.py` was to be run
   manually by the author, never by CI — but it is not part of this migration;
   see Publications.)
3. **Never commit `public/` or any built HTML.**
4. **Never edit `urls-before.txt`.** It is the contract, not a working file.
5. **Never `git push --force`** without explicit instruction in that turn.
6. **Do not rewrite prose content.** Blog posts, bio text, and page copy are the
   author's voice. Move them, fix front matter and link syntax, leave the words
   alone. If content is factually stale, *report* it — do not fix it.
7. Front matter stays **YAML** (`---` delimiters), not TOML. Keeps diffs small
   against the Jekyll originals.
8. Ask before deleting anything under `static/img/` or the photos tree.

## URL preservation

Every URL in `urls-before.txt` must exist in `public/` after a build, or be
covered by an `aliases:` entry in some page's front matter.

Jekyll permalink scheme must be reproduced in `hugo.toml`. The **actual** scheme in
`src/_config.yml` is dotted-date with a `.html` suffix, not Jekyll's default:

```yaml
permalink:    /blog/posts/:year.:month.:day/:title.html
category_dir: /blog/categories
```

**Reproduced and verified in phase 1** (2 real posts built, 10/10 blog URLs
matched the contract byte-for-byte). The working `hugo.toml` combination is:

| Old behaviour | Setting | Why |
|---|---|---|
| date from filename `2014-02-04-slug.md` | `[frontmatter] date = [":filename", ":default"]` | posts have no `date:`; `:filename` fills date **and** slug |
| `:title` = case-preserved filename slug | `permalinks.page.blog = "/blog/posts/:year.:month.:day/:slug"` + `disablePathToLower = true` | Hugo's `:title` would urlize the *front-matter* title |
| `.html` suffix | `[uglyURLs] blog = true` | not in the pattern — Hugo appends it |
| `/blog/categories/<cat>/` | `taxonomies.category = "categories"` + `permalinks.taxonomy/term.categories` | front matter keeps Jekyll's `categories:` key |
| lowercase category paths | `capitalizeListTitles = false` | with path-lowering off, Hugo's "Bug" title leaked into `/blog/categories/Bug/` |

**Dotted slugs** (resolved in phase 2): Hugo reads a dot in a filename as an
extension and truncates the slug. Two posts are affected — `…Linux-webdav-box.net`
and `…libEGL.so.1-Fedora-20` — and get `url:` pinned by `move-content.sh`.
Jekyll's `layout: blog-post` key is left in place; Hugo ignores it.

Verification loop:

```bash
hugo --minify && ./check-urls.sh
```

`hugo` is `v0.166.0+extended+withdeploy`, exported to the host at
`~/.local/bin/hugo`. Plain `hugo` works from any shell, agent shells included.
(It is installed in the `arch` distrobox and exported with `distrobox-export`; if
it ever vanishes from PATH, that export is what to re-check.)

The `extended` build matters if SCSS is ever compiled through Hugo Pipes. Per
rule 2 the build is a single pinned `hugo` binary, so pin `0.166.0` in
`.github/workflows/hugo.yml` to match.

Iterate until `check-urls.sh` reports no MISSING entries. Fix by adding
`aliases` to front matter, not by changing `urls-before.txt`.

Orphan URLs (present on the live site, absent from `sitemap.xml`) are flagged
separately by the script as ORPHAN. Do not auto-create pages for them; list them
and let the author decide keep / redirect / drop.

## URL contract: how it was rebuilt (2026-09-11)

The first `urls-before.txt` was corrupt and has been regenerated. Background, so
nobody reintroduces the bug:

`src/_config.yml` declares `url: http://rudametw.github.io`, so every `<loc>` in
the generated `sitemap.xml` is **http**. The site is served over **https**, with
a 301 from http. `check-urls.sh` used to strip the prefix by matching `${SITE_URL}`
(https), so it never matched; the fallback rule prepended a slash instead and wrote
210 unusable lines of the form `/http://rudametw.github.io/blog/`. Orphan detection
then compared two disjoint sets and flagged everything.

Fixes applied to `check-urls.sh`:

- `normalise()` strips scheme and host **by pattern**, not by matching `${SITE_URL}`.
  The contract is a set of paths; scheme and host are not part of it.
- Percent-decoding on both sides, so the sitemap's
  `/docs/APSCC-2010-Managing%20dynamic%20...pdf` matches the on-disk file whose
  name contains literal spaces. Without this, two publication PDFs read as MISSING.
- `LC_ALL=C`, because `comm` needs both inputs in the same collation as the `sort`
  that produced them.
- New `--inventory-archive` mode (now the preferred one), which builds the contract
  offline from the `jekyll-final` worktree instead of crawling the live site.

Regenerate with:

```bash
./check-urls.sh --inventory-archive
```

Current contract: **224 URLs**. `urls-orphans.txt` is a worklist of what still
needs a keep / redirect / drop call — **5 entries**:

```
/projet-al/                               <- kept as a verbatim static redirect stub (phase 1)
/research/water-quality-datascience/M2-Water-quality-datascience.pdf   <- copied; outside /docs/
/teaching/gbiaal4sgbd/cours/7_Recapitulatif_handouts_old.pdf           <- copied (5.2 MB)
/teaching/gbiaal4sgbd/cours/7_Recapitulatif_old.pdf                    <- copied (5.2 MB)
/teaching/gbiaal4sgbd/td_tp/TP-Noté-2015-videoclub.old.pdf             <- copied
```

All five are *served* by the phase-1 build (they are in `static/`); they stay on
the worklist only because the author may still want to drop the `_old` files.
Filtered out as settled: `/sitemap.xml`, all `/docs/*`, teaching exercise files
(`.ods`/`.sql`/`.zip`). Dropped outright: `/advancedsettings.xml` (Kodi config).

**Vendor junk is pruned from the contract** (author's call, 2026-09-11).
`prune_vendor()` drops `/fancybox/`, `/font-awesome/` and `/node_modules/` from
*both* the sitemap and the built-output side. This removed `/fancybox/demo/` and
`/fancybox/demo/iframe.html`, which jekyll-sitemap had listed as if they were
site content. Bootstrap, jQuery and fancybox all go away under rule 1b, so
preserving their demo pages would have been pointless.

Contract size over the session: 260 (corrupt) -> 218 (repaired) -> 216 (vendor
pruned) -> 220 (`/docs/` swept in full) -> 225 (teaching exercise files in,
`advancedsettings.xml` out) -> 224 (`diverse-logo-pngs.zip` out).

### Why `--inventory-archive` and not the live crawl

`~/git/archive/old-site-crawl/` holds only **50** HTML files against the sitemap's
218 entries — wget's link-following never reached the blog posts or galleries.
`old-site-crawl.old/` (also on disk, not described below) has the same 50. The
crawl is a usable rendering oracle for top-level pages **only**.

The full oracle is the `jekyll-final` worktree: its root is the committed *built*
site, and 206 of 210 unique sitemap paths resolve to a real file there (the other
4 differ only by percent-encoding). Read rendered output from there, not the crawl.

`--inventory` (live) is kept and fixed, but needs network access.

## `static/` — populated in phase 1 (`scripts/copy-static.sh`)

287 files, **107 MB**: `docs/` 39 MB (15 files — `diverse-logo-pngs.zip`, 16 MB,
dropped by the author 2026-09-11 and pruned from the contract), `teaching/` 43 MB (148 PDFs
+ 6 `.ods`/`.sql` exercise files), `img/` 22 MB (103 web images; the 8 `.xcf` GIMP
sources stayed behind), `photos/` 3 MB (the 6 blog-post images), plus
`favicon.ico`, `robots.txt` (same file, sitemap URL flipped to https),
`google462956b09535940b.html`, `.nojekyll`, and `projet-al/index.html` served
verbatim as the meta-refresh redirect it always was.

The script is idempotent (`cp -n`) and never deletes. Re-run it if the archive
gains a file.

Not copied, by decision: `photos/` galleries (569 MB), `fancybox/`,
`font-awesome/`, `fonts/`, `assets/` (rule 1b), `*.py`/`*.sh` under `teaching/`
(author tooling), `advancedsettings.xml`, `sitemap.xml` (Hugo generates it), and
every built `.html` page (content phase).

## Verified inventory of the old site

From `~/git/archive/jekyll-src/src/` at tag `jekyll-final`:

- `_layouts/` — 9: `default`, `full-page`, `large-page`, `blog-post`,
  `blog-post-image`, `category_index`, `gallery_index`, `gallery_page`,
  `thumbnail-gallery`.
- `_includes/` — 20, a mix of HTML partials (`head`, `navbar`, `footer`, `well`)
  and **Markdown content fragments** (`contact.md`, `research.md`,
  `teaching*.md`, `publications.md`, the four research-topic `.md` files).
  Those `.md` includes are page *content*, not chrome — they become
  `content/` files in Hugo, not `layouts/partials/`.
- `_posts/` — 12 posts, 2010–2014. Front matter is `layout`, `title`,
  `categories` (a list). `<!--more-->` is the excerpt separator.
- `_plugins/generate_categories.rb` — a custom Ruby plugin producing
  `/blog/categories/<cat>/`. Hugo taxonomies replace it; there are 16 categories.
- Markdown engine is **redcarpet** with `strikethrough` + `tables`. Hugo uses
  Goldmark; expect differences on raw HTML in Markdown and on hard line breaks.
- `jekyll-gallery-generator` built `/photos/*` from EXIF, configured with
  per-gallery `best_image` in `_config.yml`. There is no Hugo equivalent — the
  photo section needs a hand-written template plus a decision on hosting
  (see Photos below).

Layout `default.html` is a Bootstrap 3 two-column grid: `.col-md-8` content +
`.col-md-4` sidebar (`well.html`), with `navbar.html` above and `footer.html`
below. Nav is Home / Publications / Teaching / Research / Blog / Photos / Contact.

Two directories exist at the built root with no Jekyll source: `CICOMP/` and
`projet-al/`. `CICOMP/index.html` is a 35 KB stale copy of an old *home page*
("Official Home Page | Sitio Oficial"), in the sitemap. **Decision (phase 1):
alias `/CICOMP/` to `/`** — add it to `content/_index.md` `aliases:` in phase 2.
`projet-al/index.html` is a meta-refresh to a Google Doc; copied verbatim to
`static/`, so it keeps doing exactly that.

Vendored front-end to be deleted per rule 1b: `bootstrap.css`, `bootstrap.js`,
`jquery-latest.js`, `jquery.fancybox.*`, `font-awesome.css`, a remote
`google-fonts.css`, plus `OSData.swf` and `recFp.js`.

## Publications

**Source of truth: `src/publications/index.html`.** Port that page's markup and
its links to the PDFs. Do **not** use `src/publications/publications.json` — it
is dead data, referenced from nowhere in the site, and it does not match what
the page actually shows.

`scripts/bib2yaml.py` and `data/publications.yaml` in the target layout above are
therefore **not part of this migration**. There is one `.bib` file in the whole
repo (`docs/bibtex/Rudametkin10.bib`) backing two standalone pages
(`/docs/bibtex/Rudametkin10.html`, `/docs/bibtex/Rudametkin10_bib.html`); carry
those across as-is. Drop `publications.json` and `publications-template.json`.

The page links 9 local files, all of them under `/docs/` and all present in
`urls-before.txt`:

```
/docs/WalterRudametkin.thesis.FINAL.pdf        /docs/DynamicTracing.pdf
/docs/WalterRudametkin.slides.FINAL.pdf        /docs/SAC12-americo.pdf
/docs/MasterThesis-WalterRudametkin-FINAL.pdf  /docs/Rudametkin-APSCC-2010-slides.pdf
/docs/APSCC-2010-Managing dynamic service-oriented component architectures.pdf
/docs/Resilience in dynamic component-based applications.pdf
/docs/bibtex/Rudametkin10_bib.html
```

Two of those filenames contain literal spaces and appear percent-encoded in the
sitemap. `check-urls.sh` decodes both sides before comparing; keep the files
named as they are rather than renaming them, or the old URLs break.

### TODO: the publication list is out of date

The ported page must carry a visible TODO. The newest year appearing anywhere in
`index.html` is **2015**, so the list is roughly a decade stale: it predates the
author's HDR, the move to Rennes, and the promotion to Full Professor.
**Do not invent or backfill entries** — rule 6. The author updates it by hand.

Canonical up-to-date sources, to link from the page as "Up-to-date publications":

- HAL: <https://inria.hal.science/search/index/?q=%2A&rows=30&authIdPerson_i=16377&sort=publicationDate_tdate+desc>
- Google Scholar: <https://scholar.google.com/citations?user=vJQGm9kAAAAJ&hl=fr&oi=ao>

The existing page already links ORCID (`0000-0003-2903-7600`) and an older
Scholar URL (`scholar.google.fr/citations?user=vJQGm9kAAAAJ`) — same user id,
so replace it with the one above rather than keeping both.

Note `/docs/RUDAMETKIN_HDR.pdf` is served but listed in neither the sitemap nor
this page. Confirmed a keeper (see `/docs/` below) — it is in the contract. It
arguably belongs *on* this page; author's call.

## `/docs/` — all keepers (decision, 2026-09-11)

Author's ruling: **every file under `/docs/` is a keeper.** Links there have been
shared directly over the years, so "no page links it" is not evidence that a URL
is dead. `/docs/` is therefore excluded from the orphan worklist — not from the
contract.

This exposed a hole in the inventory. The sweep matched `*.html`, `*.pdf`, `*.xml`
only, so three `.zip` files and a `.bib` were served but absent from the contract.
`served_urls()` now takes **every file under `docs/` whatever its extension**, plus
pages and documents elsewhere. Contract went 216 → 220.

### TODO for the author: 5 files under `/docs/` that no page links

All are in the contract and will be preserved. Listed because they are invisible
from the site itself — worth confirming each is still wanted:

| File | Note |
|---|---|
| `/docs/RUDAMETKIN_HDR.pdf` | The HDR thesis. Never linked from any page — probably *should* be, from Publications. |
| `/docs/Developing_Adaptable_Components_Using_Dynamic_Languages.pdf` | Paper, not in the publications list either. |
| `/docs/diverse-logo/diverse-logo-fonts.zip` | DiverSE team logo kit. |
| `/docs/diverse-logo/diverse-logo-pngs.zip` | idem |
| `/docs/diverse-logo/diverse-logo-svg.zip` | idem |

The 11 other `/docs/` files are all linked from `publications/index.html` or the
two bibtex pages.

### Pre-existing broken link — do not fix silently

`src/publications/index.html` links `/docs/ICPS08-demo-NFCMuseum-cr.pdf` and
**that file does not exist** anywhere in the archive. It is a 404 on the live site
today, not something the migration introduces. Rule 6 says report, not fix:
the author supplies the file or drops the link.

## `content/` — populated in phase 2 (`scripts/move-content.sh`)

23 files. Verified: `./check-urls.sh` → **224/224, missing 0**; a site-wide scan
of the rendered HTML finds **0** local broken links and **0** unrendered Markdown
(literal `#### `, ` ``` `, `](`, `{%`) outside code blocks.

| Content | From | Form |
|---|---|---|
| 12 posts | `_posts/*.md` | `.md`; `{% highlight %}` → fences; 2 `url:` pins |
| `blog/_index.md` | — | `outputs: [HTML, RSS]` — the site's only feed |
| `contact/`, `research/`, 4 research pages | wrapper front matter + `_includes/*.md` body | `.md` |
| `teaching/_index.md` | wrapper HTML with the 4 fragments inlined where the includes were | `.md` with raw HTML; stray `]` removed from the title |
| `publications/_index.html` | `publications/index.html` body | **`.html`** + the "Up-to-date publications" HAL/Scholar block and TODO the author asked for |
| `_index.html` (home) | `index.html` body between navbar and footer | **`.html`**; `aliases: [/CICOMP/]` |
| `photos/_index.md` | phase 1 | retire page, 8 aliases |

**Redcarpet → CommonMark.** Two syntax habits from the old renderer break under
Goldmark and are fixed mechanically by the script's `commonmark()` filter, which
is fence-aware so `#comments` inside code blocks are never touched:

- `####Title` (no space) was a heading in Redcarpet; CommonMark prints the hashes.
  → `#### Title`. 23 in posts, 57 in fragments.
- A lone `<br>` line opens an HTML block that swallows the following Markdown
  until a blank line. → blank line inserted after it. 2 in posts, 29 in fragments.

**`.html` content files** need `[security] allowContent = ['! ^text/org$']` in
`hugo.toml` — Hugo ≥ 0.163 denies `text/html` content by default. Keep that list
negations-only: a positive pattern silently locks Markdown out.

The home page's inline `<style>` block (lines 5–87 of `src/index.html`) and its
`head-open-head-tag.html` meta are **not** in content — they are template, for
phase 3.

## Content staleness (report only, do not fix)

The live site predates a move and a promotion. Grep for and report occurrences of:
`Lille`, `Polytech`, `Spirals`, `CRIStAL`, `Associate Professor`, `google+`,
`brandyourself`, `univ-lille1`, `Inria Lille`. Produce a file+line list. The author
edits these manually.

**Done — see `STALE-CONTENT.md`** (regenerate by re-running the greps against
`~/git/archive/jekyll-src/src/`). **55 distinct lines across 12 files** (the
per-term totals in the report sum to more, because many lines match several terms
at once — e.g. "Polytech Lille"). By file:

| File | Lines | What is stale |
|---|---|---|
| `index.html` | 16 | Affiliation block, Spirals/Inria Lille logos, bio |
| `_includes/contact.md` | 9 | Job title, both email addresses, postal address |
| `_includes/cloud-dynamic-monitoring-and-repair.md` | 5 | Team member titles and emails |
| `_includes/optimisation-applications-cloud.md` | 4 | idem |
| `_includes/dynamic-apps-cloud-computing.md` | 4 | idem |
| `_includes/dynamic-application-consistency.md` | 4 | idem |
| `photos/2014.01.16_.../index.html` | 3 | incidental prose mentions |
| `photos/2013.12.13_.../index.html` | 3 | idem |
| `_includes/footer.html` | 3 | `google+`, `brandyourself` social links |
| `_includes/teaching-gbiaal-moodle.md` | 2 | Polytech Lille course intro, moodle URL |
| `_includes/teaching-ima3-pa.md` | 1 | idem |
| `_includes/teaching-git.md` | 1 | idem |

Note the images `img/polytech-lille.jpg` and `img/inria-lille.jpg` are affiliation
logos that go stale with the text. Rule 8 — ask before deleting anything under
`static/img/`.

Port the words unchanged (rule 6). The author does a single editing pass afterwards.

## Where to read the old site from

The orphan branch `hugo-site` contains no Jekyll files. The old version is available
in two forms, both outside the working tree:

- `~/git/archive/jekyll-src/` — a **git worktree** checked out at the tag
  `jekyll-final`. Under `src/`: `_config.yml`, `_layouts/`, `_includes/`,
  `_posts/`, `_plugins/`, and `_assets/{stylesheets,javascripts}/` (there is no
  `_sass/` — styles are plain CSS under `_assets/stylesheets/`). The worktree
  *root* additionally holds the committed build output, which is the better
  rendering oracle for blog posts and galleries the crawl missed. Read from here
  when porting templates, front matter, or content.
- `~/git/archive/old-site-crawl/` — a `wget --mirror` capture of the *rendered*
  site as served before the migration. Read from here when checking what a page
  actually looked like or contained.

Created with:

```bash
git worktree add ~/git/archive/jekyll-src jekyll-final
```

Both are **read-only for our purposes**. The worktree is backed by the live
`.git` directory: never `rm -rf` it (use `git worktree remove`), never commit in
it, never check out a different ref in it.

If `~/git/archive/jekyll-src/` is missing, recreate it with the command above
rather than pulling Jekyll files into this branch.

## Archive (`~/git/archive/`) — read-only, never modify

Pre-migration safety net, kept outside this repo. Contents:

- `jekyll-site.bundle`   — `git bundle create ... --all` of the full pre-migration
                           repo: all branches, all tags, full history including the
                           multi-GB photo blobs, as a single offline file. Verify
                           with `git bundle verify`. This is the cold archive.
- `old-site-crawl/`      — static `wget --mirror` capture of
                           https://rudametw.github.io as served immediately before
                           the migration. The rendering oracle.
- `jekyll-src/`          — git worktree at tag `jekyll-final` (see above). Backed
                           by the live `.git`, not an independent copy.

A `jekyll-site.git` mirror clone previously lived here and has been deleted as
redundant: history remains in this repo's `.git`, on GitHub under the
`jekyll-final` tag and the `master` branch, and in the bundle.

**Never write to, move, delete, or `git gc` anything under `~/git/archive/`.**
Reading is expected and encouraged.

## Photos — NOT being migrated (decision, 2026-09-11)

The author is not migrating `/photos/`. `jekyll-gallery-generator` is therefore
**skipped**, not replaced: no Hugo gallery template is to be written.

Verified scope before skipping: the plugin's output is confined to `/photos/`.
Only `_layouts/gallery_page.html` references the gallery layouts, the source
`photos/*/index.html` files are empty `<html></html>` stubs the plugin filled in,
and `_config.yml` points it at `dir: photos`. Nothing outside `/photos/` depends
on it. Skipping it costs nothing elsewhere.

This also removes the 569 MB problem: the old repo carried multiple GB of images
against GitHub Pages' 1 GB published-site limit. Do not copy the photo tree into
`static/`. Rule 8 still applies — ask before deleting anything under the photos
tree in the archive.

### The 9 gallery URLs: retire notice + aliases (decision, 2026-09-11)

Author's call: **one retire-notice page at `/photos/`, with the 8 gallery URLs
aliased onto it.** Nothing is pruned from `urls-before.txt`.

**Built in phase 1** as `content/photos/_index.md`. Body is one placeholder
sentence marked `TODO(author)` — the wording is the author's to write (rule 6).
Verified: all 9 URLs resolve; Hugo writes each alias as a meta-refresh stub.

```yaml
---
title: Photos
aliases:
  - /photos/2013.07.27_Saint_Malo/
  - /photos/2013.12.13_Dad_fishing_trip/
  - /photos/2014.01.16_Dad_keeps_torturing_me_with_these_pictures/
  - /photos/2014.02.25_rennes_at_night/
  - /photos/2014.03.01_Rennes_market_and_oyster_snack/
  - /photos/2014.03.04_Beach_Trip_to_La_Baule_and_Guerande/
  - /photos/2014.03.09_Bonnets_Rouges_Walk_in_Rennes/
  - /photos/2014.03.23_Fisheye_at_Place_De_La_Marie_Rennes/
---
```

The alias paths carry capitals and underscores — do not lowercase them, or the
old URLs break.

### Photo assets kept in `static/photos/` — DONE

`_posts/2014-03-07-My-father-tortures-me-with-beautiful-sunny-pictures.md` does
not merely link the galleries, it `<img src=>`s individual JPEGs out of them.
Rule 6 forbids rewriting the post, so the images it needs were copied across
(verified byte-identical against the archive):

```
static/photos/2013.12.13_Dad_fishing_trip/DSC_4995.JPG
static/photos/2013.12.13_Dad_fishing_trip/DSC_5013.JPG
static/photos/2013.12.13_Dad_fishing_trip/DSC_5027.JPG
static/photos/2013.12.13_Dad_fishing_trip/DSC_5033.JPG
static/photos/2013.12.13_Dad_fishing_trip/thumbs/DSC_4995.JPG
static/photos/2014.01.16_Dad_keeps_torturing_me_with_these_pictures/thumbs/DSC_5128.JPG
```

3.0 MB total. These are the **only** files from the 569 MB photo tree that belong
in `static/`. If another page turns out to reference a gallery image, add that
file here — do not copy a whole gallery directory, and do not edit the post.

### Porting rule: drop `Photos` from the nav

`/photos/` is referenced from `_includes/navbar.html` (line 20) and
`_includes/footer.html` (line 48). Both live only in the read-only archive; there
is no `layouts/` in this repo yet, so there is nothing to edit until phase 3.

**When porting those two partials, omit the `Photos` `<li>` entirely** — along
with its adjacent `footer-menu-divider` `<li>` in the footer, or the separator
dots come out wrong. Nav becomes:

```
Home | Publications | Teaching | Research | Blog | Contact
```

Note the reason is *not* that `/photos/` will 404 — the retire-notice page above
means it resolves. The point is that a retired section should not be advertised
in the primary nav: the page exists to keep old inbound links and bookmarks
working, not to invite new visits.

This is the one `/photos/` reference that gets removed rather than preserved. The
blog post's inline images, the 9 contract URLs, and the retire page itself are
all kept.

## Working style

- One phase per session, ending in a commit. Phases: (1) scaffold + `hugo.toml`
  — **done 2026-09-11**, (2) content move — **done 2026-09-11, contract 224/224**,
  (3) template port, (4) URL verification, (5) publications page, (6) CI workflow.
- Content is produced by `scripts/move-content.sh` from the archive. **Edit the
  script, not `content/`**, until the author starts editing prose there; the
  script header lists every transformation it performs. Audit any file with
  `diff ~/git/archive/jekyll-src/src/_posts/X.md content/blog/X.md`.
- `layouts/{baseof,single,list}.html` are **phase-1 stubs**, unstyled, marked
  TEMPORARY in a comment. They exist so every page renders and `check-urls.sh`
  is meaningful. Phase 3 replaces them; do not grow them in phase 2.
- Build with `hugo --minify --cleanDestinationDir`, never `rm -rf public`.
- For bulk file moves, **write a reviewable shell script** rather than performing
  dozens of individual edits. The author reviews before it runs.
- When porting a template, output a table of every Liquid construct translated and
  its Go template equivalent, so semantic drift is reviewable
  (`| markdownify`, `site.posts` ordering, `{% for %}` scoping, `{% include %}`).
- Append a short entry to `MIGRATION.md` at the end of each session: what was done,
  what is next, open questions. This is the handoff state across context windows.

## Commands you may run without asking

`hugo`, `hugo --minify`, `hugo server`, `./check-urls.sh`, `git status`,
`git diff`, `git log`, `git add`, `rg`/`grep`, `find`, and any *read-only*
access to `~/git/archive/old-site-crawl/`.

## Commands you must ask about first

`git commit`, `git push`, `git rm`, `rm -rf`, anything that *writes to*
`~/git/archive/`, anything installing a package.
