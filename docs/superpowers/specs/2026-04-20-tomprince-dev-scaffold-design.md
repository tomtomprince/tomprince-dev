# tomprince.dev Scaffold — Design

**Date:** 2026-04-20
**Status:** Approved; ready for implementation planning
**Base document:** `handoff.md` in the repo root. This spec is the consolidated, gap-filled version for the planner. Where this document and `handoff.md` differ, this document wins.

## 1. Overview

Scaffold a Hugo-based static personal site for Tom Prince at `tomprince.dev`. Single-owner writing site, nvim-first workflow, deployed to a self-managed VPS with Caddy. No theme, no JavaScript, no npm, no analytics, no comments, no search, no pagination. Microformats2 (`h-entry`, `h-card`, `h-feed`) required in templates so IndieWeb features can be layered on later without migration.

## 2. Decisions at a glance

| Topic | Decision |
|---|---|
| SSG | Hugo extended |
| Theme | None — layouts in `/layouts/` |
| Config file | `hugo.toml` (TOML) |
| Timezone | `UTC` |
| URL structure (posts) | `/:year/:slug/` |
| Body font | Serif system stack (owner may override) |
| Accent color | Placeholder muted blue; owner picks final hex |
| h-card email | Omitted on day one |
| RSS author | `<dc:creator>Tom Prince</dc:creator>` (no email) |
| RSS content | Full content, `{{ .Content \| safeHTML }}` inside CDATA |
| RSS autodiscovery | Site-wide feed `/index.xml` on every page |
| Microformats | h-entry on posts, h-feed on list pages, h-card in footer |
| AI/LLM crawlers | Stance B (block training, allow on-demand) |
| `llms.txt` | Omitted day one; revisit later |
| Hosting | VPS + Caddy, automatic HTTPS |
| Deploy | `scripts/deploy` → `hugo --minify` + `rsync` |
| Content license | TODO in README |

## 3. Delta from `handoff.md`

Changes applied:

1. **RSS template** uses `{{ .Content | safeHTML }}` inside CDATA (was: `| html`, which double-escapes).
2. **RSS author** switches to `<dc:creator>` with Dublin Core namespace; the `<author>` tag is omitted because it requires an email.
3. **RSS autodiscovery** in `head.html` always links the site-wide feed `/index.xml`, not per-section.
4. **`mainSections = ["posts"]`** set explicitly.
5. **`timeZone = "UTC"`** added.
6. **`config.toml` → `hugo.toml`** (modern Hugo convention).
7. **`robots.txt`** rendered from `layouts/robots.txt`; `static/robots.txt` removed. Includes AI-bot block list (Stance B).
8. **`layouts/404.html`** added; Caddyfile gains `handle_errors` block.
9. **`layouts/_default/terms.html`** added for `/tags/` index.
10. **`layouts/index.html`** and **`layouts/_default/list.html`** wrap post lists in `<div class="h-feed">`.
11. **Caddyfile** gains `Strict-Transport-Security`, `Content-Security-Policy`, and `X-Robots-Tag: noai, noimageai` headers.
12. **`scripts/deploy`** adds `public/index.html` sanity check and `DRY_RUN=1` env var support.
13. **`scripts/newpost`** collapses repeated dashes and errors on empty slug.
14. **`git init` + initial commit** included in scaffolding so `enableGitInfo` works.
15. **Hugo version** recorded in README ("tested with Hugo vX.Y.Z extended").

Unchanged from `handoff.md`: URL structure, archetypes shape, CSS direction, content scaffolding, .gitignore, non-goals, and the bulk of template requirements.

## 4. Repository layout

```
tomprince.dev/
├── archetypes/
│   ├── default.md
│   └── posts.md
├── assets/
│   └── css/
│       └── main.css
├── content/
│   ├── _index.md
│   ├── posts/
│   │   └── _index.md
│   ├── now.md
│   ├── about.md
│   └── colophon.md
├── layouts/
│   ├── _default/
│   │   ├── baseof.html
│   │   ├── single.html
│   │   ├── list.html
│   │   ├── terms.html
│   │   └── rss.xml
│   ├── taxonomy/
│   │   └── tag.html
│   ├── partials/
│   │   ├── head.html
│   │   ├── header.html
│   │   ├── footer.html
│   │   └── hcard.html
│   ├── 404.html
│   ├── index.html
│   └── robots.txt
├── static/
│   └── favicon.ico
├── scripts/
│   ├── newpost
│   └── deploy
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-04-20-tomprince-dev-scaffold-design.md
├── hugo.toml
├── Caddyfile                    # reference copy; live copy on VPS
├── CLAUDE.md
├── handoff.md                   # retained as history
├── .gitignore
└── README.md
```

