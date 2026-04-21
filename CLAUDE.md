# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository state

Pre-scaffold. The only file is `handoff.md` — a complete design spec for `tomprince.dev`, a personal Hugo site. Read it before doing any work here; every structural, stylistic, and tooling decision is already made.

## What this site is

- Hugo (extended), TOML config, **no theme** — layouts written directly in `/layouts/`.
- Static output deployed via `hugo --minify` + `rsync` to a VPS running Caddy.
- Microformats2 (`h-entry`, `h-card`) in templates is required; no other IndieWeb features on day one.
- No JS, no npm, no analytics, no comments, no search, no pagination. See `handoff.md` "Explicit non-goals" — treat that list as load-bearing.

## Commands (once scaffolded)

- `hugo server -D` — local dev at `localhost:1313`, drafts included.
- `scripts/newpost "title words"` — creates a draft post and opens it in `$EDITOR` (defaults to nvim).
- `scripts/deploy` — builds and rsyncs `public/` to the VPS.

## Working style

- Owner is nvim-first, plain-text, markdown. Pipeline should match.
- Don't add fields, partials, or config speculatively — handoff.md says keep archetypes and templates minimal.
- "Open decisions" in handoff.md are defaulted; don't re-litigate them unless the owner asks.
- No sycophancy, no emotional language, no anthropomorphizing (no "I think", "I feel", "happy to", "great question"). State facts and actions directly.
