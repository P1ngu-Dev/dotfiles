#!/usr/bin/env bash
# =============================================================================
# HumboltOS — Arch Post-Install Bootstrap
# Correr DESPUÉS de archinstall, como usuario normal (no root)
# =============================================================================

set -e

# ── Colores ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() {
  echo -e "${RED}[ERROR]${RESET} $1"
  exit 1
}
section() { echo -e "\n${BOLD}━━━ $1 ━━━${RESET}"; }

# ── Verificaciones iniciales ──────────────────────────────────────────────────
[[ "$EUID" -eq 0 ]] && error "No correr como root. Usá tu usuario normal."
command -v pacman &>/dev/null || error "Este script es solo para Arch Linux."

section "HumboltOS Arch Bootstrap"
info "Usuario: $(whoami) | Fecha: $(date)"

# ── 1. Actualizar sistema ─────────────────────────────────────────────────────
section "1. Actualización del sistema"
sudo pacman -Syu --noconfirm
success "Sistema actualizado"

# ── 2. Dependencias base ──────────────────────────────────────────────────────
section "2. Dependencias base"
sudo pacman -S --needed --noconfirm git base-devel curl wget stow
success "Dependencias base instaladas"

# ── 3. Instalar paru ──────────────────────────────────────────────────────────
section "3. Paru (AUR helper)"
if ! command -v paru &>/dev/null; then
  info "Instalando paru..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
  (cd "$tmpdir/paru" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
  success "paru instalado"
else
  success "paru ya instalado: $(paru --version | head -1)"
fi

# ── 4. Paquetes oficiales ─────────────────────────────────────────────────────
section "4. Paquetes oficiales"

PACMAN_PKGS=(
  # Hyprland stack
  hyprland xdg-desktop-portal-hyprland xdg-utils
  waybar rofi-wayland
  hyprpaper hypridle hyprlock
  wl-clipboard cliphist
  grim slurp swappy

  # Terminal y shell
  kitty zsh

  # Editor
  neovim

  # Fuentes
  ttf-jetbrains-mono-nerd

  # Audio (pipewire)
  pipewire pipewire-alsa pipewire-audio pipewire-pulse pipewire-jack
  wireplumber pavucontrol

  # GPU AMD
  mesa lib32-mesa
  vulkan-radeon lib32-vulkan-radeon
  libva-mesa-driver lib32-libva-mesa-driver

  # CLI modernas
  yazi fastfetch btop
  fzf bat eza zoxide fd ripgrep
  dust duf procs tldr

  # Utilidades sistema
  brightnessctl playerctl
  networkmanager nm-connection-editor
  bluez bluez-utils
  udiskie
  polkit-gnome
  qt5-wayland qt6-wayland
  nwg-look

  # Apps
  mpv

  # Dev
  github-cli
)

sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
success "Paquetes oficiales instalados"

# ── 5. Paquetes AUR ───────────────────────────────────────────────────────────
section "5. Paquetes AUR"

AUR_PKGS=(
  oculante
  hyprshot
  nwg-bar
)

paru -S --needed --noconfirm "${AUR_PKGS[@]}"
success "Paquetes AUR instalados"

# ── 6. Servicios ──────────────────────────────────────────────────────────────
section "6. Servicios"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
success "Servicios habilitados"

# ── 7. Clonar dotfiles ────────────────────────────────────────────────────────
section "7. Dotfiles"

DOTFILES_REPO="git@github.com:$(git config --global user.name 2>/dev/null || echo 'TU-USUARIO')/dotfiles.git"

if [[ ! -d "$HOME/.dotfiles" ]]; then
  warn "Asegurate de tener tu clave SSH configurada antes de este paso"
  read -rp "¿Continuar con clone SSH? [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git clone "$DOTFILES_REPO" "$HOME/.dotfiles"
    success "Dotfiles clonados"
  else
    warn "Saltando clone — hacelo manualmente después"
  fi
else
  success ".dotfiles ya existe, saltando clone"
fi

# ── 8. Stow ───────────────────────────────────────────────────────────────────
section "8. Stow — aplicar configuraciones"

if [[ -d "$HOME/.dotfiles" ]]; then
  cd "$HOME/.dotfiles"
  STOW_PKGS=(hyprland kitty nvim yazi fastfetch zsh git mimeapps scripts)
  for pkg in "${STOW_PKGS[@]}"; do
    if [[ -d "$pkg" ]]; then
      stow "$pkg" && success "stow: $pkg" || warn "stow: $pkg falló (conflicto?)"
    else
      warn "Paquete '$pkg' no encontrado, saltando"
    fi
  done
fi

# ── 9. Zsh + Oh My Zsh ───────────────────────────────────────────────────────
section "9. Zsh + Oh My Zsh"

if [[ -f "$HOME/.dotfiles/zsh/install-zsh.sh" ]]; then
  bash "$HOME/.dotfiles/zsh/install-zsh.sh"
fi

if [[ "$SHELL" != "$(which zsh)" ]]; then
  chsh -s "$(which zsh)"
  success "Shell cambiado a zsh"
fi

# ── 10. Post-config CLI ───────────────────────────────────────────────────────
section "10. Post-config CLI"
zoxide init zsh >/dev/null 2>&1 && success "zoxide OK" || warn "zoxide init falló"

# ── Resumen ───────────────────────────────────────────────────────────────────
section "Bootstrap completo"
echo -e "\n  Próximos pasos manuales:"
echo "  1. Reiniciar sesión para que zsh tome efecto"
echo "  2. Verificar monitores en ~/.config/hypr/monitors.conf"
echo "  3. Revisar audio: pactl list sinks"
echo "  4. Configurar Waybar y Rofi al gusto"
