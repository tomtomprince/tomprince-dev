# tomprince.dev — Implementation Hand-off

Hand-off document for scaffolding a personal site at `tomprince.dev`. Output of a design conversation; all major decisions are made. A few items are flagged as defaulted — if the owner prefers otherwise, they'll say so before you start.

## Context

- Owner: Tom Prince, full-stack software engineer, currently at hibambi.com.
- Goal: Personal site for writing across software and other topics. Primarily for the owner's own use; no audience assumed.
- Inspirations (in rough priority): mitchellh.com (primary aesthetic/structural target), sive.rs, simonwillison.net, evanhahn.com, dhh.dk. IndieWeb-adjacent but not IndieWeb-maximalist.
- Workflow: nvim-first, plain text, markdown. Owner journals in nvim and wants the writing pipeline to match.

## Stack decisions (fixed)

- **Static site generator**: Hugo (extended).
- **Theme**: None. Write layouts directly in `/layouts/`. Do not install or vendor a theme.
- **Config format**: TOML.
- **Hosting**: VPS, Caddy as web server, automatic HTTPS.
- **Deploy**: `hugo --minify` + `rsync` to VPS. Manual invocation via script; no CI on day one.
- **Comments**: None.
- **Analytics**: None.
- **Search**: None.
- **POSSE/automation**: None on day one. Microformats2 markup is required in templates so it can be added later without migration.

## Repository structure

```
tomprince.dev/
├── archetypes/
│   ├── default.md
│   └── posts.md
├── assets/
│   └── css/
│       └── main.css
├── content/
│   ├── _index.md           # homepage content
│   ├── posts/
│   │   └── _index.md       # posts list page
│   ├── now.md
│   ├── about.md
│   └── colophon.md
├── layouts/
│   ├── _default/
│   │   ├── baseof.html
│   │   ├── single.html
│   │   ├── list.html
│   │   └── rss.xml
│   ├── index.html          # homepage, distinct from list
│   ├── partials/
│   │   ├── head.html
│   │   ├── header.html
│   │   ├── footer.html
│   │   └── hcard.html
│   └── taxonomy/
│       └── tag.html
├── static/
│   ├── favicon.ico
│   └── robots.txt
├── scripts/
│   ├── newpost
│   └── deploy
├── config.toml
├── Caddyfile               # reference copy; actual lives on VPS
├── .gitignore
└── README.md
```

## URL structure (defaulted — confirm)

**Default**: `/:year/:slug/` for posts (e.g., `/2026/thinking-about-hugo/`). Standalone pages at root (`/now/`, `/about/`, etc.). Tag pages at `/tags/:tag/`.

Rationale: year in URL signals dated-blog intent, keeps archive navigable, survives reorganization better than flat `/slug/` if structure expands later.

If the owner prefers `/slug/` (flat, Mitchell-style) or `/posts/:slug/`, adjust `permalinks` in `config.toml` and the `newpost` script accordingly.

## config.toml

```toml
baseURL = "https://tomprince.dev/"
languageCode = "en-us"
title = "Tom Prince"
theme = ""  # no theme; layouts are in /layouts/
enableRobotsTXT = true
enableEmoji = false
enableGitInfo = true  # for lastmod on living docs

[permalinks]
  posts = "/:year/:slug/"

[params]
  author = "Tom Prince"
  description = "Personal site of Tom Prince."
  # Homepage shows the N most recent posts
  homepageRecentPosts = 5

[taxonomies]
  tag = "tags"

[markup.goldmark.renderer]
  unsafe = true  # allow raw HTML in markdown when needed

[markup.highlight]
  noClasses = false
  style = "github"

[outputs]
  home = ["HTML", "RSS"]
  section = ["HTML", "RSS"]

[mainSections]
  # controls what the site-wide RSS pulls from
  # starts as just posts; add sections here as they're introduced
```

## Archetypes

`archetypes/default.md` — fallback for non-post content:

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
draft = true
+++
```

`archetypes/posts.md` — posts:

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
draft = true
tags = []
+++
```

Keep archetypes minimal. Do not add fields speculatively.

## Templates: requirements

All templates must produce semantic, accessible HTML. No JS unless a specific feature requires it (none do on day one).

