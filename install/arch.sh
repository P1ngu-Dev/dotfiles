#!/usr/bin/env bash
# =============================================================================
# HumboltOS — Arch Post-Install Bootstrap
# Correr DESPUÉS de archinstall, como usuario normal (no root)
# =============================================================================

# No usamos set -e para poder capturar errores y continuar cuando no son críticos.

# ── Colores y UI ─────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

CHECK_MARK="\xE2\x9C\x94"
CROSS_MARK="\xE2\x9C\x98"
INFO_MARK="\xE2\x84\xB9"

# Variables para seguimiento
declare -a SUCCESS_STEPS
declare -a FAILED_STEPS
declare -a SKIPPED_STEPS

# Funciones de Logging
info() { echo -e "${BLUE}[${INFO_MARK}]${RESET} $1"; }
success() { echo -e "${GREEN}[${CHECK_MARK}]${RESET} $1"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[${CROSS_MARK}]${RESET} $1"; }
section() { echo -e "\n${BOLD}${CYAN}━━━ $1 ━━━${RESET}"; }

# Funciones de Tracking (TUI Summary)
track_success() {
  success "$1"
  SUCCESS_STEPS+=("$1")
}

track_error() {
  error "$1"
  FAILED_STEPS+=("$1")
}

track_skipped() {
  warn "$1 (Saltado)"
  SKIPPED_STEPS+=("$1")
}

fatal_error() {
  error "ERROR CRÍTICO: $1"
  echo -e "${RED}El script no puede continuar. Abortando.${RESET}"
  exit 1
}

# ── Verificaciones iniciales ──────────────────────────────────────────────────
[[ "$EUID" -eq 0 ]] && fatal_error "No correr como root. Usá tu usuario normal."
command -v pacman &>/dev/null || fatal_error "Este script es solo para Arch Linux."

section "HumboltOS Arch Bootstrap"
info "Usuario: $(whoami) | Fecha: $(date)"

# ── 1. Actualizar sistema ─────────────────────────────────────────────────────
section "1. Actualización del sistema"
if sudo pacman -Syu --noconfirm; then
  track_success "Actualización del sistema"
else
  track_error "Actualización del sistema"
fi

# ── 2. Dependencias base ──────────────────────────────────────────────────────
section "2. Dependencias base"
if sudo pacman -S --needed --noconfirm git base-devel curl wget stow; then
  track_success "Dependencias base instaladas"
else
  fatal_error "No se pudieron instalar las dependencias base (git, base-devel). Requeridas para yay."
fi

# ── 3. Instalar yay ──────────────────────────────────────────────────────────
section "3. Yay (AUR helper)"
if ! command -v yay &>/dev/null; then
  info "Instalando yay..."
  tmpdir=$(mktemp -d)
  if git clone https://aur.archlinux.org/yay.git "$tmpdir/yay" && \
     (cd "$tmpdir/yay" && makepkg -si --noconfirm); then
    rm -rf "$tmpdir"
    track_success "yay instalado desde AUR"
  else
    track_error "Fallo al instalar yay"
    rm -rf "$tmpdir"
  fi
else
  track_success "yay ya instalado: $(yay --version | head -1)"
fi

# ── 4. Paquetes oficiales ─────────────────────────────────────────────────────
section "4. Paquetes oficiales"

PACMAN_PKGS=(
  7zip alsa-tools alsa-utils amd-ucode aria2 audacity base base-devel bat
  bitwarden blueman bluez bluez-utils brightnessctl broot btop btrfs-progs
  chromium cliphist cpu-x discord dnsmasq docker duf dust edk2-ovmf
  efibootmgr eza fastfetch fd firefox fish fzf gamemode gemini-cli gimp git
  github-cli go goverlay greetd grim grub grub-btrfs gst-plugin-pipewire
  guestfs-tools haruna htop hypridle hyprland hyprlock hyprpolkitagent
  hyprshot inotify-tools kdenlive kitty kubectl lazygit lib32-mesa
  lib32-vulkan-radeon libosinfo libpulse libreoffice-fresh libvirt linux
  linux-firmware mangohud mpv nano ncdu neovim networkmanager
  nm-connection-editor nmap noto-fonts npm nwg-bar nwg-look obs-studio
  obsidian oculante ollama opencode openrgb openssh os-prober
  otf-commit-mono-nerd pacman-contrib pavucontrol php pipewire pipewire-alsa
  pipewire-jack pipewire-pulse playerctl pnpm polkit-gnome prismlauncher procs
  qemu-full qemu-img qt5-wayland qt6-virtualkeyboard qt6-wayland retroarch
  ripgrep rofi rsync sddm sddm-kcm seahorse shortwave shotcut slurp snapper
  spotify-launcher steam stow sudo swappy swtpm telegram-desktop thunar
  thunderbird tldr tmux tor ttf-jetbrains-mono-nerd tuned udiskie unzip
  virt-install virt-manager virt-viewer vulkan-radeon waybar wget wireplumber
  wireshark-qt wl-clipboard wpa_supplicant xdg-desktop-portal-hyprland
  xdg-utils yazi zed zoxide zram-generator zsh
)

if sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"; then
  track_success "Paquetes oficiales (pacman) instalados"
else
  track_error "Hubo errores al instalar algunos paquetes oficiales"
fi

# ── 5. Paquetes AUR ───────────────────────────────────────────────────────────
section "5. Paquetes AUR"

if command -v yay &>/dev/null; then
  AUR_PKGS=(
    antigravity caelestia-shell paru-debug spicetify-bin spotatui-bin
    ttf-material-symbols-variable-git warp-terminal-autoup-bin yay yay-debug
    zen-browser-bin
  )

  if yay -S --needed --noconfirm "${AUR_PKGS[@]}"; then
    track_success "Paquetes AUR instalados"
  else
    track_error "Hubo errores al instalar algunos paquetes AUR"
  fi
else
  track_skipped "Instalación de paquetes AUR (yay no está disponible)"
fi

# ── 6. Servicios ──────────────────────────────────────────────────────────────
section "6. Servicios"
if sudo systemctl enable --now NetworkManager; then
  track_success "Servicio NetworkManager habilitado"
else
  track_error "Fallo al habilitar NetworkManager"
fi

if sudo systemctl enable --now bluetooth; then
  track_success "Servicio bluetooth habilitado"
else
  track_error "Fallo al habilitar bluetooth"
fi

# ── 7. Clonar dotfiles ────────────────────────────────────────────────────────
section "7. Dotfiles"

DOTFILES_REPO="git@github.com:$(git config --global user.name 2>/dev/null || echo 'TU-USUARIO')/dotfiles.git"

if [[ ! -d "$HOME/.dotfiles" ]]; then
  warn "Asegurate de tener tu clave SSH configurada antes de este paso"
  read -rp "¿Continuar con clone SSH? [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    if git clone "$DOTFILES_REPO" "$HOME/.dotfiles"; then
      track_success "Dotfiles clonados correctamente"
    else
      track_error "Fallo al clonar los dotfiles"
    fi
  else
    track_skipped "Clonado de dotfiles"
  fi
else
  track_success ".dotfiles ya existe, clonado omitido"
fi

# ── 8. Stow ───────────────────────────────────────────────────────────────────
section "8. Stow — aplicar configuraciones"

if [[ -d "$HOME/.dotfiles" ]]; then
  cd "$HOME/.dotfiles" || exit
  STOW_PKGS=(hyprland kitty nvim yazi fastfetch zsh git mimeapps scripts caelestia btop cava gtk-3.0 gtk-4.0 qtengine spicetify mako fuzzel warp-terminal thunar vesktop zed)
  
  stow_errors=0
  for pkg in "${STOW_PKGS[@]}"; do
    if [[ -d "$pkg" ]]; then
      if stow "$pkg"; then
        success "stow: $pkg"
      else
        error "stow: $pkg falló (posible conflicto de archivos)"
        stow_errors=$((stow_errors + 1))
      fi
    else
      warn "Paquete '$pkg' no encontrado en .dotfiles, saltando"
    fi
  done
  
  if [ "$stow_errors" -eq 0 ]; then
    track_success "Todas las configuraciones aplicadas (Stow)"
  else
    track_error "Algunas configuraciones (Stow) fallaron ($stow_errors errores)"
  fi
else
  track_skipped "Stow omitido (directorio .dotfiles no encontrado)"
fi

# ── 9. Zsh + Oh My Zsh ───────────────────────────────────────────────────────
section "9. Zsh + Oh My Zsh"

if [[ -f "$HOME/.dotfiles/zsh/install-zsh.sh" ]]; then
  if bash "$HOME/.dotfiles/zsh/install-zsh.sh"; then
    track_success "Script de instalación de Zsh ejecutado"
  else
    track_error "Fallo en el script de instalación de Zsh"
  fi
else
  track_skipped "Script install-zsh.sh no encontrado"
fi

if [[ "$SHELL" != "$(which zsh)" ]]; then
  if chsh -s "$(which zsh)"; then
    track_success "Shell cambiado a zsh"
  else
    track_error "Fallo al cambiar la shell a zsh (intenta manualmente)"
  fi
else
  track_success "zsh ya es la shell por defecto"
fi

# ── 10. Post-config CLI ───────────────────────────────────────────────────────
section "10. Post-config CLI"
if zoxide init zsh >/dev/null 2>&1; then
  track_success "zoxide inicializado"
else
  track_error "Fallo al inicializar zoxide"
fi

# ── Resumen (TUI) ─────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${CYAN}════════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}                     RESUMEN DE INSTALACIÓN                     ${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════════${RESET}\n"

if [ ${#SUCCESS_STEPS[@]} -gt 0 ]; then
  echo -e "${GREEN}${BOLD}Operaciones Exitosas:${RESET}"
  for step in "${SUCCESS_STEPS[@]}"; do
    echo -e "  ${GREEN}${CHECK_MARK}${RESET} $step"
  done
  echo ""
fi

if [ ${#SKIPPED_STEPS[@]} -gt 0 ]; then
  echo -e "${YELLOW}${BOLD}Operaciones Omitidas:${RESET}"
  for step in "${SKIPPED_STEPS[@]}"; do
    echo -e "  ${YELLOW}-${RESET} $step"
  done
  echo ""
fi

if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo -e "${RED}${BOLD}Operaciones Fallidas (Requieren intervención manual):${RESET}"
  for step in "${FAILED_STEPS[@]}"; do
    echo -e "  ${RED}${CROSS_MARK}${RESET} $step"
  done
  echo ""
else
  echo -e "${GREEN}${BOLD}¡Todo se instaló y configuró sin errores!${RESET}\n"
fi

echo -e "${BOLD}${CYAN}Próximos pasos manuales sugeridos:${RESET}"
echo "  1. Reiniciar sesión para que zsh tome efecto"
echo "  2. Verificar monitores en ~/.config/hypr/monitors.conf"
echo "  3. Revisar dispositivos de audio: pactl list sinks"
echo "  4. Si hubo errores en stow, revisa archivos conflictivos en ~/.config"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════════${RESET}\n"
