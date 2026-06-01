# dotfiles

## Instalación en Arch Linux limpio

> ⚠ El repo es privado. Usá un [token de GitHub](https://github.com/settings/tokens) en la URL o cloná el repo primero.

### 1. Instalación del sistema (desde ISO)

```bash
curl -sL "https://<TOKEN>@raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/iso/iso-install.sh" | bash
```

### 2. Post-install bootstrap (después de reiniciar)

```bash
# Con token
curl -sL "https://<TOKEN>@raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/arch.sh" | bash

# O clonando primero y ejecutando local
git clone --depth=1 https://<TOKEN>@github.com/P1ngu-Dev/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install/arch.sh
```