### `layouts/_default/baseof.html`

Outer shell. Includes `head` partial, `header` partial, a `{{ block "main" . }}` for content, and `footer` partial. Sets `lang="en"` on html element.

### `layouts/partials/head.html`

- Charset, viewport
- `<title>` — page title with site title suffix, except on homepage
- `<meta name="description">` — page description or site description fallback
- Canonical URL
- RSS autodiscovery link for the current section's feed
- Linked stylesheet (processed from `assets/css/main.css` via Hugo Pipes, fingerprinted)
- Open Graph and Twitter card tags (basic)
- No external resources (no Google Fonts, no analytics, no trackers)

### `layouts/partials/header.html`

Minimal site header: site title as link to `/`, plus nav links to `/posts/`, `/now/`, `/about/`. Nothing else.

### `layouts/partials/footer.html`

- Copyright line
- Link to `/colophon/`
- RSS link
- The `h-card` partial (hidden or footer-visible — see below)

### `layouts/partials/hcard.html`

Microformats2 `h-card` for the site owner. Must include `p-name`, `u-url`, and `u-email` (the last optional; owner to decide). This partial is included in the footer of every page so the h-card is site-wide.

### `layouts/index.html` (homepage, distinct from list)

- Short intro/bio (pulled from `content/_index.md`)
- List of N most recent posts (N from `Site.Params.homepageRecentPosts`)
- Link to full archive (`/posts/`)
- No pagination on homepage

### `layouts/_default/single.html`

The post page. **Must include microformats2:**

- Wrapping `<article class="h-entry">`
- `<h1 class="p-name">` for title
- `<time class="dt-published" datetime="...">` for date, with both machine-readable datetime attribute and human-readable text
- `<div class="e-content">` wrapping the rendered content
- Author attribution via `h-card` (can be the footer partial, or explicit `<a class="p-author h-card" href="/">Tom Prince</a>`)
- If `lastmod` differs meaningfully from `date`, render a `<time class="dt-updated">` as well
- Tag links at the bottom, each with `class="p-category"`

