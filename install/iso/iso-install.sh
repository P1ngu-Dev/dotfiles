#!/usr/bin/env bash
# =============================================================================
# PenguOS — Arch Linux Installation Bootstrapper
# Descarga la configuración de archinstall y ejecuta el installer
# =============================================================================

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
CONFIG_FILE="user_configuration.json"
CREDS_FILE="user_credentials.json"

info "PenguOS Installation Bootstrapper"
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Verificaciones ────────────────────────────────────────────────────────────
if ! command -v curl &>/dev/null; then
    error "curl no está disponible."
    exit 1
fi

if ! command -v archinstall &>/dev/null; then
    error "archinstall no está disponible. Ejecutá desde la ISO oficial de Arch."
    exit 1
fi

# ── Detectar conexión a internet ─────────────────────────────────────────────
info "Verificando conexión a internet..."
if ! curl -s --max-time 5 https://github.com &>/dev/null; then
    warn "No hay conexión a internet."
    echo ""
    echo "Para conectarte a WiFi ejecutá: iwctl"
    echo "O configurá ethernet si tenés cable."
    echo ""
    read -rp "Press Enter cuando estés conectado para continuar..."
fi

success "Conexión a internet verificada."

# ── Descargar configuración ───────────────────────────────────────────────────
download_configs() {
    info "Descargando configuración..."
    if curl -sL -o "$CONFIG_FILE" "${BASE_URL}/archinstall/$CONFIG_FILE" && \
       curl -sL -o "$CREDS_FILE" "${BASE_URL}/archinstall/$CREDS_FILE"; then
        success "Configuración descargada."
        return 0
    else
        error "Falló la descarga de configuración."
        return 1
    fi
}

echo ""
if [[ -f "$CONFIG_FILE" && -f "$CREDS_FILE" ]]; then
    info "Ya existe configuración en el directorio actual."
    read -rp "¿Querés volver a descargar? [y/N]: " redownload
    if [[ "${redownload,,}" == "y" ]]; then
        download_configs
    else
        success "Usando archivos existentes."
    fi
else
    download_configs
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
echo -e "${BOLD}Archivos descargados:${RESET}"
echo "  $(pwd)/$CONFIG_FILE"
echo "  $(pwd)/$CREDS_FILE"
echo ""
echo "Para ejecutar archinstall:"
echo -e "  ${CYAN}archinstall --config $CONFIG_FILE${RESET}"
echo ""
echo "O con credenciales (experimental):"
echo -e "  ${CYAN}archinstall --config $CONFIG_FILE --creds $CREDS_FILE${RESET}"
echo ""
read -rp "¿Querés ejecutar archinstall ahora? [Y/n]: " run_install

if [[ "${run_install,,}" =~ ^n ]]; then
    info "Saliendo. Los archivos quedaron descargados."
    info "Ejecutá 'archinstall --config $CONFIG_FILE' cuando quieras."
    exit 0
fi

# ── Ejecutar archinstall ──────────────────────────────────────────────────────
info "Ejecutando archinstall..."
echo ""
archinstall --config "$CONFIG_FILE" --creds "$CREDS_FILE"

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
echo ""
echo -e "${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"