## 5. `hugo.toml`

```toml
baseURL = "https://tomprince.dev/"
languageCode = "en-us"
title = "Tom Prince"
timeZone = "UTC"
enableRobotsTXT = true
enableEmoji = false
enableGitInfo = true

mainSections = ["posts"]

[permalinks]
  posts = "/:year/:slug/"

[params]
  author = "Tom Prince"
  description = "Personal site of Tom Prince."
  homepageRecentPosts = 5

[taxonomies]
  tag = "tags"

[markup.goldmark.renderer]
  unsafe = true

[markup.highlight]
  noClasses = false
  style = "github"

[outputs]
  home = ["HTML", "RSS"]
  section = ["HTML", "RSS"]
```

## 6. Archetypes

`archetypes/default.md`:

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
draft = true
+++
```

`archetypes/posts.md`:

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
draft = true
tags = []
+++
```

Keep archetypes minimal. Do not add fields speculatively.

## 7. Templates

All templates emit semantic, accessible HTML. No JS.

### 7.1 `layouts/_default/baseof.html`

Outer shell: `<html lang="en">`, includes `head` partial, `header` partial, `{{ block "main" . }}`, `footer` partial.

### 7.2 `layouts/partials/head.html`

- Charset, viewport
- `<title>` — page title with site title suffix, except on homepage
- `<meta name="description">` — page description or site description fallback
- Canonical URL
- RSS autodiscovery link: always the site-wide feed (`<link rel="alternate" type="application/rss+xml" href="/index.xml">`)
- Stylesheet processed from `assets/css/main.css` via Hugo Pipes, minified and fingerprinted
- Open Graph and Twitter card tags (text only; no `og:image` on day one)
- **No** external resources (no fonts, no analytics, no trackers)

### 7.3 `layouts/partials/header.html`

Site title as link to `/`, nav links to `/posts/`, `/now/`, `/about/`. Nothing else.

### 7.4 `layouts/partials/footer.html`

- Copyright line
- Link to `/colophon/`
- RSS link
- `hcard` partial

### 7.5 `layouts/partials/hcard.html`

Microformats2 `h-card`. Includes `p-name` and `u-url`. **Omits `u-email`** on day one. Included in footer site-wide.

### 7.6 `layouts/index.html` (homepage)

- Short intro/bio from `content/_index.md`
- List of most recent posts (count from `Site.Params.homepageRecentPosts`), wrapped in `<div class="h-feed">`, each entry as a minimal `h-entry` (`p-name` link + `dt-published`)
- Link to `/posts/` for the full archive
- No pagination

### 7.7 `layouts/_default/single.html`

Post page. Required markup:

- `<article class="h-entry">`
- `<h1 class="p-name">` for title
- `<time class="dt-published" datetime="{ISO-8601}">` with both machine-readable `datetime` and human-readable text
- `<div class="e-content">` wrapping rendered content
- Author attribution via the footer h-card (no explicit per-post `p-author` needed; the footer h-card is site-wide)
- If `lastmod` differs meaningfully from `date`, emit `<time class="dt-updated">`
- Tag links at the bottom, each with `class="p-category"`

Validate against indiewebify.me after first post is live.

### 7.8 `layouts/_default/list.html`

Reverse-chronological list of pages in the section. Each entry: title linked, date, optional summary if present. Wrap in `<div class="h-feed">`; each entry as a minimal `h-entry`. No pagination.

### 7.9 `layouts/_default/terms.html`

Index page at `/tags/` listing all tags alphabetically with post counts. Minimal markup.

### 7.10 `layouts/taxonomy/tag.html`

Per-tag archive (same shape as `list.html`, scoped to the tag).

### 7.11 `layouts/_default/rss.xml`

Override Hugo default. Requirements:

- `<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">`
- Full post content via `{{ .Content | safeHTML }}` wrapped in `<![CDATA[ ... ]]>` inside `<description>`
- `<pubDate>` per item (RFC 1123)
- `<guid isPermaLink="true">` per item
- `<dc:creator>Tom Prince</dc:creator>` per item (used instead of `<author>` so no email is required)
- `<category>` per item per tag
- `<atom:link rel="self" .../>` on the channel

