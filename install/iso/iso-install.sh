#!/usr/bin/env bash
# =============================================================================
# PenguOS — Arch Linux Installation Bootstrapper
# Correr DESPUÉS de bootear la ISO de Arch Linux
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

BRANCH="${1:-main}"
REPO="P1ngu-Dev/dotfiles"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/install"

info "PenguOS Installation Bootstrapper"
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Verificaciones ────────────────────────────────────────────────────────────
if ! command -v curl &>/dev/null; then
    error "curl no está disponible. Esta imagen de Arch no lo incluye."
    exit 1
fi

if ! command -v archinstall &>/dev/null; then
    error "archinstall no está disponible. Ejecutá desde la ISO oficial de Arch."
    exit 1
fi

# ── Detectar conexión a internet ─────────────────────────────────────────────
info "Verificando conexión a internet..."
if ! curl -s --max-time 5 https://github.com &>/dev/null; then
    warn "No hay conexión a internet detectada."
    echo ""
    echo "Para conectarte a WiFi ejecutá: iwctl"
    echo "O configurá ethernet si tenés cable."
    echo ""
    read -rp "Press Enter cuando estés conectado para continuar..."
fi

success "Conexión a internet verificada."

# ── Descargar configuración ───────────────────────────────────────────────────
info "Descargando configuración de archinstall..."
CONFIG_DIR=$(mktemp -d)
cd "$CONFIG_DIR"

if curl -sL -o user_configuration.json "${BASE_URL}/archinstall/user_configuration.json" && \
   curl -sL -o user_credentials.json "${BASE_URL}/archinstall/user_credentials.json"; then
    success "Configuración descargada."
else
    error "Falló la descarga de configuración."
    exit 1
fi

# ── Mostrar resumen ──────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Resumen de configuración pre-cargada:${RESET}"
echo ""
echo "  • Idioma: en_US (teclado US)"
echo "  • Zona horaria: America/Santiago"
echo "  • Audio: Pipewire"
echo "  • Red: NetworkManager"
echo "  • Bootloader: GRUB"
echo "  • Swap: zRAM (zstd)"
echo "  • Repositorios: multilib"
echo "  • Perfil: Minimal"
echo "  • Usuario: pingu (sudo)"
echo ""
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}Durante la instalación vas a necesitar:${RESET}"
echo "  1. Seleccionar el disco donde instalar"
echo "  2. Establecer contraseña para 'pingu'"
echo "  3. Establecer contraseña para root"
echo ""
read -rp "Press Enter para continuar con archinstall..."

# ── Ejecutar archinstall ──────────────────────────────────────────────────────
info "Ejecutando archinstall..."
echo ""

archinstall --config user_configuration.json --creds user_credentials.json

# ── Post-install ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Instalación completada!${RESET}"
echo ""
success "Ahora necesitas:"
echo "  1. Reiniciar el sistema"
echo "  2. Iniciar sesión como 'pingu'"
echo "  3. Ejecutar el script de post-instalación:"
echo ""
echo -e "  ${CYAN}curl -L https://raw.githubusercontent.com/${REPO}/${BRANCH}/install/first-boot/bootstrap.sh | bash${RESET}"
echo "  o"
echo -e "  ${CYAN}git clone https://github.com/${REPO}.git ~/.dotfiles && bash ~/.dotfiles/install/arch.sh${RESET}"
echo ""
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

cd /
rm -rf "$CONFIG_DIR"