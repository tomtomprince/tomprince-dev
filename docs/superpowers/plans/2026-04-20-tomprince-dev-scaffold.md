# tomprince.dev Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold a Hugo (extended) personal site at `tomprince.dev` to the state defined in `docs/superpowers/specs/2026-04-20-tomprince-dev-scaffold-design.md`, verified against the spec's acceptance criteria.

**Architecture:** Static site built by Hugo, no theme, layouts written directly. Microformats2 markup (`h-entry`, `h-feed`, `h-card`) in templates. Deploy via `rsync` to a VPS running Caddy. No JavaScript, no npm, no analytics.

**Tech Stack:** Hugo extended (any modern version — record the actual version at scaffold time), Go HTML templates, POSIX shell, plain CSS processed through Hugo Pipes, git, Caddy (reference only).

**Commit policy:** The owner handles all `git commit` invocations. Each task ends with `git add <files>` and a status message. **Do NOT run `git commit` in any task.** After staging, tell the owner the task is ready to commit.

**Working directory:** `/Users/thomasprince/dev/tomprince-dev` (treat as site root). Spec file is at `docs/superpowers/specs/2026-04-20-tomprince-dev-scaffold-design.md` — consult it for background, but each task below is self-contained.

---

## File Map

| Path | Created by | Responsibility |
|---|---|---|
| `.gitignore` | Task 1 | Ignore Hugo build output and editor scratch files |
| `hugo.toml` | Task 2 | Site config (baseURL, taxonomies, permalinks, outputs, markup) |
| `archetypes/default.md` | Task 3 | Front matter template for non-post content |
| `archetypes/posts.md` | Task 3 | Front matter template for posts (adds `tags = []`) |
| `content/_index.md` | Task 4 | Homepage intro body |
| `content/posts/_index.md` | Task 4 | Posts section landing body |
| `content/now.md` | Task 4 | `/now` page placeholder |
| `content/about.md` | Task 4 | `/about` page placeholder |
| `content/colophon.md` | Task 4 | `/colophon` page describing the stack |
| `layouts/partials/head.html` | Task 5 | `<head>` contents (meta, title, stylesheet, RSS autodiscovery) |
| `layouts/partials/header.html` | Task 6 | Site header + primary nav |
| `layouts/partials/hcard.html` | Task 7 | `h-card` microformat partial (no `u-email`) |
| `layouts/partials/footer.html` | Task 8 | Site footer (copyright, colophon link, RSS link, h-card) |
| `layouts/_default/baseof.html` | Task 9 | Base HTML shell; all page templates extend this |
| `layouts/index.html` | Task 10 | Homepage (intro + h-feed of recent posts) |
| `layouts/_default/list.html` | Task 11 | Section archive (posts archive) with h-feed |
| `layouts/_default/single.html` | Task 12 | Post page with full h-entry markup |
| `layouts/_default/terms.html` | Task 13 | `/tags/` index listing all tags |
| `layouts/taxonomy/tag.html` | Task 14 | Per-tag archive with h-feed |
| `layouts/404.html` | Task 15 | Custom 404 page |
| `layouts/_default/rss.xml` | Task 16 | RSS with Dublin Core namespace, full content in CDATA |
| `layouts/robots.txt` | Task 17 | Hugo-rendered `robots.txt` with AI-bot blocklist |
| `assets/css/main.css` | Task 18 | Site styles (under 200 lines, dark mode aware) |
| `static/favicon.ico` | Task 19 | Favicon placeholder |
| `scripts/newpost` | Task 20 | Create a new draft post |
| `scripts/deploy` | Task 21 | Build + rsync to VPS (with `DRY_RUN=1` support) |
| `Caddyfile` | Task 22 | Reference copy of the VPS Caddy config |
| `README.md` | Task 23 | Project overview, commands, Hugo version pin |

---

## Execution Order

- **Phase 0 — Foundation:** Tasks 1–2 (git + config)
- **Phase 1 — Content scaffolding:** Tasks 3–4 (archetypes + placeholders)
- **Phase 2 — Partials:** Tasks 5–8 (head, header, hcard, footer)
- **Phase 3 — Base + page layouts:** Tasks 9–16
- **Phase 4 — robots.txt:** Task 17
- **Phase 5 — Assets:** Tasks 18–19 (CSS, favicon)
- **Phase 6 — Scripts:** Tasks 20–21 (newpost, deploy)
- **Phase 7 — Reference docs:** Tasks 22–23 (Caddyfile, README)
- **Phase 8 — Acceptance validation:** Task 24

Each task assumes the working directory is `/Users/thomasprince/dev/tomprince-dev` unless otherwise noted.

---

### Task 1: Initialize git repo and `.gitignore`

**Files:**
- Create: `.gitignore`
- Run: `git init`

- [ ] **Step 1: Create `.gitignore`**

Write to `/Users/thomasprince/dev/tomprince-dev/.gitignore`:

```
/public/
/resources/
/.hugo_build.lock
.DS_Store
*.swp
```

- [ ] **Step 2: Initialize git**

