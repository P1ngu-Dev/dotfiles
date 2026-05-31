# PenguOS — Base Arch Linux Install

Esta carpeta contiene la configuración predefinida para automatizar la instalación **base** de Arch Linux usando la herramienta oficial `archinstall`.

Al usar esto, te ahorrás configurar manualmente cosas repetitivas (como el perfil de audio, bootloader, red, idioma, repositorios, etc.), mientras que dejás a `archinstall` preguntarte solo lo importante (en qué disco instalar y tus contraseñas) para mayor seguridad.

### ¿Por qué perfil "minimal"?
Tu script `arch.sh` se encarga de instalar toda tu interfaz gráfica (Hyprland, Caelestia, Waybar, etc.). Por lo tanto, la instalación base solo necesita darte un sistema en BTRFS con internet, multilib, tu usuario y `git`.

## Estructura del instalador

```
install/
├── arch.sh              # Script principal de post-instalación
├── archinstall/         # Configs para archinstall
│   ├── user_configuration.json
│   └── user_credentials.json
├── iso/                 # Scripts para la ISO
│   └── iso-install.sh   # Descarga configs y ejecuta archinstall
├── first-boot/          # Scripts para el primer inicio
│   └── bootstrap.sh     # Clona dotfiles y ejecuta arch.sh
└── etc/                 # Configs del sistema
    └── systemd/zram-generator.conf
```

## Instalación automatizada (recomendado)

```bash
# 1. Desde la ISO: descarga configs y ejecuta archinstall
curl -L https://raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/iso/iso-install.sh | bash

# 2. Después de reiniciar (primer login): clona dotfiles y ejecuta post-install
curl -L https://raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/first-boot/bootstrap.sh | bash
```

## Instalación manual paso a paso

### Paso 1: Ejecutar archinstall

1. Bootear desde el **Live USB** de Arch Linux.
2. Asegurate de tener internet (ej: `iwctl` para WiFi).
3. Descargar la configuración:
   ```bash
   curl -O https://raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/archinstall/user_configuration.json
   curl -O https://raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/archinstall/user_credentials.json
   ```
4. Ejecutar archinstall:
   ```bash
   archinstall --config user_configuration.json --creds user_credentials.json
   ```
5. `archinstall` ya tendrá configurado:
   * **Idioma/Teclado:** en_US (us layout)
   * **Zona Horaria:** America/Santiago
   * **Audio:** Pipewire
   * **Red:** NetworkManager
   * **Bootloader:** GRUB
   * **Swap:** zRAM (zstd)
   * **Repositorios:** multilib habilitado
   * **Perfil:** Minimal
   * **Usuarios:** El usuario `pingu` (sudo) ya estará precargado, **solo necesitas ir a la opción de User Accounts en el menú y ponerle tu contraseña**, al igual que la contraseña de Root.
6. Darle a **Install**.

### Paso 2: Post-instalación

Una vez que reinicies y entres como `pingu`:

```bash
curl -L https://raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/first-boot/bootstrap.sh | bash
```

Esto va a:
1. Clonar tus dotfiles a `~/.dotfiles`
2. Ejecutar `arch.sh` automáticamente