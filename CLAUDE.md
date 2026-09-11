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
data/publications.yaml
scripts/bib2yaml.py
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
   must be a single pinned `hugo` binary. `scripts/bib2yaml.py` is run manually by
   the author, not by CI.
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

so:

```toml
[permalinks]
  blog = "/blog/posts/:year.:month.:day/:title.html"

[taxonomies]
  category = "blog/categories"
```

Two traps in that translation:

- Jekyll's `:title` preserves the filename's case; Hugo's `:slug`/`:title` lowercases
  by default. Live URLs have capitals (`/blog/posts/2014.03.05/Thunderbird-leading-spaces-bug.html`,
  `NSLU2-multiple-network-itfs.html`). Set `disablePathToLower = true` or pin each
  post's `slug:` in front matter.
- The `.html` suffix means these are *not* directory-style URLs. Hugo needs
  `uglyURLs` for the blog section, or explicit `url:` per post.

Verification loop:

```bash
hugo --minify && ./check-urls.sh
```

Iterate until `check-urls.sh` reports no MISSING entries. Fix by adding
`aliases` to front matter, not by changing `urls-before.txt`.

Orphan URLs (present on the live site, absent from `sitemap.xml`) are flagged
separately by the script as ORPHAN. Do not auto-create pages for them; list them
and let the author decide keep / redirect / drop.

## Blocking issues found on inspection (2026-09-11)

These are unresolved. Read before starting phase 1.

1. **`urls-before.txt` is corrupt — 210 of its 260 lines are unsatisfiable.**
   `src/_config.yml` sets `url: http://rudametw.github.io` (http), but
   `check-urls.sh` defaults `SITE_URL` to `https://rudametw.github.io`. The
   `normalise()` sed therefore never strips the prefix off sitemap `<loc>`
   values; the fallback rule `s|^\([^/]\)|/\1|` prepends a slash instead,
   yielding lines like `/http://rudametw.github.io/blog/`. Verify with
   `grep -c '^/http' urls-before.txt`.
   Knock-on effect: `urls-orphans.txt` (`comm -13 sitemap crawl`) lists all 50
   crawled URLs as ORPHAN, because the mangled sitemap set intersects the crawl
   set nowhere. **The orphan list is currently meaningless.**
   Fix is in `check-urls.sh` (make `normalise` scheme-insensitive), then
   regenerate with `./check-urls.sh --inventory`. Rule 4 forbids hand-editing
   `urls-before.txt`; regenerating it from a fixed script is the intended path.
   Ask before regenerating — it overwrites the contract.

2. **The crawl is partial: 50 HTML files vs. 218 `<loc>` entries in the
   sitemap.** `~/git/archive/old-site-crawl/` never captured the blog posts or
   photo galleries. `~/git/archive/old-site-crawl.old/` (not mentioned above,
   present on disk) has the same 50 files, so re-crawling did not help. The
   rendering oracle covers the top-level pages only; for anything under
   `/blog/posts/` or `/photos/`, read the built HTML in
   `~/git/archive/jekyll-src/` root instead (that worktree contains both the
   Jekyll source under `src/` and the committed build output at its root).

3. **`hugo` is not installed** (`command -v hugo` fails). The verification loop
   cannot run yet. Installing it needs the author's go-ahead per the rules below.

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

Two sections exist on disk but appear in neither the nav nor the crawl:
`src/CICOMP/` and `src/projet-al/` (old course pages). `/CICOMP/` is in the
sitemap; `/projet-al/` is in neither the sitemap nor the crawl, i.e. a true
orphan. Report both, let the author decide.

Vendored front-end to be deleted per rule 1b: `bootstrap.css`, `bootstrap.js`,
`jquery-latest.js`, `jquery.fancybox.*`, `font-awesome.css`, a remote
`google-fonts.css`, plus `OSData.swf` and `recFp.js`.

## Publications: the source of truth is HTML, not BibTeX

`src/publications/publications.json` exists but **nothing references it** — it is
dead data. The live page is hand-written HTML in `src/publications/index.html`:
ORCID and Scholar links, then `<TABLE>` blocks of theses, book chapters,
conference and journal papers. Only one `.bib` file exists in the whole repo
(`docs/bibtex/Rudametkin10.bib`), and it backs two standalone pages.

So the `scripts/bib2yaml.py` + `data/publications.yaml` pipeline in the target
layout above is a **plan, not a port**. Phase 5 has to start by deciding where
the bibliography actually comes from (author's BibTeX file? HAL? ORCID export?).
Ask before writing the converter.

## Content staleness (report only, do not fix)

The live site predates a move and a promotion. Grep for and report occurrences of:
`Lille`, `Polytech`, `Spirals`, `CRIStAL`, `Associate Professor`, `google+`,
`brandyourself`, `univ-lille1`, `Inria Lille`. Produce a file+line list. The author
edits these manually.

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

## Photos

The old repo carries multiple GB of images. GitHub Pages has a 1 GB published-site
limit. Photos are being reduced or moved off-repo. Do not copy the full photo tree
into `static/` without asking.

## Working style

- One phase per session, ending in a commit. Phases: (1) scaffold + `hugo.toml`,
  (2) content move, (3) template port, (4) URL verification, (5) publications
  pipeline, (6) CI workflow.
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
