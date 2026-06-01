# Feature: ISO Auto-instaladora (PenguOS ISO)

## Motivación

Actualmente el setup requiere:
1. Bootear ISO oficial de Arch
2. Ejecutar `iso-install.sh` (descarga configs de archinstall)
3. Ejecutar `archinstall` manualmente
4. Reiniciar
5. Ejecutar `arch.sh` (bootstrap post-instalación)

Esto depende de internet, de GitHub, y tiene pasos manuales. Se busca una **ISO propia** que al bootear haga todo el setup completo sin intervención, dejando el sistema listo con todas las configs aplicadas.

## Objetivo

- **Instalación fresca** — no es clonar mi máquina actual. Es instalar Arch desde cero con todo configurado: hyprland, waybar, kitty, nvim, zsh, servicios, firewall, snapper, etc.
- **Plug & play** — bootear la ISO, elegir disco (o que lo detecte solo), esperar, y al reiniciar tener el sistema completo.
- **Lo único que se pierde al formatear son archivos personales** — todo lo configurable ya está pre-aplicado.
- **Post-instalación liviano** — scripts para gestionar cosas que cambio frecuentemente (temas, paquetes nuevos, etc.), pero el grueso ya viene del ISO.

## Enfoque propuesto

Usar `archiso` para construir una ISO que contenga:

- **Dentro del ISO (airootfs):**
  - Los dotfiles completos (se copian automáticamente desde `~/.dotfiles/` al buildear)
  - `arch.sh` y `archinstall` configs
  - Un script de arranque que ejecute el pipeline completo

- **Pipeline automatizado al bootear:**
  1. Particionado automático (o preguntar disco al inicio)
  2. `archinstall` con configs pre-cargadas
  3. Post-instalación: copiar dotfiles, stow, servicios, etc.
  4. Reboot → sistema listo

## Diferencia con el setup actual

| Hoy | ISO propio |
|---|---|
| Depende de GitHub para scripts y configs | Todo incluido en el ISO |
| Pasos manuales (elegir disco, confirmar) | Automático o mínima interacción |
| Necesita internet para bajar dotfiles | Los dotfiles viajan en el ISO |
| Post-instalación pesado (instala todo) | Solo lo que cambia frecuentemente |

## Mantenimiento

- El ISO se **rebuildéa desde mi máquina** con un `build-iso.sh` que copia automáticamente los dotfiles actuales.
- Si cambio una config de Hyprland, kitty, etc. → rebuild ISO y ya está.
- Los cambios frecuentes (temas, paquetes nuevos, etc.) se gestionan con un script post-instalación separado, no requieren rebuildear el ISO.

## Estructura planeada

```
install/iso/
├── build-iso.sh              # Script que construye la ISO
├── profiledef.sh             # Config de archiso
├── pacman.conf               # PAckage list para la ISO base
├── airootfs/
│   ├── root/
│   │   ├── dotfiles/         # Se copia automáticamente al buildear
│   │   ├── arch.sh           # Post-install bootstrap
│   │   └── auto-install.sh   # Entry point del pipeline
│   └── etc/
│       └── ...               # Configs del entorno live si hacen falta
└── README.md                 # Cómo buildear y usar
```

## Notas

- No se busca una "golden image" con paquetes pre-instalados (sería enorme). Se busca una ISO que automatice la instalación oficial de Arch con todo configurado.
- Los paquetes se instalan desde los repos en el momento, igual que hoy.
- Lo que viaja en el ISO son: scripts, configs, dotfiles — cosas livianas.
