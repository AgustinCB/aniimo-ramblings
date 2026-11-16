#!/usr/bin/env bash
# Run Hugo inside a container.
#
# This project targets immutable/atomic hosts (e.g. Bazzite) where Hugo is not
# installed system-wide, so every Hugo invocation goes through podman (or
# docker, if that is what is available).
#
# Usage:
#   ./hugo.sh                       # same as `hugo` (build into ./public)
#   ./hugo.sh version
#   ./hugo.sh new content guides/my-guide.md
#   ./hugo.sh server                # dev server on http://localhost:1313/
#
# Override the image or version with HUGO_IMAGE / HUGO_VERSION.
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.152.2}"
HUGO_IMAGE="${HUGO_IMAGE:-docker.io/hugomods/hugo:exts-${HUGO_VERSION}}"
HUGO_PORT="${HUGO_PORT:-1313}"

if command -v podman >/dev/null 2>&1; then
  ENGINE=podman
elif command -v docker >/dev/null 2>&1; then
  ENGINE=docker
else
  echo "error: neither podman nor docker is available" >&2
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

engine_args=(
  run --rm
  --volume "${PROJECT_DIR}:/src:z"
  --workdir /src
)

# Only allocate a TTY when running interactively (keeps CI/scripts happy).
if [ -t 0 ] && [ -t 1 ]; then
  engine_args+=(--interactive --tty)
fi

# Keep generated files (./public, ./resources) owned by the current user
# instead of a subuid, which matters on rootless podman.
engine_args+=(--user "$(id -u):$(id -g)" --env HOME=/tmp)
if [ "${ENGINE}" = "podman" ]; then
  engine_args+=(--userns=keep-id)
fi

cmd=("$@")

# The dev server needs a published port and must listen on all interfaces.
if [ "${1:-}" = "server" ] || [ "${1:-}" = "serve" ]; then
  engine_args+=(--publish "${HUGO_PORT}:${HUGO_PORT}")
  HUGO_BASEURL="${HUGO_BASEURL:-http://localhost:${HUGO_PORT}/}"
  cmd=("$@" --bind 0.0.0.0 --port "${HUGO_PORT}" --baseURL "${HUGO_BASEURL}" --appendPort=false)
fi

exec "${ENGINE}" "${engine_args[@]}" "${HUGO_IMAGE}" hugo "${cmd[@]}"
