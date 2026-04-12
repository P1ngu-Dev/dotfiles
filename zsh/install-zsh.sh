#!/usr/bin/env bash
# Instala zsh, Oh My Zsh, plugins y tema desde cero

set -e  # detener si algo falla

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── 1. Instalar zsh si no está ──────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
    echo "Instalando zsh..."
    if command -v pacman &>/dev/null;   then sudo pacman -S --needed zsh
    elif command -v dnf &>/dev/null;    then sudo dnf install -y zsh
    elif command -v zypper &>/dev/null; then sudo zypper install -y zsh
    elif command -v apt &>/dev/null;    then sudo apt install -y zsh
    fi
else
    echo "zsh ya instalado: $(zsh --version)"
fi

# ── 2. Instalar Oh My Zsh si no está ────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
else
    echo "Oh My Zsh ya instalado."
fi

# ── 3. Plugins ───────────────────────────────────────────────────────────────
plugins=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "marlonrichert/zsh-autocomplete"
)

for plugin in "${plugins[@]}"; do
    name="${plugin##*/}"
    dir="$ZSH_CUSTOM/plugins/$name"
    if [[ ! -d "$dir" ]]; then
        echo "Instalando $name..."
        git clone "https://github.com/$plugin" "$dir"
    else
        echo "$name ya instalado, actualizando..."
        git -C "$dir" pull
    fi
done

# ── 4. Powerlevel10k ─────────────────────────────────────────────────────────
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    echo "Instalando powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k \
        "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "Powerlevel10k ya instalado."
fi

# ── 5. Cambiar shell default a zsh ───────────────────────────────────────────
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Cambiando shell default a zsh..."
    chsh -s "$(which zsh)"
else
    echo "Shell ya es zsh."
fi

echo ""
echo "Listo. Reinicia la terminal o corre: exec zsh"
