#!/usr/bin/env bash
# =============================================================================
# PenguOS — First Boot Setup
# Se ejecuta en el primer inicio de sesión del usuario pingu
# Descarga los dotfiles y ejecuta el script de post-instalación
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BLUE}[*]${RESET} $1"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }
success() { echo -e "${GREEN}[+]${RESET} $1"; }
error() { echo -e "${RED}[x]${RESET} $1"; }

BOLD_CYAN="${BOLD}${CYAN}"

REPO="P1ngu-Dev/dotfiles"
BRANCH="${1:-main}"

BOOTSTRAP_DONE_FLAG="$HOME/.bootstrap_done"
DOTFILES_DIR="$HOME/.dotfiles"

info "PenguOS First Boot Setup"
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Verificaciones ────────────────────────────────────────────────────────────
if [[ "$EUID" -eq 0 ]]; then
    error "No correr este script como root. Usá tu usuario normal."
    exit 1
fi

if [[ -f "$BOOTSTRAP_DONE_FLAG" ]]; then
    success "Bootstrap ya ejecutado. Omitiendo."
    info "Si querés correrlo de nuevo: rm $BOOTSTRAP_DONE_FLAG"
    exit 0
fi

if ! command -v git &>/dev/null; then
    error "Git no está instalado. ¿Se ejecutó correctamente archinstall?"
    exit 1
fi

# ── Clonar dotfiles ───────────────────────────────────────────────────────────
if [[ ! -d "$DOTFILES_DIR" ]]; then
    info "Clonando dotfiles..."
    if git clone "https://github.com/${REPO}.git" "$DOTFILES_DIR"; then
        success "Dotfiles clonados correctamente."
    else
        error "Falló al clonar los dotfiles."
        exit 1
    fi
else
    info "Dotfiles ya existen en $DOTFILES_DIR, actualizando..."
    git -C "$DOTFILES_DIR" pull || true
fi

# ── Verificar que arch.sh existe ──────────────────────────────────────────────
ARCH_SCRIPT="$DOTFILES_DIR/install/arch.sh"
if [[ ! -f "$ARCH_SCRIPT" ]]; then
    error "arch.sh no encontrado en $ARCH_SCRIPT"
    exit 1
fi

# ── Ejecutar arch.sh ─────────────────────────────────────────────────────────
info "Ejecutando script de post-instalación..."
echo ""
if bash "$ARCH_SCRIPT"; then
    success "Post-instalación completada!"
else
    error "La post-instalación tuvo errores. Revisá el output arriba."
    exit 1
fi

# ── Marcar como completado ───────────────────────────────────────────────────
touch "$BOOTSTRAP_DONE_FLAG"
echo ""
success "Bootstrap completado. Disfrutá tu PenguOS!"
echo ""
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"