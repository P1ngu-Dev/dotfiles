#!/usr/bin/env bash
set -euo pipefail

scheme_file="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
theme_dir="$config_dir/themes"
theme_file="$theme_dir/caelestia.json"

if [[ ! -f "$scheme_file" ]]; then
  exit 0
fi

mkdir -p "$theme_dir"

export SCHEME_FILE="$scheme_file"
export THEME_FILE_PATH="$theme_file"

# Genera el JSON del tema via Python para manejar los colores con alpha correctamente
python - <<'PY'
import json, os
from pathlib import Path

scheme_file = os.environ["SCHEME_FILE"]
with open(scheme_file, "r", encoding="utf-8") as f:
    data = json.load(f)

cols = data.get("colours", {})

def c(key):
    """Devuelve el color hex sin # o string vacío."""
    return cols.get(key, "")

def hex_alpha(key, alpha_pct):
    """Devuelve color hex de 8 dígitos con alpha (0-100)."""
    val = c(key)
    if not val:
        return None
    a = round(alpha_pct / 100 * 255)
    return f"#{val}{a:02x}"

bg         = c("background")
on_bg      = c("onBackground")
primary    = c("primary")
secondary  = c("secondary")
tertiary   = c("tertiary")
on_primary = c("onPrimary")
surface_container      = c("surfaceContainer")
surface_container_low  = c("surfaceContainerLow")
surface_container_high = c("surfaceContainerHigh")
surface_variant        = c("surfaceVariant")
on_surface_variant     = c("onSurfaceVariant")
outline                = c("outline")
outline_variant        = c("outlineVariant")
success                = c("success")
success_container      = c("successContainer")
error                  = c("error")
error_container        = c("errorContainer")
yellow                 = c("yellow")
term1  = c("term1")
term2  = c("term2")
term3  = c("term3")
term4  = c("term4")
term5  = c("term5")
term9  = c("term9")
term10 = c("term10")

if not bg or not on_bg or not primary:
    exit(0)

# Paneles con alpha para el efecto "blur panel" sobre el fondo transparente de kitty
panel_bg   = hex_alpha("surfaceContainer",     70)  # 70% opacidad
element_bg = hex_alpha("surfaceContainerHigh", 80)  # 80% opacidad
border_col = hex_alpha("outlineVariant",       60)  # bordes sutiles
subtle_col = hex_alpha("surfaceVariant",       50)

theme = {
    "$schema": "https://opencode.ai/theme.json",
    "defs": {
        "onBackground":          f"#{on_bg}",
        "primary":               f"#{primary}",
        "secondary":             f"#{secondary}",
        "tertiary":              f"#{tertiary}",
        "onPrimary":             f"#{on_primary}",
        "onSurfaceVariant":      f"#{on_surface_variant}",
        "outline":               f"#{outline}",
        "outlineVariant":        f"#{outline_variant}",
        "success":               f"#{success}",
        "successContainer":      f"#{success_container}",
        "error":                 f"#{error}",
        "errorContainer":        f"#{error_container}",
        "yellow":                f"#{yellow}",
        "term1":                 f"#{term1}",
        "term2":                 f"#{term2}",
        "term3":                 f"#{term3}",
        "term4":                 f"#{term4}",
        "term5":                 f"#{term5}",
        "term9":                 f"#{term9}",
        "term10":                f"#{term10}",
        # Panels con alpha embebido
        "panelBg":               panel_bg,
        "elementBg":             element_bg,
        "borderCol":             border_col,
        "subtleCol":             subtle_col,
        "surfaceContainerLow":   f"#{surface_container_low}",
    },
    "theme": {
        # Transparente → hereda el fondo de kitty (con su blur/opacity)
        "background":        "none",
        "backgroundPanel":   "panelBg",
        "backgroundElement": "elementBg",

        "primary":           "primary",
        "secondary":         "secondary",
        "accent":            "tertiary",
        "error":             "error",
        "warning":           "yellow",
        "success":           "success",
        "info":              "term4",

        "text":              "onBackground",
        "textMuted":         "onSurfaceVariant",

        "border":            "borderCol",
        "borderActive":      "primary",
        "borderSubtle":      "subtleCol",

        "diffAdded":             "success",
        "diffRemoved":           "error",
        "diffContext":           "onSurfaceVariant",
        "diffHunkHeader":        "secondary",
        "diffHighlightAdded":    "term10",
        "diffHighlightRemoved":  "term9",
        "diffAddedBg":           "successContainer",
        "diffRemovedBg":         "errorContainer",
        "diffContextBg":         "surfaceContainerLow",
        "diffLineNumber":        "onSurfaceVariant",
        "diffAddedLineNumberBg":   "successContainer",
        "diffRemovedLineNumberBg": "errorContainer",

        "markdownText":             "onBackground",
        "markdownHeading":          "primary",
        "markdownLink":             "primary",
        "markdownLinkText":         "secondary",
        "markdownCode":             "term2",
        "markdownBlockQuote":       "onSurfaceVariant",
        "markdownEmph":             "onBackground",
        "markdownStrong":           "onBackground",
        "markdownHorizontalRule":   "outlineVariant",
        "markdownListItem":         "primary",
        "markdownListEnumeration":  "yellow",
        "markdownImage":            "primary",
        "markdownImageText":        "secondary",
        "markdownCodeBlock":        "onBackground",

        "syntaxComment":     "onSurfaceVariant",
        "syntaxKeyword":     "term5",
        "syntaxFunction":    "term4",
        "syntaxVariable":    "onBackground",
        "syntaxString":      "term2",
        "syntaxNumber":      "term3",
        "syntaxType":        "term4",
        "syntaxOperator":    "term5",
        "syntaxPunctuation": "onSurfaceVariant",
    }
}

out_path = os.environ.get("THEME_FILE_PATH", "")
Path(out_path).write_text(json.dumps(theme, indent=2) + "\n")
PY

# Asegurar que tui.json selecciona el tema caelestia
config_file="$config_dir/tui.json"
if [[ ! -f "$config_file" ]]; then
  printf '{\n  "theme": "caelestia"\n}\n' > "$config_file"
else
  CONFIG_FILE="$config_file" python - <<'PY'
import json, os
from pathlib import Path
path = Path(os.environ["CONFIG_FILE"])
try:
    data = json.loads(path.read_text())
except Exception:
    data = {}
data["theme"] = "caelestia"
path.write_text(json.dumps(data, indent=2) + "\n")
PY
fi