### 7.12 `layouts/404.html`

Minimal custom 404. Uses the baseof shell. Short message ("Not found.") + link to `/`.

### 7.13 `layouts/robots.txt` (Hugo-rendered)

```
User-agent: *
Allow: /

Sitemap: {{ "sitemap.xml" | absURL }}

# Stance B: block training crawlers; on-demand fetchers (ChatGPT-User,
# Claude-User, Perplexity-User, etc.) remain allowed by default.
User-agent: GPTBot
Disallow: /
User-agent: ClaudeBot
Disallow: /
User-agent: anthropic-ai
Disallow: /
User-agent: Google-Extended
Disallow: /
User-agent: CCBot
Disallow: /
User-agent: Applebot-Extended
Disallow: /
User-agent: Bytespider
Disallow: /
User-agent: Amazonbot
Disallow: /
User-agent: Meta-ExternalAgent
Disallow: /
User-agent: FacebookBot
Disallow: /
User-agent: PerplexityBot
Disallow: /
User-agent: Diffbot
Disallow: /
User-agent: ImagesiftBot
Disallow: /
User-agent: cohere-ai
Disallow: /
User-agent: Omgilibot
Disallow: /
```

## 8. CSS direction

Single file at `assets/css/main.css`, processed by Hugo Pipes (minify + fingerprint). Target: under 200 lines.

- System serif stack for body: `ui-serif, Georgia, Cambria, "Times New Roman", serif` (owner may override to sans)
- Body: `line-height: 1.7`, `max-width: 68ch`, centered with responsive left/right padding
- Near-black text on near-white background; one accent color for links (underlined by default)
- `prefers-color-scheme: dark` with inverted palette
- Code blocks: monospace system stack, subtle background, horizontal scroll on overflow; no line numbers
- No hero images, no post thumbnails, no related-posts, no reading-time, no author box
- No print stylesheet on day one

## 9. Content scaffolding

Placeholders the owner will replace:

- `content/_index.md` — 1–3 sentence intro. Placeholder: "Tom Prince. Software engineer. Writing here when I have something to say."
- `content/posts/_index.md` — one-line description.
- `content/now.md` — `/now` page. Include a commented link to nownownow.com. Front matter + single paragraph placeholder.
- `content/about.md` — placeholder with opinions-are-my-own disclaimer.
- `content/colophon.md` — describes the stack (Hugo, no theme, VPS, Caddy, microformats2).

## 10. Scripts

### 10.1 `scripts/newpost`

```sh
#!/bin/sh
set -e
cd "$(dirname "$0")/.."
if [ -z "$*" ]; then
  echo "usage: newpost <title words>" >&2
  exit 1
fi
slug=$(echo "$*" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-' | tr -cd 'a-z0-9-' | tr -s '-')
slug=${slug#-}
slug=${slug%-}
if [ -z "$slug" ]; then
  echo "error: slug is empty after normalization" >&2
  exit 1
fi
hugo new --kind posts "posts/$slug.md"
target="content/posts/$slug.md"
${EDITOR:-nvim} "$target"
```

Note: posts live flat in `content/posts/`; the year segment in the URL comes from the `permalinks` pattern, not the source path.

### 10.2 `scripts/deploy`

```sh
#!/bin/sh
set -e
cd "$(dirname "$0")/.."
hugo --minify --gc
if [ ! -f public/index.html ]; then
  echo "error: public/index.html missing after build; aborting deploy" >&2
  exit 1
fi
DRY_FLAG=""
[ "${DRY_RUN:-0}" = "1" ] && DRY_FLAG="--dry-run"
rsync -avz --delete $DRY_FLAG \
  --exclude='.well-known' \
  public/ \
  deploy@tomprince.dev:/var/www/tomprince.dev/
```

Both scripts: `chmod +x`.

## 11. Caddyfile

Lives on the VPS at `/etc/caddy/Caddyfile`. Reference copy in the repo.

