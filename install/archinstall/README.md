# HumboltOS — Base Arch Linux Install

Esta carpeta contiene la configuración predefinida para automatizar la instalación **base** de Arch Linux usando la herramienta oficial `archinstall`. 

Al usar esto, te ahorrás configurar manualmente cosas repetitivas (como el perfil de audio, bootloader, red, idioma, repositorios, etc.), mientras que dejás a `archinstall` preguntarte solo lo importante (en qué disco instalar y tus contraseñas) para mayor seguridad.

### ¿Por qué perfil "minimal"?
Tu script `arch.sh` se encarga de instalar toda tu interfaz gráfica (Hyprland, Caelestia, Waybar, etc.). Por lo tanto, la instalación base solo necesita darte un sistema en BTRFS con internet, multilib, tu usuario y `git`.

## Instrucciones de Instalación

1. Bootear desde el **Live USB** de Arch Linux.
2. Asegurate de tener internet (ej: `iwctl` para WiFi).
3. Descargar este archivo de configuración directamente a tu Live USB:
   ```bash
   curl -O https://raw.githubusercontent.com/P1ngu-Dev/dotfiles/main/install/archinstall/user_configuration.json
   ```
4. Ejecutar `archinstall` pasándole esta configuración:
   ```bash
   archinstall --config user_configuration.json
   ```
5. `archinstall` se abrirá y ya tendrá configurado:
   * **Idioma/Teclado:** en_US (us layout)
   * **Zona Horaria:** America/Santiago
   * **Audio:** Pipewire
   * **Red:** NetworkManager
   * **Bootloader:** GRUB
   * **Swap:** zRAM (zstd)
   * **Repositorios:** multilib habilitado
6. Solo tendrás que completar de forma interactiva en la pantalla:
   * **Disk Configuration** (Elegir qué disco borrar y decirle que use BTRFS)
   * **User Accounts** (Crear tu usuario `pingu`, establecer que sea sudoer, y tu contraseña)
   * **User password / Root password**
7. Darle a **Install**.

Una vez finalizado, reiniciá el sistema (`reboot`), iniciá sesión con tu usuario, y ejecutá tu script `arch.sh` para transformar esa instalación base en tu sistema completo:

```bash
git clone https://github.com/P1ngu-Dev/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install/arch.sh
```