Run:
```bash
cd /Users/thomasprince/dev/tomprince-dev && git init
```

Expected: `Initialized empty Git repository in …/tomprince-dev/.git/`.

- [ ] **Step 3: Stage existing files**

Run:
```bash
git add .gitignore CLAUDE.md handoff.md docs/
```

- [ ] **Step 4: Verify staging**

Run: `git status --short`

Expected: lines starting with `A` for `.gitignore`, `CLAUDE.md`, `handoff.md`, and files under `docs/`.

- [ ] **Step 5: Announce ready to commit**

Tell the owner: "Task 1 staged. Ready for initial commit (suggested message: `chore: initial repo with spec, handoff, and CLAUDE guidance`)."

---

### Task 2: Create `hugo.toml`

**Files:**
- Create: `hugo.toml`

- [ ] **Step 1: Write `hugo.toml`**

Write to `/Users/thomasprince/dev/tomprince-dev/hugo.toml`:

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

- [ ] **Step 2: Record Hugo version**

Run: `hugo version`

Capture the output — used in Task 23 (README). Example expected form: `hugo v0.134.0-… extended linux/amd64 …`. If `extended` is missing, stop and tell the owner: the spec requires Hugo extended.

- [ ] **Step 3: Build the (empty) site to sanity-check config**

Run: `hugo --minify`

Expected: exit 0. May print `WARN` lines about missing templates — that is fine at this stage. `public/` is created.

- [ ] **Step 4: Clean the build output**

Run: `rm -rf public resources`

- [ ] **Step 5: Stage and announce**

```bash
git add hugo.toml
```

Tell the owner: "Task 2 staged. Ready to commit (suggested: `chore: add hugo.toml`)."

---

### Task 3: Create archetypes

**Files:**
- Create: `archetypes/default.md`
- Create: `archetypes/posts.md`

- [ ] **Step 1: Create `archetypes/default.md`**

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
draft = true
+++
```

- [ ] **Step 2: Create `archetypes/posts.md`**

```markdown
+++
title = "{{ replace .Name "-" " " | title }}"
date = {{ .Date }}
draft = true
tags = []
+++
```

- [ ] **Step 3: Verify archetypes work**

Run: `hugo new --kind posts posts/_archetype_check.md`

Expected: prints the path. The file should include `tags = []`.

Verify:
```bash
grep -c '^tags = \[\]$' content/posts/_archetype_check.md
```
Expected: `1`.

- [ ] **Step 4: Remove the check file**

Run: `rm content/posts/_archetype_check.md`

- [ ] **Step 5: Stage and announce**

```bash
git add archetypes/
```

Tell the owner: "Task 3 staged. Ready to commit (suggested: `chore: add archetypes`)."

---

### Task 4: Create content placeholders

**Files:**
- Create: `content/_index.md`
- Create: `content/posts/_index.md`
- Create: `content/now.md`
- Create: `content/about.md`
- Create: `content/colophon.md`

- [ ] **Step 1: Create `content/_index.md`**

```markdown
+++
title = "Tom Prince"
+++

Tom Prince. Software engineer. Writing here when I have something to say.
```

- [ ] **Step 2: Create `content/posts/_index.md`**

```markdown
+++
title = "Posts"
+++

Everything I've written here, newest first.
```

- [ ] **Step 3: Create `content/now.md`**

```markdown
+++
title = "Now"
date = 2026-04-20
+++

<!-- Inspired by https://nownownow.com/ -->

Placeholder for a /now page.
```

- [ ] **Step 4: Create `content/about.md`**

```markdown
+++
title = "About"
date = 2026-04-20
+++

Placeholder. Opinions here are my own and do not represent any employer.
```

- [ ] **Step 5: Create `content/colophon.md`**

```markdown
+++
title = "Colophon"
date = 2026-04-20
+++

