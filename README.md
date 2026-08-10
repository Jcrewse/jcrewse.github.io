# jcrewse.github.io

Personal site. Jekyll + the [academicpages](https://github.com/academicpages/academicpages.github.io)
theme, built and deployed by GitHub Actions to <https://jcrewse.github.io>.

This file is the orientation doc: what lives where, how to make the common
edits, and the handful of things about this repo that will surprise you.

---

## The 30-second model

You write Markdown. A GitHub Action turns it into HTML and publishes it.

```
push to main  →  Actions: jekyll build  →  link check  →  deploy to Pages
```

Three kinds of thing live in this repo:

| | What | Touch it? |
|---|---|---|
| **Content** | `_pages/`, `_posts/`, `_publications/`, `_drafts/`, `files/`, `images/` | Yes, constantly |
| **Settings** | `_config.yml`, `_data/navigation.yml` | Occasionally |
| **Theme machinery** | `_layouts/`, `_includes/`, `_sass/`, `assets/` | Rarely — see [Theme is vendored](#the-theme-is-vendored) |

Anything starting with `_` is a Jekyll source folder, not output. The built
site (`_site/`) is generated in CI and is not committed.

---

## Where each page comes from

Every page's URL is set by its own `permalink:` front matter, not by its
filename or folder. That means you can move files around freely.

| URL | Source file | Layout |
|---|---|---|
| `/` | `_pages/about.md` | single |
| `/publications/` | `_pages/publications.html` | archive |
| `/blog/` | `_pages/year-archive.html` | archive |
| `/cv/` | `_pages/cv.md` | archive |
| `/pendulum/` | `_pages/pendulum.html` | single |
| `/posts/<title>/` | `_posts/YYYY-MM-DD-title.md` | single |
| `/publications/<name>/` | `_publications/*.md` | single |
| `/404.html` | `_pages/404.md` | single |

`_pages/` also contains `category-archive.html`, `tag-archive.html`,
`collection-archive.html` and `sitemap.md`. These ship with the theme, are not
in the nav, and nothing links to them. Harmless; delete if they bother you.

The two layouts you'll see: **single** is a normal page, **archive** is a page
that lists things. Both render the left sidebar.

---

## Common edits

### Add a blog post

Create `_posts/YYYY-MM-DD-some-title.md`:

```markdown
---
title: "Some Title"
date: 2026-08-10 09:00:00 -0500
categories: [PHYSICS]
---

Body text in Markdown.
```

The date in the **filename** is what Jekyll uses to order and publish it. A
post dated in the future still appears, because `future: true` is set.

To work on something without publishing it, put it in `_drafts/` and leave the
date off the filename. Drafts are never built. (There are four in there now.)

### Add a publication

Create `_publications/YYYY-MM-DD-short-name.md`. Front matter only — no body
needed:

```markdown
---
title: "Paper Title"
collection: publications
category: manuscripts
permalink: /publication/2026-short-name
excerpt: 'One-line summary shown on the listing page.'
date: 2026-01-15
venue: 'Physical Review B'
paperurl: 'https://doi.org/...'
citation: 'A. Author, <b>J. Crewse</b>. "Paper Title." <i>Physical Review B</i> <b>1</b>, 012345.'
---
```

**`category:` is required.** The listing page groups by it and *silently skips*
anything whose category isn't one of `manuscripts`, `books`, or `conferences`
(defined under `publication_category` in `_config.yml`). A paper with no
category just won't appear, with no error. Use `manuscripts` for journal
articles.

### Add a new page

Create `_pages/thing.md` with a `permalink:`, then add it to the nav:

```markdown
---
title: "Thing"
permalink: /thing/
author_profile: true
---
```

`author_profile: true` shows the left sidebar. Set it to `false` for a
full-width page — that's what `/pendulum/` does, along with `classes: wide`.

### Change the top navigation

Edit `_data/navigation.yml`. Order in the file is order on screen.

```yaml
main:
  - title: "About"
    url: /
```

Adding a page to `_pages/` does **not** put it in the nav, and removing it from
the nav does **not** unpublish the page. Two separate steps.

### Change the sidebar (photo, bio, social links)

All of it is the `author:` block in `_config.yml` — name, bio, location,
employer, email, and the social icons. A field left blank hides its icon.
Currently set: email, Google Scholar, GitHub, LinkedIn.

The photo is `author.avatar`, resolved relative to `images/`. Currently
`eiffel-headshot.jpg`.

### Edit the CV

`_pages/cv.md`, plain Markdown. Sections use `Heading\n======` style.
Conference presentations and teaching live here directly (teaching is under
Experience as the Graduate Teaching Assistant entry). Publications do **not** —
they come from `_publications/`.

The downloadable PDF is `files/JackCrewseCV.pdf`. Replacing that file is all
that's needed; the link points at a fixed path.

### Add a PDF or an image

PDFs and downloads → `files/`. Images → `images/`. Reference them from
Markdown as `/files/name.pdf` and `/images/name.jpg`.

### Math

Write LaTeX inline as `$...$` or display as `$$...$$`. It works on every page
with no front matter flag — see [MathJax is hand-added](#mathjax-is-hand-added).

---

## Deploying

Push to `main`. That's it — the Action does the rest, usually in about a minute.

Other branches **build but don't deploy**, so you can push a branch to check
that it compiles without touching the live site. That gate is the `if:` on the
`deploy` job in `.github/workflows/pages-deploy.yml`.

To see what happened:

```bash
gh run list --branch main --limit 5
```

```bash
gh run view --log-failed
```

If a build fails, nothing deploys and the live site stays exactly as it was.
A failed build cannot break the published site.

---

## The link checker

`.github/scripts/check-links.rb` runs on every build, before publishing. It
resolves every internal link and image in the built site and fails the build if
any of them 404. That's what stops a broken link from ever reaching the site.

It checks **internal links only** — external URLs (journal links, etc.) are not
verified, so those can still rot silently.

It runs a self-test first, against a fixture with a deliberately broken link.
That's deliberate: the dangerous failure for a link checker is silently finding
*nothing*, which looks exactly like a clean site. If the self-test ever fails,
believe it — the checker is broken, not your links.

To run it yourself you need a built `_site/` (see below), then:

```bash
bundle exec ruby .github/scripts/check-links.rb
```

---

## Previewing locally

**There is currently no Ruby on this machine, so local preview doesn't work
yet.** Every check today happens in CI. That's workable but slow.

To set it up, install Ruby 3.1+, then:

```bash
bundle install
```

```bash
bundle exec jekyll serve --livereload
```

That serves the site at <http://localhost:4000> and rebuilds as you save. Worth
doing if you plan to make frequent edits — ask and I'll wire it up.

---

## Things that will surprise you

### The theme is vendored

academicpages is not a gem. `_layouts/`, `_includes/`, `_sass/` and `assets/`
are *copies* of the theme, committed to this repo. Consequences:

- You can edit any of it directly — nothing is hidden.
- Theme updates are a manual merge, not a version bump.
- Those folders are theme code. Prefer changing `_config.yml` or content first.

### MathJax is hand-added

Stock academicpages ships **no math support at all**. MathJax is configured in
`_includes/head/custom.html`, set up for `$...$` inline math. If math stops
rendering, that file is why.

### `sw.js` is a tombstone

The previous theme (Chirpy) registered a cache-first service worker that served
stale pages forever. `sw.js` at the repo root exists solely to unregister it and
clear those caches for returning visitors. It is not a real service worker.

Safe to delete around mid-2027, once anyone who visited the old site has come
back at least once.

### `_sass/vendor/` must stay tracked

`.gitignore` has `/vendor` — **anchored to the root on purpose**. A bare
`vendor` also matches `_sass/vendor/`, which holds Font Awesome and the Susy
grid the entire layout depends on. Silently dropping those 92 files breaks the
build with a confusing SCSS import error. Don't un-anchor that line.

### html-proofer doesn't work here

The standard Jekyll link checker reports "Checking 0 internal links" and passes
broken links in this environment — every 5.x version, bundled and standalone.
That's why the custom checker exists. Don't swap it back in without testing it
against a known-broken link first.

### Post URLs are pinned

`permalink: /posts/:title/` in `_config.yml` is inherited from the old Chirpy
site so existing links keep working. `/curriculum-vitae/` and `/year-archive/`
also redirect to their new homes via `redirect_from:`. Changing these breaks
inbound links.

---

## File map

```
_config.yml              Site settings, author sidebar, collections
_data/navigation.yml     Top nav menu
_pages/                  Standalone pages (about, cv, publications, blog, pendulum)
_posts/                  Published blog posts
_drafts/                 Unpublished drafts, never built
_publications/           One file per paper
files/                   PDFs (CV, thesis)
images/                  Photos and favicons
sw.js                    Service-worker tombstone (see above)
_layouts/ _includes/     Theme templates -- vendored
_sass/ assets/           Theme styles and JS -- vendored
.github/workflows/       Build + deploy pipeline
.github/scripts/         Link checker
```
