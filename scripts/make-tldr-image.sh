#!/usr/bin/env bash
# Generate the TL;DR summary image for the "What to Build" guide.
#
# Draws every Aniimo recommended in the TL;DR tables, grouped the same way
# (Splashable first, then the elemental cores), with role, stat priority and
# item under each portrait.
#
# Needs ImageMagick 7 (`magick`) and the portraits in static/images/aniimo/.
#
# Usage: ./scripts/make-tldr-image.sh [output.png]
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${PROJECT_DIR}/static/images/aniimo"
OUT="${1:-${PROJECT_DIR}/static/images/what-to-build-tldr.png}"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

BG='#11131a'
PANEL='#161922'
BORDER='#242836'
FG='#e6e8ee'
MUTED='#9aa3b2'
ACCENT='#7aa2f7'
FONT='DejaVu-Sans'
FONT_BOLD='DejaVu-Sans-Bold'

CELL_W=210
PORTRAIT_H=120
PAD=12
COLUMNS=4

# name|file|role|stats|item
cell() {
  local name="$1" file="$2" role="$3" stats="$4" item="$5"
  local out="${WORK}/cell_${file}_$(echo "$name" | tr -cd '[:alnum:]').png"

  magick "${SRC}/${file}.png" -background none \
    -resize "x${PORTRAIT_H}" -gravity south -extent "${CELL_W}x${PORTRAIT_H}" +repage \
    "${WORK}/p.png"

  magick -background none -fill "${FG}" -font "${FONT_BOLD}" -pointsize 20 \
    -size "$((CELL_W - 2 * PAD))x" -gravity center caption:"${name}" "${WORK}/t1.png"
  magick -background none -fill "${ACCENT}" -font "${FONT}" -pointsize 16 \
    -size "$((CELL_W - 2 * PAD))x" -gravity center caption:"${role}" "${WORK}/t2.png"
  magick -background none -fill "${MUTED}" -font "${FONT}" -pointsize 14 \
    -size "$((CELL_W - 2 * PAD))x" -gravity center caption:"${stats}" "${WORK}/t3.png"
  magick -background none -fill "${MUTED}" -font "${FONT}" -pointsize 14 \
    -size "$((CELL_W - 2 * PAD))x" -gravity center caption:"${item}" "${WORK}/t4.png"

  magick "${WORK}/p.png" "${WORK}/t1.png" "${WORK}/t2.png" "${WORK}/t3.png" "${WORK}/t4.png" \
    -background none -gravity center -append +repage \
    -bordercolor none -border "0x${PAD}" \
    -background "${PANEL}" -flatten \
    -bordercolor "${BORDER}" -border 1 +repage \
    "${out}"
  echo "${out}"
}

# Groups are collected first; the header bands are drawn at the end, once the
# final width is known, so each one spans the whole image.
row_cells=()
titles=()
strips=()

flush_group() {
  local title="$1"
  [ "${#row_cells[@]}" -eq 0 ] && return 0
  local slug
  slug="$(echo "$title" | tr -cd '[:alnum:]')"
  local strip="${WORK}/row_${slug}.png"
  # Equal cell heights, so every portrait in the group shares a baseline.
  local max_h=0 h c
  for c in "${row_cells[@]}"; do
    h="$(magick identify -format '%h' "${c}")"
    [ "${h}" -gt "${max_h}" ] && max_h="${h}"
  done
  local sized=()
  for c in "${row_cells[@]}"; do
    magick "${c}" -background "${PANEL}" -gravity north \
      -extent "x${max_h}" +repage "${c%.png}_h.png"
    sized+=("${c%.png}_h.png")
  done
  # Wrap into lines of at most COLUMNS cells, then stack the lines.
  local lines=() chunk=() n=0 idx=0
  for c in "${sized[@]}"; do
    chunk+=("${c}")
    n=$((n + 1))
    if [ "${n}" -eq "${COLUMNS}" ]; then
      magick "${chunk[@]}" -background "${BG}" -gravity north +append +repage \
        "${WORK}/line_${slug}_${idx}.png"
      lines+=("${WORK}/line_${slug}_${idx}.png")
      idx=$((idx + 1))
      chunk=()
      n=0
    fi
  done
  if [ "${n}" -gt 0 ]; then
    magick "${chunk[@]}" -background "${BG}" -gravity north +append +repage \
      "${WORK}/line_${slug}_${idx}.png"
    lines+=("${WORK}/line_${slug}_${idx}.png")
  fi
  magick "${lines[@]}" -background "${BG}" -gravity west -append +repage "${strip}"
  titles+=("${title}")
  strips+=("${strip}")
  row_cells=()
}