```
tomprince.dev, www.tomprince.dev {
    @www host www.tomprince.dev
    redir @www https://tomprince.dev{uri} permanent

    root * /var/www/tomprince.dev
    file_server
    encode gzip zstd

    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        Content-Security-Policy "default-src 'self'; style-src 'self'; img-src 'self' data:; base-uri 'self'; form-action 'self'; frame-ancestors 'none'"
        X-Content-Type-Options nosniff
        Referrer-Policy strict-origin-when-cross-origin
        Permissions-Policy "interest-cohort=()"
        X-Robots-Tag "noai, noimageai"
    }

    handle_errors {
        @404 expression {err.status_code} == 404
        rewrite @404 /404.html
        file_server
    }

    @rss path_regexp rss_path (^|/)index\.xml$
    header @rss Content-Type "application/rss+xml; charset=utf-8"
}
```

HSTS omits `preload` deliberately — add it only after submitting to the HSTS preload list.

## 12. `.gitignore`

```
/public/
/resources/
/.hugo_build.lock
.DS_Store
*.swp
```

## 13. `README.md` requirements

Brief. Document:

- What the site is
- Hugo version tested against (`hugo version` output at scaffold time)
- How to run locally (`hugo server -D`)
- How to create a post (`scripts/newpost "title"`)
- How to deploy (`scripts/deploy`; `DRY_RUN=1 scripts/deploy` for preview)
- Where the Caddyfile lives on the VPS
- Content license: TODO (suggest CC BY 4.0 for content, MIT for code)

## 14. Acceptance criteria

After scaffolding:

1. `hugo server -D` runs without errors and serves the site at `localhost:1313`.
2. A sample post created via `scripts/newpost "hello world"` renders at `/2026/hello-world/` after removing `draft = true`.
3. Homepage shows intro plus recent posts list, wrapped in `h-feed`.
4. `/posts/` shows a full archive, wrapped in `h-feed`.
5. `/index.xml` and `/posts/index.xml` exist and contain full post content (not summaries), unescaped inside CDATA.
6. RSS root element declares the Dublin Core namespace; each item carries a `<dc:creator>` tag.
7. A post page would validate as `h-entry` on indiewebify.me (verified by inspection until a reachable URL exists).
8. Homepage includes site-wide `h-card` (in footer).
9. No external resources loaded (Network tab: every request is to `tomprince.dev`).
10. Dark mode switches via `prefers-color-scheme`.
11. Total CSS under 200 lines.
12. `/404.html` renders as a Hugo-built page; Caddy's `handle_errors` serves it for unknown paths (verified by inspection until VPS is live).
13. `/tags/` lists all tags (terms page).
14. `/robots.txt` contains the AI-bot block list (Stance B).
15. Response headers (once deployed) include CSP, HSTS, `X-Robots-Tag: noai, noimageai`.
16. `DRY_RUN=1 scripts/deploy` completes without writing to the VPS.
17. `scripts/newpost` with an all-punctuation title exits non-zero.
18. Repo is a git repo with at least one commit (so `enableGitInfo` works without warnings).

## 15. Non-goals (do not add)

- No theme installation
- No JavaScript framework, bundler, or npm dependencies
- No comments system
- No analytics of any kind
- No newsletter signup
- No social share buttons
- No related-posts computation
- No reading-time estimate
- No author bio box on posts (footer h-card suffices)
- No POSSE automation, webmention receiver, or ActivityPub bridge on day one (microformats2 markup is the only IndieWeb-related requirement)
- No pagination on day one
- No search on day one
- No `llms.txt` on day one
- No `og:image` on day one

## 16. Open owner TODOs (post-scaffold, not Claude Code)

**Site / content:**
- Pick final accent color hex
- Decide serif vs sans body font
- Write first real post
- Provision VPS, install Caddy, create `deploy` user, set up SSH key
- DNS: A/AAAA for apex, CNAME or A for www
- Validate `h-entry`/`h-card` at indiewebify.me
- Decide and document content license in README
- Revisit `u-email` inclusion in h-card
- Revisit `llms.txt`
- Consider HSTS preload submission once confident in HTTPS stability
- Replace `static/favicon.ico` placeholder

**Minor code improvements (from final review — low priority):**
- Add `:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }` to `main.css` for keyboard navigation
- `scripts/deploy`: the unquoted `$DRY_FLAG` in the rsync invocation triggers `shellcheck` SC2086; conventional POSIX workaround, low practical risk
- `layouts/_default/single.html`: `/about/` and `/now/` pages show their `date` field as a visible timestamp — add a `layouts/page.html` layout without the date block if you want static pages to look dateless
- `hugo.toml`: `mainSections` at root scope works but is semantically a params-level key; add a comment clarifying it's a Hugo site-level config key
