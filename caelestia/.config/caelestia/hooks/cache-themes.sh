#!/usr/bin/env bash
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/caelestia/themes"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$CACHE"

declare -A FILES=(
  ["btop/themes/caelestia.theme"]="btop.theme"
  ["cava/config"]="cava.conf"
  ["discord-themes/caelestia.theme.css"]="discord.css"
  ["fuzzel/fuzzel.ini"]="fuzzel.ini"
  ["gtk-3.0/gtk.css"]="gtk-3.0-colors.css"
  ["gtk-3.0/thunar.css"]="thunar.css"
  ["gtk-4.0/gtk.css"]="gtk-4.0-colors.css"
  ["gtk-4.0/thunar.css"]="thunar.css"
  ["htop/htoprc"]="htoprc"
  ["hypr/scheme/current.conf"]="hypr.conf"
  ["kitty/caelestia.conf"]="kitty.conf"
  ["nvtop/nvtop.colors"]="nvtop.colors"
  ["opencode/themes/caelestia.json"]="opencode.json"
  ["qtengine/caelestia.colors"]="qtengine.colors"
  ["spicetify/Themes/caelestia/color.ini"]="spicetify.ini"
  ["zed/themes/caelestia.json"]="zed.json"
)

for src_rel in "${!FILES[@]}"; do
  cache_name="${FILES[$src_rel]}"
  src="$CONFIG/$src_rel"
  dst="$CACHE/$cache_name"

  # Skip if source doesn't exist
  if [[ ! -e "$src" ]]; then
    continue
  fi

  # If source is a symlink already pointing to our cache, skip
  if [[ -L "$src" ]]; then
    current_target=$(readlink "$src")
    if [[ "$current_target" == "$dst" ]]; then
      continue
    fi
  fi

  # Copy content (follows symlinks via cp) and replace with symlink to cache
  cp "$src" "$dst"
  rm "$src"
  ln -sf "$dst" "$src"
done
