#!/bin/bash
SCREEN_HEIGHT=$(hyprctl monitors -j | jq '.[0].height')
BUTTONS_HEIGHT=200

MARGIN=$(( (SCREEN_HEIGHT - BUTTONS_HEIGHT) / 2 ))

wlogout \
  --css ~/.config/wlogout/style.css \
  --layout ~/.config/wlogout/layout.css \
  --buttons-per-row 4 \
  --margin-top $MARGIN \
  --margin-bottom $MARGIN
