# HumboltOS modern CLI replacements
# Guarda este archivo en: ~/.config/zsh/modern-cli.zsh
# Luego cárgalo desde tu ~/.zshrc con:
#   source ~/.config/zsh/modern-cli.zsh
#
# Objetivo:
# - Reemplazar por completo comandos clásicos por alternativas modernas
# - Mantener una vía explícita a los binarios originales con aliases *raw
# - Evitar romper el shell si algún binario no está instalado

# PATH para herramientas instaladas con cargo
export PATH="$HOME/.cargo/bin:$PATH"

# -----------------------------
# Utilidades internas
# -----------------------------
_has() {
  command -v "$1" >/dev/null 2>&1
}

# Alias
alias ll='ls -la --color=auto'
alias update='sudo dnf update -y'
alias hypr-reload='hyprctl reload'
alias vim='nvim'  
alias sdi='sudo dnf install -y'
alias save='snapper -c root create --description'

# -----------------------------
# cd -> zoxide
# -----------------------------
# Reemplaza cd completamente. También habilita z, zi, etc. según zoxide.
if _has zoxide; then
  eval "$(zoxide init zsh --cmd cd)"
  alias zox='zoxide query -i'
fi

# -----------------------------
# cat -> bat / batcat
# -----------------------------
if _has bat; then
  alias cat='bat --paging=never'
  alias catp='bat'
elif _has batcat; then
  alias cat='batcat --paging=never'
  alias catp='batcat'
fi
alias catraw='/usr/bin/cat'

# -----------------------------
# ls -> eza / exa / lsd
# -----------------------------
if _has eza; then
  alias ls='eza --group-directories-first --icons=auto'
  alias l='eza --group-directories-first --icons=auto'
  alias la='eza -a --group-directories-first --icons=auto'
  alias ll='eza -lah --git --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
elif _has exa; then
  alias ls='exa --group-directories-first --icons'
  alias l='exa --group-directories-first --icons'
  alias la='exa -a --group-directories-first --icons'
  alias ll='exa -lah --git --group-directories-first --icons'
  alias lt='exa --tree --level=2 --group-directories-first --icons'
elif _has lsd; then
  alias ls='lsd'
  alias l='lsd'
  alias la='lsd -a'
  alias ll='lsd -lah'
  alias lt='lsd --tree --depth 2'
fi
alias lsraw='/usr/bin/ls'

# -----------------------------
# find -> fd / fdfind
# -----------------------------
if _has fd; then
  alias find='fd'
elif _has fdfind; then
  alias find='fdfind'
fi
alias findraw='/usr/bin/find'

# -----------------------------
# grep -> rg
# -----------------------------
if _has rg; then
  alias grep='rg'
  alias rgi='rg -i'
fi
alias grepraw='/usr/bin/grep'

# -----------------------------
# du -> dust
# -----------------------------
if _has dust; then
  alias du='dust'
fi
alias duraw='/usr/bin/du'

# -----------------------------
# df -> duf
# -----------------------------
if _has duf; then
  alias df='duf'
fi
alias dfraw='/usr/bin/df'

# -----------------------------
# ps -> procs
# -----------------------------
if _has procs; then
  alias ps='procs'
fi
alias psraw='/usr/bin/ps'

# -----------------------------
# top -> btop / bottom / htop
# -----------------------------
if _has btop; then
  alias top='btop'
elif _has btm; then
  alias top='btm'
elif _has bottom; then
  alias top='bottom'
elif _has htop; then
  alias top='htop'
fi

# -----------------------------
# tree -> broot / eza tree
# -----------------------------
if _has broot; then
  alias tree='broot'
elif _has eza; then
  alias tree='eza --tree --level=3 --icons=auto'
elif _has exa; then
  alias tree='exa --tree --level=3 --icons'
fi
alias treeraw='/usr/bin/tree'

# -----------------------------
# man -> tldr (reemplazo agresivo)
# -----------------------------
# Esto es útil para uso diario, pero no es equivalente a man.
# Si necesitas la documentación completa, usa manraw.
#
#if _has tldr; then
#  alias man='tldr'
#fi
#alias manraw='/usr/bin/man'

# -----------------------------
# sed -> sd
# -----------------------------
# Ojo: sd no es 100% compatible con sed. Alias agresivo.
if _has sd; then
  alias sed='sd'
fi
alias sedraw='/usr/bin/sed'

# -----------------------------
# diff -> difft / delta
# -----------------------------
# No son equivalentes exactos a diff. Se exponen como reemplazo visual.
if _has difft; then
  alias diff='difft'
elif _has difftastic; then
  alias diff='difftastic'
elif _has delta; then
  alias diff='delta'
fi
alias diffraw='/usr/bin/diff'

# -----------------------------
# hexdump -> hexyl
# -----------------------------
if _has hexyl; then
  alias hexdump='hexyl'
fi
alias hexdumpraw='/usr/bin/hexdump'

# -----------------------------
# dig -> dog / drill
# -----------------------------
if _has dog; then
  alias dig='dog'
elif _has drill; then
  alias dig='drill'
fi
alias digraw='/usr/bin/dig'

# -----------------------------
# locate -> plocate
# -----------------------------
if _has plocate; then
  alias locate='plocate'
fi
alias locateraw='/usr/bin/locate'

# -----------------------------
# Extras modernos recomendados
# -----------------------------
if _has fzf; then
  alias ff='fzf'
fi

if _has jq; then
  alias json='jq'
fi

if _has glow; then
  alias md='glow'
fi

if _has xh; then
  alias http='xh'
elif _has httpie; then
  alias http='http'
fi

# -----------------------------
# Nota importante
# -----------------------------
# Algunos reemplazos NO son 100% compatibles semánticamente:
# - man -> tldr
# - sed -> sd
# - diff -> difftastic/delta
# - dig -> dog/drill
# - tree -> broot
# Esto está hecho a propósito porque pediste reemplazarlos por completo,
# pero para scripts y troubleshooting usa siempre los *raw.
