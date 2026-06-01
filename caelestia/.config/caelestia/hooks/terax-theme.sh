#!/usr/bin/env bash
set -euo pipefail

scheme_file="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
terax_dir="${XDG_DATA_HOME:-$HOME/.local/share}/app.crynta.terax"
themes_file="$terax_dir/terax-custom-themes.json"
settings_file="$terax_dir/terax-settings.json"

if [[ ! -f "$scheme_file" ]]; then
  exit 0
fi

mkdir -p "$terax_dir"

export SCHEME_FILE="$scheme_file"
export THEMES_FILE="$themes_file"
export SETTINGS_FILE="$settings_file"

python3 - <<'PY'
import json, os
from pathlib import Path

scheme_file = os.environ["SCHEME_FILE"]
themes_file = os.environ["THEMES_FILE"]
settings_file = os.environ["SETTINGS_FILE"]

with open(scheme_file, "r", encoding="utf-8") as f:
    data = json.load(f)

cols = data.get("colours", {})

def c(key):
    return cols.get(key, "")

def rgba(key, alpha_pct):
    val = c(key)
    if not val:
        return None
    r = int(val[0:2], 16)
    g = int(val[2:4], 16)
    b = int(val[4:6], 16)
    a = alpha_pct / 100
    return f"rgba({r},{g},{b},{a:.2f})"

bg = c("background")
on_bg = c("onBackground")
primary = c("primary")
on_primary = c("onPrimary")
secondary = c("secondary")
tertiary = c("tertiary")
surface_container = c("surfaceContainer")
surface_container_high = c("surfaceContainerHigh")
surface_variant = c("surfaceVariant")
on_surface_variant = c("onSurfaceVariant")
outline = c("outline")
outline_variant = c("outlineVariant")
error = c("error")
success = c("success")

term0 = c("term0")
term1 = c("term1")
term2 = c("term2")
term3 = c("term3")
term4 = c("term4")
term5 = c("term5")
term6 = c("term6")
term7 = c("term7")
term8 = c("term8")
term9 = c("term9")
term10 = c("term10")
term11 = c("term11")
term12 = c("term12")
term13 = c("term13")
term14 = c("term14")
term15 = c("term15")

if not bg or not on_bg or not primary:
    exit(0)

theme = {
    "id": "caelestia",
    "name": "Caelestia",
    "description": "Dynamic theme from wallpaper colors",
    "editorTheme": {"dark": "atomone"},
    "variants": {
        "dark": {
            "colors": {
                "background": f"#{bg}",
                "foreground": f"#{on_bg}",
                "card": f"#{surface_container}",
                "cardForeground": f"#{on_bg}",
                "popover": f"#{surface_container_high}",
                "popoverForeground": f"#{on_bg}",
                "primary": f"#{primary}",
                "primaryForeground": f"#{on_primary}",
                "secondary": f"#{surface_variant}",
                "secondaryForeground": f"#{on_bg}",
                "muted": f"#{surface_variant}",
                "mutedForeground": f"#{on_surface_variant}",
                "accent": f"#{tertiary}",
                "accentForeground": f"#{on_bg}",
                "destructive": f"#{error}",
                "border": rgba("onBackground", 10),
                "input": rgba("onBackground", 14),
                "ring": f"#{primary}",
                "sidebar": f"#{surface_container}",
                "sidebarForeground": f"#{on_bg}",
                "sidebarPrimary": f"#{primary}",
                "sidebarPrimaryForeground": f"#{on_primary}",
                "sidebarAccent": f"#{surface_variant}",
                "sidebarAccentForeground": f"#{on_bg}",
                "sidebarBorder": rgba("onBackground", 10),
                "sidebarRing": f"#{primary}",
            },
            "terminal": {
                "cursor": f"#{on_bg}",
                "cursorAccent": f"#{bg}",
                "selection": rgba("primary", 25),
                "ansi": [
                    f"#{term0}", f"#{term1}", f"#{term2}", f"#{term3}",
                    f"#{term4}", f"#{term5}", f"#{term6}", f"#{term7}",
                    f"#{term8}", f"#{term9}", f"#{term10}", f"#{term11}",
                    f"#{term12}", f"#{term13}", f"#{term14}", f"#{term15}",
                ],
            },
        }
    }
}

themes_path = Path(themes_file)
try:
    existing = json.loads(themes_path.read_text()) if themes_path.exists() else {}
except Exception:
    existing = {}

if not isinstance(existing, dict):
    existing = {}

themes_list = existing.get("themes", [])
if not isinstance(themes_list, list):
    themes_list = []

themes_list = [t for t in themes_list if t.get("id") != "caelestia"]
themes_list.append(theme)

existing["themes"] = themes_list
themes_path.write_text(json.dumps(existing, indent=2) + "\n")

settings_path = Path(settings_file)
try:
    settings = json.loads(settings_path.read_text()) if settings_path.exists() else {}
except Exception:
    settings = {}

if not isinstance(settings, dict):
    settings = {}

settings["themeId"] = "caelestia"
settings["theme"] = "dark"
settings["editorTheme"] = "atomone"
settings["fontSize"] = 16
settings["zoomLevel"] = 1.25
settings["vimMode"] = False

settings_path.write_text(json.dumps(settings, indent=2) + "\n")
PY
