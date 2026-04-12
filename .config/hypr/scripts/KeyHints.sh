#!/usr/bin/env bash

cat <<'EOF' | rofi -dmenu -i -p "Keybinds" -theme-str 'window {width: 700px;} listview {lines: 18;}'
SUPER + Enter    terminal
SUPER + E        file manager
SUPER + R        app launcher
SUPER + H        quick help
SUPER + S        web search
SUPER + Shift+S  screenshot
SUPER + Shift+K  search keybinds
SUPER + F        fullscreen
SUPER + Ctrl+F   maximize
SUPER + V        toggle floating
SUPER + 1..0     switch workspace
SUPER + Shift+1..0 move window to workspace
SUPER + arrows   resize active window
SUPER + mouse wheel workspace next/prev
EOF