Validate against [indiewebify.me](https://indiewebify.me) after first post exists.

### `layouts/_default/list.html`

Reverse-chronological list of pages in the section. Each entry: title (linked), date, optional short summary if present. No pagination on day one (add later if needed).

### `layouts/taxonomy/tag.html`

Same shape as list.html but scoped to the tag.

### `layouts/_default/rss.xml`

Override Hugo's default to emit **full post content**, not summaries. Use `{{ .Content | html }}` inside `<description>` wrapped in CDATA. Include `<pubDate>`, `<guid>`, `<author>`, and per-item `<category>` tags from the post's tags.

## CSS direction

Single file at `assets/css/main.css`, processed by Hugo Pipes, fingerprinted in output. Target: under 200 lines.

- System font stack for body. Suggested: `ui-serif, Georgia, Cambria, "Times New Roman", serif` for a Mitchell-leaning serif feel. Owner to confirm serif vs sans.
- Body: `line-height: 1.7`, `max-width: 68ch`, centered with left/right padding that scales down on mobile.
- Color palette: near-black text on near-white background. One accent color for links (suggest a muted blue or the owner's choice). Underlined links by default.
- `prefers-color-scheme: dark` support with an inverted palette.
- Code blocks: monospace system stack, subtle background, horizontal scroll on overflow. No line numbers on day one.
- No hero images, no post thumbnails, no "related posts", no reading time, no author boxes on posts.
- Print stylesheet is not required on day one.

## Content scaffolding

Create these files with minimal placeholder content the owner will replace:

- `content/_index.md` — homepage intro, 1–3 sentences max. Placeholder: "Tom Prince. Software engineer. Writing here when I have something to say."
- `content/posts/_index.md` — one-line description for the posts archive.
- `content/now.md` — /now page. Include a link to nownownow.com in a comment. Front matter only + a single paragraph placeholder.
- `content/about.md` — placeholder. Mention the opinions-are-my-own disclaimer.
- `content/colophon.md` — describes the site stack (Hugo, no theme, VPS, Caddy, microformats2). This page exists as the answer to "what's this site built with."

## Scripts

### `scripts/newpost`

```sh
#!/bin/sh
set -e
cd "$(dirname "$0")/.."
if [ -z "$*" ]; then
  echo "usage: newpost <title words>" >&2
  exit 1
fi
slug=$(echo "$*" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-' | tr -cd 'a-z0-9-')
hugo new --kind posts "posts/$slug.md"
# path Hugo actually wrote to:
target="content/posts/$slug.md"
${EDITOR:-nvim} "$target"
```

Note: the permalink pattern handles the year segment in URLs, but the source file lives flat in `content/posts/`. If the owner prefers year-based source directories for filesystem navigability, change the `hugo new` path to `posts/$(date +%Y)/$slug.md` — Hugo will still produce the same URL.

### `scripts/deploy`

```sh
#!/bin/sh
set -e
cd "$(dirname "$0")/.."
hugo --minify --gc
rsync -avz --delete \
  --exclude='.well-known' \
  public/ \
  deploy@tomprince.dev:/var/www/tomprince.dev/
```

The `--exclude='.well-known'` preserves anything Caddy puts there for ACME challenges. Adjust user/host as needed.

Both scripts: `chmod +x`.

## Caddyfile (reference)

Lives on the VPS at `/etc/caddy/Caddyfile`. Reference copy in the repo for documentation.

```
tomprince.dev, www.tomprince.dev {
    @www host www.tomprince.dev
    redir @www https://tomprince.dev{uri} permanent

    root * /var/www/tomprince.dev
    file_server
    encode gzip zstd

    header {
        X-Content-Type-Options nosniff
        Referrer-Policy strict-origin-when-cross-origin
        Permissions-Policy "interest-cohort=()"
    }

    # Serve .xml as application/rss+xml when appropriate
    @rss path *.xml
    header @rss Content-Type "application/rss+xml; charset=utf-8"
}
```

## .gitignore

```
/public/
/resources/
/.hugo_build.lock
.DS_Store
*.swp
```

## README.md

Brief. Document:
- What the site is
- How to run locally (`hugo server -D`)
- How to create a post (`scripts/newpost "title"`)
- How to deploy (`scripts/deploy`)
- Where the Caddyfile lives on the VPS
- License for content vs. code (owner to decide; suggest CC BY 4.0 for content, MIT for code, but leave as TODO)

## Acceptance criteria

After scaffolding:

1. `hugo server -D` runs without errors and serves the site at `localhost:1313`.
2. A sample post created via `scripts/newpost "hello world"` renders correctly at `/2026/hello-world/` after removing the `draft = true` line.
3. The homepage shows the intro plus recent posts list.
4. `/posts/` shows a full archive.
5. `/index.xml` and `/posts/index.xml` both exist and contain full post content (not summaries).
6. A post page validates as an h-entry on indiewebify.me (after being deployed to a reachable URL — or verified by inspection).
7. The homepage includes an h-card for Tom Prince.
8. No external resources loaded (check Network tab: every request is to tomprince.dev).
9. Dark mode switches correctly via `prefers-color-scheme`.
10. Total CSS under 200 lines.

## Open decisions (defaulted — owner to override if desired)

1. **URL structure**: defaulted to `/:year/:slug/`. Alternatives: `/:slug/` or `/posts/:slug/`.
2. **Body font**: defaulted to serif (Mitchell-lean). Owner may prefer sans.
3. **Accent color**: defaulted to a muted blue. Owner to pick final hex.
4. **Email in h-card**: include or omit — owner to decide.
5. **Content license**: TODO in README until owner decides.

## Explicit non-goals (do not add)

- No theme installation
- No JavaScript framework, bundler, or npm dependencies
- No comments system
- No analytics of any kind
- No newsletter signup
- No social share buttons
- No "related posts" computation
- No reading-time estimate
- No author bio box on posts (h-card in footer is sufficient)
- No POSSE automation, webmention receiver, or ActivityPub bridge on day one (microformats2 markup is the only IndieWeb-related requirement)
- No pagination on day one
- No search on day one

## Things to do after scaffolding (owner, not Claude Code)

- Provision VPS, install Caddy, create `deploy` user, set up SSH key
- Point DNS (A/AAAA for apex, CNAME or A for www)
- Write first real post
- Validate h-entry/h-card at indiewebify.me
- Decide and document content license in README
