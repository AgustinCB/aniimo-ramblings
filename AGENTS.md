# AGENTS.md — Aniimo Ramblings

Operating manual for an AI agent working on this repository. It covers three
jobs: running the local preview server, reviewing articles I write, and
producing/managing images and other assets.

## Golden rule

**Do not rewrite my prose.** The voice of the articles is mine. You may fix
typos, grammar, spelling, punctuation, capitalisation, heading levels, list
numbering, line wrapping and factual errors in names/numbers. Everything else
— phrasing, tone, structure, opinions, additions, deletions — is a
*suggestion* you report back, never an edit you apply.

## The project

- Hugo static site, deployed to GitHub Pages via `.github/workflows/hugo.yml`
  on every push to `main`. Live at
  <https://agustincb.github.io/aniimo-ramblings/>.
- Host is **Bazzite**: immutable, no system packages. Hugo is never installed;
  it runs in a container through `./hugo.sh` (podman first, docker fallback).
- Articles live in `content/guides/`. A mirror copy exists in
  `Writerside/topics/guides/`. **Both must be kept in sync** — I sometimes
  write in the Writerside copy, so check which one is newer before editing,
  and copy the final version over the other.
- Images: `static/images/` (summary graphics) and `static/images/aniimo/`
  (official portraits, 240px max).
- Image generation scripts: `scripts/`.

## 1. Local server (over SSH)

Sessions happen over SSH, so the server must bind `0.0.0.0` *and* be served
with the LAN base URL — otherwise the configured GitHub Pages sub-path breaks
every CSS/image link and the site renders unstyled.

```bash
HUGO_BASEURL=http://192.168.4.25:1313/ ./hugo.sh server
```

Then give me the LAN URL, never `localhost`:

- http://192.168.4.25:1313/
- http://192.168.4.25:1313/guides/what-to-build/

Rules:

- Always pass `HUGO_BASEURL`. Without it `hugo.sh` defaults to `localhost` and
  assets 404.
- Run it as a background process and verify with
  `curl -s -o /dev/null -w '%{http_code}' <url>` before reporting success.
- Confirm the IP with `ip -4 addr` instead of assuming, if a connection fails.
- On "restart": stop the existing Hugo container first
  (`podman ps` → `podman stop <id>`), then start a fresh one. A stale server
  started before a `baseURL` change will serve broken asset paths.
- For a one-off production check: `./hugo.sh --gc --minify`.

## 2. Review passes over articles

When I say "do a pass", run these in order unless I name a specific one.

### Pass A — correctness

Check every factual claim: Aniimo names and spellings, elements, roles
(DPS / Break / Support / Heal / Regen), evolution lines, alpha/egg
availability, item names, stat priorities, and type-chart interactions.
Verify against the type chart, the official Aniimo wiki/Aniilog listings and
community tier lists; search the web when unsure.

Report as three buckets:

- **Verified** — brief, just enough that I know it was checked.
- **Inaccuracies** — with the correct value and where it appears.
- **Unverified** — claims you could not confirm from any public source. Say
  so plainly; do not assume they are wrong.

Fix only unambiguous factual errors (a misspelled Aniimo or item name). Opinion
claims ("X is the best DPS") and contested takes get flagged, not changed — I
am fine publishing controversial opinions.

### Pass B — typos and syntax

Apply directly: spelling, subject/verb agreement, plurals, missing articles,
missing punctuation, sentence fragments, duplicated words, hyphenation.

Consistency rules for this site:

- Element names capitalised: Dark, Lightning, Wind, Fire, Water, Grass, Earth,
  Ice, Light.
- "Aniimo" always capitalised; "Lightning" never "Lighting".
- Stats written as `ATK`, `HP`, `BREAK`, `REGEN`, `DEF`.
- Item names lowercase (`gargantuan horn`, `ferocious fang`,
  `capacitous battery`, `explosive globes`, `fission needle`,
  `spirited feather`, `miraculous fleece`, `marching flask`).
- Pronouns per Aniimo stay consistent within the article.
- Keep the file's existing hard-wrap width; rewrap any line you lengthen.

### Pass C — clarity and consistency

Structural, non-destructive only:

- Heading levels consistent (siblings at the same depth, no skipped levels).
- The `## Contents` index at the top matches the actual headings and anchors.
- Internal contradictions between sections.
- Terminology used the same way throughout.
- **Flag long-running paragraphs** — list them by line range with a suggested
  split point. Do not split them yourself.

### Reporting

End every pass with: what you changed (as a short diff or bullet list), what
you flagged, and whether both the `content/` and `Writerside/` copies are in
sync.

## 3. Images and assets

- No AI image generation is available here. Images are composed
  programmatically with **ImageMagick** (`magick`, installed on the host);
  `graphviz`/`mermaid-cli` can be run via `podman` for diagrams.
- Every generated image must come from a **committed, re-runnable script** in
  `scripts/` (see `scripts/make-tldr-image.sh`), never from ad-hoc commands.
  If I ask for a tweak, edit the script and re-run it.
- Match the site palette: bg `#11131a`, panel `#161922`, border `#242836`,
  text `#e6e8ee`, muted `#9aa3b2`, accent `#7aa2f7`.
- Portraits come from the official Aniimo wiki CDN
  (`worldx-website-cdn.aniimo.com`). Trim and resize to 240px max before
  committing; keep them in `static/images/aniimo/<lowercase-name>.png`.
- Reference images with absolute paths: `![Name](/images/...)`.
  `layouts/_default/_markup/render-image.html` prefixes the Pages sub-path and
  picks the class: `/images/aniimo/*` → `.aniimo-portrait` (inline thumbnail),
  anything else → `.figure-image` (full-width block).
- Any article using official artwork keeps the attribution line at the bottom:
  "Aniimo artwork belongs to Hero Games and is used here for illustrative
  purposes in a fan-made guide."
- Always inspect the generated image before declaring it done — check for
  clipped captions and lopsided rows.

## Verification checklist before reporting done

1. `./hugo.sh --gc --minify` builds with no errors.
2. The dev server returns 200 for `/` and the edited guide.
3. `content/` and `Writerside/` copies are identical.
4. New images exist under `public/images/` after a build.

## Out of scope

- Writing or rewriting article content, adding sections, changing opinions.
- Committing or pushing without being asked.
- Installing anything on the host; use containers.