add() { row_cells+=("$(cell "$@")"); }

# ---- Splashable ----------------------------------------------------------
add "Turbo" turbo "Support (buffer)" "ATK" "ferocious fang"
add "Tromber" tromber "Support (buffer)" "ATK" "ferocious fang"
add "Glacy" glacy "Heal" "HP" "marching flask"
add "Gracewing" gracewing "Heal" "HP" "miraculous fleece"
add "Somniwing" somniwing "Regen" "REGEN" "spirited feather"
add "Besauce" besauce "Regen" "REGEN" "spirited feather"
add "Inferlupa" inferlupa "Break" "BREAK, HP, DEF, ATK" "gargantuan horn"
flush_group "Splashable — use them on any team"

# ---- Elemental cores -----------------------------------------------------
add "Prismana Turbo" turbo "Support" "ATK" "ferocious fang"
add "Ignitis" ignitis "DPS" "ATK, HP, DEF" "crit items"
add "Stellarys" stellarys "DPS" "ATK" "fission needle"
add "Inferlupa" inferlupa "Break" "BREAK, HP, DEF, ATK" "gargantuan horn"
flush_group "Dark"

add "Luminelle" luminelle "Support" "ATK" "ferocious fang"
add "Fulmintis" fulmintis "DPS" "ATK, HP, DEF" "crit items"
add "Blazen" blazen "Break" "BREAK, HP, ATK, DEF" "gargantuan horn"
flush_group "Lightning"

add "Tromber" tromber "Support" "ATK" "ferocious fang"
add "Hypnyto" hypnyto "DPS" "ATK, HP, DEF" "crit items"
add "Helgon" helgon "Break" "BREAK, HP, ATK, DEF" "gargantuan horn"
flush_group "Wind"

add "Sparkelf" sparkelf "Support" "ATK" "ferocious fang"
add "Scorchhowl" scorchhowl "DPS" "ATK" "explosive globes"
add "Squashel" squashel "Break" "BREAK, HP, ATK, DEF" "gargantuan horn"
flush_group "Fire"

add "Sherro" sherro "DPS" "ATK" "capacitous battery"
add "Panpanta" panpanta "Break / pseudo-support" "BREAK, HP, ATK, DEF" "gargantuan horn"
flush_group "Water"

add "Melloblum" melloblum "Support" "ATK" "ferocious fang"
add "Leafy" leafy "Regen / Support" "REGEN" "spirited feather"
add "Irisalis" irisalis "DPS" "ATK" "crit items"
flush_group "Grass"

# ---- Assemble ------------------------------------------------------------
# The widest row sets the image width; headers and rows are padded to it.
MAX_W=0
for strip in "${strips[@]}"; do
  w="$(magick identify -format '%w' "${strip}")"
  [ "${w}" -gt "${MAX_W}" ] && MAX_W="${w}"
done

parts=()
for i in "${!strips[@]}"; do
  slug="$(echo "${titles[$i]}" | tr -cd '[:alnum:]')"
  hdr="${WORK}/hdr_${slug}.png"
  magick -size "$((MAX_W - 2))x44" "xc:${PANEL}" \
    -font "${FONT_BOLD}" -pointsize 24 -fill "${ACCENT}" \
    -gravity west -annotate +16+0 "${titles[$i]}" \
    -bordercolor "${BORDER}" -border 1 +repage "${hdr}"
  padded="${strips[$i]%.png}_padded.png"
  magick "${strips[$i]}" -background "${BG}" -gravity west \
    -extent "${MAX_W}x" +repage "${padded}"
  parts+=("${hdr}" "${padded}")
done

magick "${parts[@]}" -background "${BG}" -gravity west -append +repage "${WORK}/body.png"
BODY_W="$(magick identify -format '%w' "${WORK}/body.png")"

magick -size "${BODY_W}x" -background "${BG}" -fill "${FG}" \
  -font "${FONT_BOLD}" -pointsize 40 -gravity west caption:"What to Build — TL;DR" \
  "${WORK}/title.png"
magick -size "${BODY_W}x" -background "${BG}" -fill "${MUTED}" \
  -font "${FONT}" -pointsize 16 -gravity west \
  caption:"Aniimo Ramblings · artwork belongs to Hero Games, used for illustrative purposes in a fan-made guide" \
  "${WORK}/footer.png"

magick "${WORK}/title.png" "${WORK}/body.png" "${WORK}/footer.png" \
  -background "${BG}" -gravity west -append +repage \
  -bordercolor "${BG}" -border 28 +repage \
  -depth 8 -strip \
  "${OUT}"

magick identify "${OUT}"
