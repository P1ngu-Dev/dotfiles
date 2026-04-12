#!/usr/bin/env bash
# Instala plugins y tema de Oh My Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

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

# Powerlevel10k
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    echo "Instalando powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k \
        "$ZSH_CUSTOM/themes/powerlevel10k"
fi

echo "Listo."
