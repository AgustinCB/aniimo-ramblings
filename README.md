# Aniimo Ramblings

A static site built with [Hugo](https://gohugo.io/) and deployed to GitHub Pages.

The host this repo is developed on is an immutable/atomic system (Bazzite), so
Hugo is **not** installed locally — every Hugo command runs inside a container
via the `./hugo.sh` wrapper (podman, with a docker fallback).

## Requirements

- `podman` (preinstalled on Bazzite) or `docker`
- nothing else; the Hugo extended binary comes from the
  `docker.io/hugomods/hugo:exts-<version>` image

## Local development

```bash
./hugo.sh server            # live preview on http://localhost:1313/
./hugo.sh                   # one-off build into ./public
./hugo.sh --gc --minify     # production-like build
./hugo.sh version
```

Override the Hugo version or image if needed:

```bash
HUGO_VERSION=0.152.2 ./hugo.sh version
HUGO_IMAGE=docker.io/hugomods/hugo:exts ./hugo.sh version
HUGO_PORT=8080 ./hugo.sh server
```

Notes on the container setup:

- the project is bind-mounted at `/src` with the `:z` SELinux label, which is
  required on Fedora-based immutable hosts
- the container runs as your UID/GID (`--userns=keep-id`) so `public/` and
  `resources/` stay owned by you and remain editable/removable
- `./hugo.sh server` publishes the port and binds to `0.0.0.0` inside the
  container so the preview is reachable from the host

## Adding a guide

```bash
./hugo.sh new content guides/my-new-guide.md
```

The new file starts as `draft: true`; set it to `false` (or delete the line)
to publish. Preview drafts with `./hugo.sh server -D`.

## Project layout

```
archetypes/         front matter template for new content
assets/css/         stylesheet (processed by Hugo Pipes)
content/            Markdown content (`content/guides/` holds the guides)
layouts/            templates (baseof, home, list, single, partials)
static/             files copied verbatim to the site root
hugo.toml           site configuration
hugo.sh             containerised Hugo wrapper
.github/workflows/  GitHub Pages build & deploy
```

## Deployment

`.github/workflows/hugo.yml` builds the site and publishes it with the official
GitHub Pages actions on every push to `main` (and on manual dispatch).

One-time setup in the repository:

1. **Settings → Pages → Build and deployment → Source: GitHub Actions**.
2. `hugo.toml`'s `baseURL` is set to
   `https://agustincb.github.io/aniimo-ramblings/`. The workflow passes the
   correct `--baseURL` from the Pages configuration anyway, so this value
   only matters for local builds.

Using a custom domain? Add the domain in Settings → Pages and put the same
value in `static/CNAME`, then update `baseURL` accordingly.