This site is built with [Hugo](https://gohugo.io/), no theme — layouts live in `/layouts/`.
It's hosted on a VPS behind [Caddy](https://caddyserver.com/), deployed via `rsync`.
Posts and list pages carry [microformats2](https://microformats.org/wiki/microformats2) markup (`h-entry`, `h-feed`, `h-card`).
```

- [ ] **Step 6: Stage and announce**

```bash
git add content/
```

Tell the owner: "Task 4 staged. Ready to commit (suggested: `chore: seed content placeholders`)."

---

### Task 5: `head.html` partial

**Files:**
- Create: `layouts/partials/head.html`

- [ ] **Step 1: Write `layouts/partials/head.html`**

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>{{ if .IsHome }}{{ .Site.Title }}{{ else }}{{ .Title }} — {{ .Site.Title }}{{ end }}</title>
<meta name="description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">

<link rel="canonical" href="{{ .Permalink }}">
<link rel="alternate" type="application/rss+xml" title="{{ .Site.Title }}" href="{{ "/index.xml" | absURL }}">

{{ $css := resources.Get "css/main.css" | resources.Minify | resources.Fingerprint }}
<link rel="stylesheet" href="{{ $css.RelPermalink }}">

<meta property="og:title" content="{{ if .IsHome }}{{ .Site.Title }}{{ else }}{{ .Title }}{{ end }}">
<meta property="og:description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">
<meta property="og:type" content="{{ if .IsPage }}article{{ else }}website{{ end }}">
<meta property="og:url" content="{{ .Permalink }}">

<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="{{ if .IsHome }}{{ .Site.Title }}{{ else }}{{ .Title }}{{ end }}">
<meta name="twitter:description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">
```

Note: this partial references `assets/css/main.css` (created in Task 18). Hugo builds in this task will fail if the CSS is missing. That is expected; the full build test lives in Task 9 / Task 18.

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/partials/head.html
```

Tell the owner: "Task 5 staged. Ready to commit (suggested: `feat(layouts): add head partial`)."

---

### Task 6: `header.html` partial

**Files:**
- Create: `layouts/partials/header.html`

- [ ] **Step 1: Write `layouts/partials/header.html`**

```html
<header>
  <nav>
    <a href="/"><strong>{{ .Site.Title }}</strong></a>
    <ul>
      <li><a href="/posts/">Posts</a></li>
      <li><a href="/now/">Now</a></li>
      <li><a href="/about/">About</a></li>
    </ul>
  </nav>
</header>
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/partials/header.html
```

Tell the owner: "Task 6 staged. Ready to commit (suggested: `feat(layouts): add header partial`)."

---

### Task 7: `hcard.html` partial

**Files:**
- Create: `layouts/partials/hcard.html`

- [ ] **Step 1: Write `layouts/partials/hcard.html`**

```html
<p class="h-card">
  <a class="p-name u-url" href="{{ .Site.BaseURL }}">{{ .Site.Params.author }}</a>
</p>
```

Note: `u-email` is intentionally omitted per the spec. Add later if the owner decides to expose email.

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/partials/hcard.html
```

Tell the owner: "Task 7 staged. Ready to commit (suggested: `feat(layouts): add hcard partial`)."

---

### Task 8: `footer.html` partial

**Files:**
- Create: `layouts/partials/footer.html`

- [ ] **Step 1: Write `layouts/partials/footer.html`**

```html
<footer>
  <p>© {{ now.Year }} Tom Prince</p>
  <p>
    <a href="/colophon/">Colophon</a> ·
    <a href="/index.xml">RSS</a>
  </p>
  {{ partial "hcard.html" . }}
</footer>
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/partials/footer.html
```

Tell the owner: "Task 8 staged. Ready to commit (suggested: `feat(layouts): add footer partial`)."

---

### Task 9: `baseof.html`

**Files:**
- Create: `layouts/_default/baseof.html`

- [ ] **Step 1: Write `layouts/_default/baseof.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  {{ partial "head.html" . }}
</head>
<body>
  {{ partial "header.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
  {{ partial "footer.html" . }}
</body>
</html>
```

- [ ] **Step 2: Stage (build verification deferred)**

Full-build verification requires the CSS (Task 18) and at least one page template. We'll run the first full build at Task 18.

```bash
git add layouts/_default/baseof.html
```

Tell the owner: "Task 9 staged. Ready to commit (suggested: `feat(layouts): add baseof shell`)."

---

### Task 10: Homepage — `layouts/index.html`

**Files:**
- Create: `layouts/index.html`

- [ ] **Step 1: Write `layouts/index.html`**

```html
{{ define "main" }}
<section>
  {{ .Content }}
</section>
<section class="h-feed">
  <h2>Recent posts</h2>
  {{ $n := .Site.Params.homepageRecentPosts }}
  {{ range first $n (where .Site.RegularPages "Section" "posts") }}
  <article class="h-entry">
    <h3><a class="u-url p-name" href="{{ .Permalink }}">{{ .Title }}</a></h3>
    <time class="dt-published" datetime="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">{{ .Date.Format "Jan 2, 2006" }}</time>
  </article>
  {{ end }}
  <p><a href="/posts/">Full archive →</a></p>
</section>
{{ end }}
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/index.html
```

Tell the owner: "Task 10 staged. Ready to commit (suggested: `feat(layouts): add homepage with h-feed`)."

---

### Task 11: Section archive — `layouts/_default/list.html`

**Files:**
- Create: `layouts/_default/list.html`

- [ ] **Step 1: Write `layouts/_default/list.html`**

```html
{{ define "main" }}
<h1>{{ .Title }}</h1>
{{ with .Content }}{{ . }}{{ end }}
<div class="h-feed">
  {{ range .Pages }}
  <article class="h-entry">
    <h2><a class="u-url p-name" href="{{ .Permalink }}">{{ .Title }}</a></h2>
    <time class="dt-published" datetime="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">{{ .Date.Format "Jan 2, 2006" }}</time>
    {{ with .Summary }}<p>{{ . | plainify | truncate 200 }}</p>{{ end }}
  </article>
  {{ end }}
</div>
{{ end }}
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/_default/list.html
```

Tell the owner: "Task 11 staged. Ready to commit (suggested: `feat(layouts): add list template with h-feed`)."

---

### Task 12: Post page — `layouts/_default/single.html`

**Files:**
- Create: `layouts/_default/single.html`

- [ ] **Step 1: Write `layouts/_default/single.html`**

```html
{{ define "main" }}
<article class="h-entry">
  <header>
    <h1 class="p-name">{{ .Title }}</h1>
    <p>
      <time class="dt-published" datetime="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">{{ .Date.Format "January 2, 2006" }}</time>
      {{ if and (not .Lastmod.IsZero) (ne (.Lastmod.Format "2006-01-02") (.Date.Format "2006-01-02")) }}
      — updated <time class="dt-updated" datetime="{{ .Lastmod.Format "2006-01-02T15:04:05Z07:00" }}">{{ .Lastmod.Format "January 2, 2006" }}</time>
      {{ end }}
    </p>
  </header>
  <div class="e-content">
    {{ .Content }}
  </div>
  {{ with .Params.tags }}
  <p class="tags">
    {{ range . }}
    <a class="p-category" href="/tags/{{ . | urlize }}/">{{ . }}</a>
    {{ end }}
  </p>
  {{ end }}
</article>
{{ end }}
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/_default/single.html
```

Tell the owner: "Task 12 staged. Ready to commit (suggested: `feat(layouts): add single post template with h-entry`)."

---

### Task 13: Taxonomy index — `layouts/_default/terms.html`

**Files:**
- Create: `layouts/_default/terms.html`

- [ ] **Step 1: Write `layouts/_default/terms.html`**

```html
{{ define "main" }}
<h1>Tags</h1>
<ul>
  {{ range .Data.Terms.Alphabetical }}
  <li>
    <a href="{{ .Page.Permalink }}">{{ .Page.Title }}</a> ({{ .Count }})
  </li>
  {{ end }}
</ul>
{{ end }}
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/_default/terms.html
```

Tell the owner: "Task 13 staged. Ready to commit (suggested: `feat(layouts): add terms template for /tags/`)."

---

### Task 14: Per-tag archive — `layouts/taxonomy/tag.html`

**Files:**
- Create: `layouts/taxonomy/tag.html`

- [ ] **Step 1: Write `layouts/taxonomy/tag.html`**

```html
{{ define "main" }}
<h1>Tag: {{ .Title }}</h1>
<div class="h-feed">
  {{ range .Pages }}
  <article class="h-entry">
    <h2><a class="u-url p-name" href="{{ .Permalink }}">{{ .Title }}</a></h2>
    <time class="dt-published" datetime="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">{{ .Date.Format "Jan 2, 2006" }}</time>
  </article>
  {{ end }}
</div>
{{ end }}
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/taxonomy/tag.html
```

Tell the owner: "Task 14 staged. Ready to commit (suggested: `feat(layouts): add per-tag archive template`)."

---

### Task 15: 404 page — `layouts/404.html`

**Files:**
- Create: `layouts/404.html`

- [ ] **Step 1: Write `layouts/404.html`**

```html
{{ define "main" }}
<h1>Not found</h1>
<p>That page isn't here. Try the <a href="/">homepage</a>.</p>
{{ end }}
```

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/404.html
```

Tell the owner: "Task 15 staged. Ready to commit (suggested: `feat(layouts): add 404 page`)."

---

### Task 16: RSS — `layouts/_default/rss.xml`

**Files:**
- Create: `layouts/_default/rss.xml`

- [ ] **Step 1: Write `layouts/_default/rss.xml`**

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<rss version="2.0"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>{{ .Site.Title }}</title>
    <link>{{ .Site.BaseURL }}</link>
    <description>{{ .Site.Params.description }}</description>
    <language>{{ .Site.LanguageCode }}</language>
    <atom:link href="{{ .Permalink }}index.xml" rel="self" type="application/rss+xml" />
    {{ $pages := .Pages }}
    {{ if .IsHome }}{{ $pages = where .Site.RegularPages "Section" "posts" }}{{ end }}
    {{ range first 20 $pages }}
    <item>
      <title>{{ .Title }}</title>
      <link>{{ .Permalink }}</link>
      <guid isPermaLink="true">{{ .Permalink }}</guid>
      <pubDate>{{ .Date.Format "Mon, 02 Jan 2006 15:04:05 -0700" }}</pubDate>
      <dc:creator>{{ .Site.Params.author }}</dc:creator>
      {{ with .Params.tags }}{{ range . }}
      <category>{{ . }}</category>
      {{ end }}{{ end }}
      <description><![CDATA[{{ .Content | safeHTML }}]]></description>
    </item>
    {{ end }}
  </channel>
</rss>
```

Notes:
- `dc:creator` replaces `<author>` so no email is exposed.
- Content goes inside `CDATA` via `| safeHTML` — **not** `| html`, which would double-escape.
- Home feed intentionally pulls from `posts` section only (ignores standalone pages like `/now/`, `/about/`).

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/_default/rss.xml
```

Tell the owner: "Task 16 staged. Ready to commit (suggested: `feat(layouts): add RSS template with dc:creator and full-content CDATA`)."

---

### Task 17: `robots.txt` — `layouts/robots.txt`

**Files:**
- Create: `layouts/robots.txt`

- [ ] **Step 1: Write `layouts/robots.txt`**

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

- [ ] **Step 2: Stage and announce**

```bash
git add layouts/robots.txt
```

Tell the owner: "Task 17 staged. Ready to commit (suggested: `feat(layouts): add robots.txt template with AI-bot blocklist`)."

---

### Task 18: CSS — `assets/css/main.css`

**Files:**
- Create: `assets/css/main.css`

- [ ] **Step 1: Write `assets/css/main.css`**

```css
:root {
  --text: #222;
  --bg: #fdfdfc;
  --accent: #3355aa;
  --muted: #666;
  --border: #e5e5e3;
  --code-bg: #f5f5f4;
}

@media (prefers-color-scheme: dark) {
  :root {
    --text: #e8e8e6;
    --bg: #1a1a1a;
    --accent: #8aabff;
    --muted: #999;
    --border: #333;
    --code-bg: #252525;
  }
}

* { box-sizing: border-box; }

html {
  color: var(--text);
  background: var(--bg);
  font-family: ui-serif, Georgia, Cambria, "Times New Roman", serif;
  font-size: 18px;
  line-height: 1.7;
}

body {
  margin: 0 auto;
  padding: 2rem 1.5rem 4rem;
  max-width: 68ch;
}

header, main, footer { display: block; }

header {
  margin-bottom: 3rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
}

header nav {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
}

header nav ul {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  gap: 1.25rem;
}

header a strong { font-size: 1.1rem; }

a {
  color: var(--accent);
  text-decoration: underline;
  text-underline-offset: 2px;
}

a:hover { text-decoration: none; }

h1, h2, h3 {
  line-height: 1.3;
  margin-top: 2rem;
  margin-bottom: 0.75rem;
}

h1 { font-size: 1.75rem; }
h2 { font-size: 1.4rem; }
h3 { font-size: 1.2rem; }

p, ul, ol, blockquote { margin: 0 0 1.25rem; }

blockquote {
  border-left: 3px solid var(--border);
  padding-left: 1rem;
  color: var(--muted);
}

pre, code {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  font-size: 0.9em;
}

code {
  background: var(--code-bg);
  padding: 0.1em 0.3em;
  border-radius: 3px;
}

pre {
  background: var(--code-bg);
  padding: 1rem;
  overflow-x: auto;
  border-radius: 4px;
}

pre code { background: none; padding: 0; }

article.h-entry > header {
  border: none;
  margin-bottom: 1rem;
  padding-bottom: 0;
}

article time {
  color: var(--muted);
  font-size: 0.9em;
}

.h-feed article {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
}

.h-feed article:last-child { border-bottom: none; }

.h-feed h2, .h-feed h3 { margin: 0 0 0.25rem; }

.tags {
  margin-top: 2rem;
  font-size: 0.9em;
  color: var(--muted);
}

.tags a { margin-right: 0.5rem; }

footer {
  margin-top: 4rem;
  padding-top: 1rem;
  border-top: 1px solid var(--border);
  font-size: 0.9em;
  color: var(--muted);
}

footer p { margin: 0.25rem 0; }

footer .h-card { display: none; }

@media (max-width: 600px) {
  body { padding: 1.5rem 1rem 3rem; }
  html { font-size: 16px; }
}
```

- [ ] **Step 2: Verify CSS under 200 lines (AC#11)**

Run:
```bash
wc -l assets/css/main.css
```
Expected: less than 200.

- [ ] **Step 3: Run the first full build (all templates present now)**

Run:
```bash
hugo --minify
```
Expected: exit 0. Output under `public/` now exists. Warnings about missing data files / templates are acceptable; errors are not.

- [ ] **Step 4: Spot-check homepage output**

Run:
```bash
grep -c 'class="h-feed"' public/index.html
grep -c 'class="h-card"' public/index.html
grep -c 'rel="canonical"' public/index.html
grep -c 'application/rss+xml' public/index.html
```
Each should print `1` (or more for `h-entry` if recent posts exist).

- [ ] **Step 5: Spot-check RSS output**

Run:
```bash
grep -c '<dc:creator>' public/index.xml
grep -c '<!\[CDATA\[' public/index.xml
```
Each should print a number (0 is acceptable if there are no posts yet; 1+ once a post exists). The namespace declaration must be present:
```bash
grep -c 'xmlns:dc="http://purl.org/dc/elements/1.1/"' public/index.xml
```
Expected: `1`.

- [ ] **Step 6: Clean the build output**

Run: `rm -rf public resources`

- [ ] **Step 7: Stage and announce**

```bash
git add assets/
```
Tell the owner: "Task 18 staged. Ready to commit (suggested: `feat(assets): add main.css under 200 lines with dark mode`)."

---

### Task 19: Favicon placeholder

**Files:**
- Create: `static/favicon.ico`

- [ ] **Step 1: Create a 1×1 transparent PNG renamed as `.ico`**

macOS `sips` / bundled tools produce valid ICOs awkwardly. Simplest: create an empty-but-valid placeholder so the route exists. A truly empty file will 200 but be useless; use a minimal valid 1×1 PNG byte-stream saved under the `.ico` name (browsers fall back gracefully).

Run:
```bash
mkdir -p static
python3 -c 'import base64, sys; sys.stdout.buffer.write(base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="))' > static/favicon.ico
```

Verify the file is non-empty:
```bash
test -s static/favicon.ico && echo OK
```
Expected: `OK`. (Owner will replace with a real favicon later.)

- [ ] **Step 2: Stage and announce**

```bash
git add static/
```
Tell the owner: "Task 19 staged. Ready to commit (suggested: `chore: add placeholder favicon`). Owner should replace with a real favicon when ready."

---

### Task 20: `scripts/newpost`

**Files:**
- Create: `scripts/newpost`

- [ ] **Step 1: Write `scripts/newpost`**

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

- [ ] **Step 2: Make executable**

Run:
```bash
chmod +x scripts/newpost
```

- [ ] **Step 3: Test empty-slug guard (AC#17)**

Run:
```bash
EDITOR=true scripts/newpost '!!!' ; echo "exit=$?"
```
Expected: the script prints `error: slug is empty after normalization` and `exit=1`.

- [ ] **Step 4: Test happy path**

Run:
```bash
EDITOR=true scripts/newpost 'Hello World Test'
ls content/posts/hello-world-test.md
```
Expected: the file exists. Now remove it:
```bash
rm content/posts/hello-world-test.md
```

- [ ] **Step 5: Stage and announce**

```bash
git add scripts/newpost
```
Tell the owner: "Task 20 staged. Ready to commit (suggested: `feat(scripts): add newpost script with slug guard`)."

---

### Task 21: `scripts/deploy`

**Files:**
- Create: `scripts/deploy`

- [ ] **Step 1: Write `scripts/deploy`**

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

- [ ] **Step 2: Make executable**

Run:
```bash
chmod +x scripts/deploy
```

- [ ] **Step 3: Test `DRY_RUN=1` mode without touching the VPS (AC#16)**

The VPS does not yet exist. The `rsync` line will fail DNS resolution regardless of `DRY_RUN`. Verify behavior by overriding the target to a local directory for this check:

Run:
```bash
mkdir -p /tmp/tomprince-dev-dry
DRY_RUN=1 \
  rsync -avz --delete --dry-run \
    --exclude='.well-known' \
    public/ \
    /tmp/tomprince-dev-dry/ \
  && echo "dry-run OK"
```
Expected: `dry-run OK` printed; `/tmp/tomprince-dev-dry/` remains empty (dry-run did not copy). If `public/` is missing, first run `hugo --minify --gc`.

Then clean:
```bash
rm -rf /tmp/tomprince-dev-dry public resources
```

(The full end-to-end deploy test happens only after the VPS is provisioned — that's an owner TODO.)

- [ ] **Step 4: Stage and announce**

```bash
git add scripts/deploy
```
Tell the owner: "Task 21 staged. Ready to commit (suggested: `feat(scripts): add deploy script with DRY_RUN and sanity check`)."

---

### Task 22: `Caddyfile`

**Files:**
- Create: `Caddyfile`

- [ ] **Step 1: Write `Caddyfile`**

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

Note: this Caddyfile is a **reference copy** that lives in the repo for documentation. The live copy goes to `/etc/caddy/Caddyfile` on the VPS at provisioning time. HSTS deliberately omits `preload`.

- [ ] **Step 2: Validate Caddyfile syntax (if `caddy` is installed locally)**

Run:
```bash
if command -v caddy >/dev/null 2>&1; then
  caddy validate --config Caddyfile --adapter caddyfile
else
  echo "caddy not installed locally — skipping validation; syntax will be validated on the VPS"
fi
```
Expected: either a successful validation message or the skip message.

- [ ] **Step 3: Stage and announce**

```bash
git add Caddyfile
```
Tell the owner: "Task 22 staged. Ready to commit (suggested: `docs: add reference Caddyfile`)."

---

### Task 23: `README.md`

**Files:**
- Create: `README.md`

- [ ] **Step 1: Re-record the Hugo version (captured in Task 2)**

Run: `hugo version`

Capture the printed line; paste it verbatim into the README "Tested with" block below.

- [ ] **Step 2: Write `README.md`**

Replace `{HUGO_VERSION_LINE}` below with the line captured in Step 1.

```markdown
# tomprince.dev

Personal site of Tom Prince. Built with Hugo (extended), no theme, layouts in `/layouts/`. Deployed via `rsync` to a VPS running Caddy.

## Tested with

```
{HUGO_VERSION_LINE}
```

## Run locally

```sh
hugo server -D
```

Serves the site at `http://localhost:1313` including drafts.

## Create a post

```sh
scripts/newpost "hello world"
```

Opens the new draft in `$EDITOR` (defaults to `nvim`). Remove `draft = true` in the front matter when ready to publish.

## Deploy

```sh
scripts/deploy
```

Builds with `hugo --minify --gc` and `rsync`s `public/` to the VPS. To preview without writing:

```sh
DRY_RUN=1 scripts/deploy
```

## Server config

The live Caddyfile lives on the VPS at `/etc/caddy/Caddyfile`. A reference copy is at `Caddyfile` in this repo; changes there do not apply until the VPS copy is updated.

## Licenses

- Code: TODO (owner to decide — MIT suggested)
- Content: TODO (owner to decide — CC BY 4.0 suggested)
```

- [ ] **Step 3: Stage and announce**

```bash
git add README.md
```
Tell the owner: "Task 23 staged. Ready to commit (suggested: `docs: add README`). Note: content/code licenses still TODO per owner."

---

### Task 24: Final acceptance run

This task rebuilds the site end-to-end and walks through every acceptance criterion from spec §14 that can be tested locally. VPS-dependent ACs (11 items marked "once deployed" / "once VPS is live") are deferred to post-provisioning.

**Files:** No file changes; verification only.

- [ ] **Step 1: Create a throwaway sample post**

Run:
```bash
EDITOR=true scripts/newpost "Hello World"
```
Then publish it by stripping the draft flag:
```bash
sed -i.bak 's/^draft = true$/draft = false/' content/posts/hello-world.md
rm content/posts/hello-world.md.bak
```
Add some body content:
```bash
cat >> content/posts/hello-world.md <<'EOF'

This is a sample post used only for acceptance validation. It will be removed at the end of this task.

Lorem ipsum with some **bold** and a [link](https://tomprince.dev/).
EOF
```

- [ ] **Step 2: Build**

Run:
```bash
hugo --minify --gc
```
Expected: exit 0 with no `ERROR` lines. Warnings are acceptable.

- [ ] **Step 3: AC#1 — `hugo server -D` smoke test**

Run:
```bash
hugo server -D --port 1313 &
SERVER_PID=$!
sleep 2
curl -sf http://localhost:1313/ >/dev/null && echo "AC#1 OK"
kill $SERVER_PID
```
Expected: `AC#1 OK`.

- [ ] **Step 4: AC#2 — sample post renders at `/2026/hello-world/`**

Run:
```bash
test -f public/2026/hello-world/index.html && echo "AC#2 OK"
```
Expected: `AC#2 OK`.

- [ ] **Step 5: AC#3 & AC#4 — homepage and posts archive carry `h-feed`**

Run:
```bash
grep -c 'class="h-feed"' public/index.html
grep -c 'class="h-feed"' public/posts/index.html
```
Both: at least `1`. Also verify the homepage has the intro:
```bash
grep -q 'Tom Prince\. Software engineer\.' public/index.html && echo "AC#3 intro OK"
```
Expected: `AC#3 intro OK`.

- [ ] **Step 6: AC#5 & AC#6 — RSS has full content in CDATA, dc:creator, DC namespace**

Run:
```bash
grep -c 'xmlns:dc="http://purl.org/dc/elements/1.1/"' public/index.xml
grep -c '<dc:creator>Tom Prince</dc:creator>' public/index.xml
grep -c '<!\[CDATA\[' public/index.xml
```
All three: at least `1`. Then verify the CDATA content is not HTML-entity-escaped (no `&lt;` inside CDATA):
```bash
awk '/<!\[CDATA\[/,/\]\]>/' public/index.xml | grep -c '&lt;'
```
Expected: `0`.

- [ ] **Step 7: AC#7 — post page has h-entry with required children**

Run:
```bash
POST=public/2026/hello-world/index.html
for cls in 'h-entry' 'p-name' 'dt-published' 'e-content'; do
  grep -q "class=\"$cls" "$POST" || grep -q "class=\"[^\"]* $cls" "$POST" \
    || { echo "AC#7 FAIL: $cls missing"; exit 1; }
done
echo "AC#7 OK"
```
Expected: `AC#7 OK`.

- [ ] **Step 8: AC#8 — site-wide h-card in footer**

Run:
```bash
grep -q 'class="h-card"' public/index.html && echo "AC#8 OK"
```
Expected: `AC#8 OK`.

- [ ] **Step 9: AC#9 — no external resources loaded**

Run:
```bash
grep -Eh 'https?://(?!tomprince\.dev|localhost)' public/index.html public/2026/hello-world/index.html || echo "AC#9 OK (no external URLs in rendered HTML)"
```
Expected: `AC#9 OK ...`. If any external URLs appear, inspect: template references in OG tags use `.Permalink` which resolves to the `baseURL` — acceptable. External links inside post bodies are user content, not scaffold leakage; spot-check that nothing in the scaffold added them.

- [ ] **Step 10: AC#10 — dark mode via `prefers-color-scheme`**

Run:
```bash
CSS=$(ls public/css/*.css | head -1)
grep -q 'prefers-color-scheme: dark' "$CSS" && echo "AC#10 OK"
```
Expected: `AC#10 OK`.

- [ ] **Step 11: AC#11 — CSS under 200 lines (source, not fingerprinted output)**

Run:
```bash
wc -l assets/css/main.css
```
Expected: a number under 200.

- [ ] **Step 12: AC#12 — 404 page built (Caddy routing verified post-deploy only)**

Run:
```bash
test -f public/404.html && grep -q 'Not found' public/404.html && echo "AC#12 OK (build side; Caddy routing verified post-deploy)"
```
Expected: `AC#12 OK ...`.

- [ ] **Step 13: AC#13 — `/tags/` lists the single tag from the sample post (empty is fine)**

The sample post has no `tags = [...]` populated, so `/tags/` will render an empty list. Verify the page itself exists:
```bash
test -f public/tags/index.html && echo "AC#13 OK"
```
Expected: `AC#13 OK`.

- [ ] **Step 14: AC#14 — `robots.txt` served with AI-bot blocklist**

Run:
```bash
grep -c '^User-agent: GPTBot' public/robots.txt
grep -c '^User-agent: ClaudeBot' public/robots.txt
grep -q '^Sitemap: ' public/robots.txt && echo "AC#14 OK"
```
Each bot check: `1`. `AC#14 OK` printed.

- [ ] **Step 15: AC#15 — CSP/HSTS/X-Robots-Tag (verified post-deploy)**

These headers are set in `Caddyfile` and are only testable once the VPS is live. Confirm the header block exists in the repo copy:
```bash
grep -c 'Strict-Transport-Security' Caddyfile
grep -c 'Content-Security-Policy' Caddyfile
grep -c 'X-Robots-Tag "noai, noimageai"' Caddyfile
```
All: `1`. Note "AC#15 verified at config level; runtime verification pending VPS deploy" in the wrap-up message.

- [ ] **Step 16: AC#16 — `DRY_RUN=1 scripts/deploy` preview**

End-to-end against the real VPS host would require DNS; for now just verify the script contains the DRY_RUN branch:
```bash
grep -c 'DRY_RUN' scripts/deploy
```
Expected: at least `2` (both the env var read and the flag comparison).

- [ ] **Step 17: AC#17 — `newpost` with all-punctuation title exits non-zero**

Already covered in Task 20. Re-verify:
```bash
EDITOR=true scripts/newpost '!!!' ; test $? -ne 0 && echo "AC#17 OK"
```
Expected: `AC#17 OK`.

- [ ] **Step 18: AC#18 — repo is a git repo with ≥1 commit**

Run:
```bash
git rev-parse --is-inside-work-tree
git log --oneline | head -1
```
Expected: `true` and at least one commit line. If no commits yet, remind the owner: "The owner owns commits; please run `git commit` at least once so `enableGitInfo` stops warning."

- [ ] **Step 19: Remove the throwaway sample post**

Run:
```bash
rm content/posts/hello-world.md
rm -rf public resources
```

- [ ] **Step 20: Stage any final files and announce completion**

```bash
git status
```

Tell the owner: "All local acceptance criteria pass. Items requiring the live VPS (Caddy 404 routing, runtime response headers, indiewebify.me validation of a reachable post URL) are deferred until provisioning. Scaffold complete; ready for final owner review and commits across all 23 task batches above."

---

## Self-Review

**Spec coverage:**

| Spec section | Covered by |
|---|---|
| §4 Repository layout | Tasks 1–23 collectively build the tree |
| §5 `hugo.toml` | Task 2 |
| §6 Archetypes | Task 3 |
| §7.1 baseof | Task 9 |
| §7.2 head | Task 5 |
| §7.3 header | Task 6 |
| §7.4 footer | Task 8 |
| §7.5 hcard | Task 7 |
| §7.6 index (homepage h-feed) | Task 10 |
| §7.7 single (h-entry) | Task 12 |
| §7.8 list (h-feed) | Task 11 |
| §7.9 terms | Task 13 |
| §7.10 tag | Task 14 |
| §7.11 rss (dc:creator, CDATA, namespaces) | Task 16 |
| §7.12 404 | Task 15 |
| §7.13 robots.txt (Stance B) | Task 17 |
| §8 CSS | Task 18 |
| §9 Content placeholders | Task 4 |
| §10.1 newpost | Task 20 |
| §10.2 deploy | Task 21 |
| §11 Caddyfile | Task 22 |
| §12 .gitignore | Task 1 |
| §13 README | Task 23 |
| §14 Acceptance criteria | Task 24 |

All spec sections are covered.

**Placeholder scan:** None — all code is inline and complete. Only owner-decision TODOs remain (license picks in README §Licenses, favicon replacement), both explicitly noted as owner TODOs in the spec.

**Type/naming consistency:** `content/posts/hello-world-test.md` in Task 3's archetype check is removed in the same task. The sample post `hello-world.md` in Task 24 is removed at Task 24's end. No cross-task dangling artifacts. Template field names (`Site.Params.author`, `Site.Params.description`, `Site.Params.homepageRecentPosts`, `Params.tags`, `Date`, `Lastmod`) used consistently across Tasks 5, 8, 10, 11, 12, 14, 16.

**Commit discipline:** Every task ends with `git add` and a "ready to commit" announcement; no task runs `git commit` — matches the feedback memory.
