# tomprince.dev

Personal site of Tom Prince. Built with Hugo (extended), no theme, layouts in `/layouts/`. Deployed via `rsync` to a VPS running Caddy.

## Tested with

```
hugo v0.160.1+extended+withdeploy darwin/arm64 BuildDate=2026-04-08T14:02:42Z VendorInfo=Homebrew
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

- Code: [MIT](LICENSE)
- Content: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
