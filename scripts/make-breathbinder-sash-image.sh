#!/usr/bin/env bash
# Generate the breathbinder sash figure for the "BREAK Melloblum" guide.
#
# Draws the item's loop: stacks of [Momentum] build up in combat, a damage
# skill consumes them, and each one adds crit rate for 3s. Everything is
# drawn from scratch with ImageMagick, so no game art is used here.
#
# Needs ImageMagick 7 (`magick`).
#
# Usage: ./scripts/make-breathbinder-sash-image.sh [output.png]
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-${PROJECT_DIR}/static/images/breathbinder-sash.png}"
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

CARD_W=230
CARD_H=150
PAD=14

# title|value|note
card() {
  local title="$1" value="$2" note="$3" out="$4"
  magick -size "$((CARD_W - 2 * PAD))x" -background none -fill "${MUTED}" \
    -font "${FONT}" -pointsize 16 -gravity center caption:"${title}" "${WORK}/c1.png"
  magick -size "$((CARD_W - 2 * PAD))x" -background none -fill "${ACCENT}" \
    -font "${FONT_BOLD}" -pointsize 30 -gravity center caption:"${value}" "${WORK}/c2.png"
  magick -size "$((CARD_W - 2 * PAD))x" -background none -fill "${FG}" \
    -font "${FONT}" -pointsize 15 -gravity center caption:"${note}" "${WORK}/c3.png"

  magick "${WORK}/c1.png" "${WORK}/c2.png" "${WORK}/c3.png" \
    -background none -gravity center -append +repage \
    -bordercolor none -border "0x${PAD}" \
    -background "${PANEL}" -gravity center -extent "$((CARD_W - 2))x$((CARD_H - 2))" \
    -bordercolor "${BORDER}" -border 1 +repage \
    "${out}"
}

arrow() {
  magick -size "60x${CARD_H}" "xc:${BG}" \
    -fill "${ACCENT}" -stroke "${ACCENT}" -strokewidth 3 \
    -draw "line 10,$((CARD_H / 2)) 44,$((CARD_H / 2))" \
    -draw "polygon 44,$((CARD_H / 2 - 9)) 56,$((CARD_H / 2)) 44,$((CARD_H / 2 + 9))" \
    +repage "$1"
}

card "In combat" "3 stacks" "1 [Momentum] every 3s, caps at 3" "${WORK}/s1.png"
card "Damage skill" "consumes all" "Blasting Roses spends the stacks" "${WORK}/s2.png"
card "For 3s" "+99% crit" "3 x 33% on top of the 10% base" "${WORK}/s3.png"
arrow "${WORK}/a1.png"
cp "${WORK}/a1.png" "${WORK}/a2.png"

magick "${WORK}/s1.png" "${WORK}/a1.png" "${WORK}/s2.png" "${WORK}/a2.png" "${WORK}/s3.png" \
  -background "${BG}" -gravity center +append +repage "${WORK}/body.png"
BODY_W="$(magick identify -format '%w' "${WORK}/body.png")"

magick -size "${BODY_W}x" -background "${BG}" -fill "${FG}" \
  -font "${FONT_BOLD}" -pointsize 34 -gravity west caption:"breathbinder sash" \
  "${WORK}/title.png"
magick -size "${BODY_W}x" -background "${BG}" -fill "${MUTED}" \
  -font "${FONT}" -pointsize 16 -gravity west \
  caption:"Legendary, level 15 - the loop that turns Melloblum into guaranteed crits" \
  "${WORK}/subtitle.png"

magick "${WORK}/title.png" "${WORK}/subtitle.png" "${WORK}/body.png" \
  -background "${BG}" -gravity west -append +repage \
  -bordercolor "${BG}" -border 28 +repage \
  -depth 8 -strip \
  "${OUT}"

magick identify "${OUT}"
