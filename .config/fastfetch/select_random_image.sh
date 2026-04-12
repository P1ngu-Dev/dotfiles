#!/bin/bash
# Script para seleccionar imagen aleatoria excluyendo las últimas 3 mostradas

IMAGE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/images"
HISTORY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/.image_history"

# Crear archivo de historial si no existe
touch "$HISTORY_FILE"

# Obtener todas las imágenes disponibles
mapfile -t ALL_IMAGES < <(find "$IMAGE_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) | sort)

# Leer las últimas 3 imágenes mostradas
mapfile -t LAST_IMAGES < <(tail -n 3 "$HISTORY_FILE")

# Filtrar imágenes disponibles excluyendo las últimas 3
AVAILABLE_IMAGES=()
for img in "${ALL_IMAGES[@]}"; do
    skip=0
    for last in "${LAST_IMAGES[@]}"; do
        if [[ "$img" == "$last" ]]; then
            skip=1
            break
        fi
    done
    if [[ $skip -eq 0 ]]; then
        AVAILABLE_IMAGES+=("$img")
    fi
done

# Si no hay imágenes disponibles (solo tienes 3 o menos), usar todas
if [[ ${#AVAILABLE_IMAGES[@]} -eq 0 ]]; then
    AVAILABLE_IMAGES=("${ALL_IMAGES[@]}")
fi

# Seleccionar una imagen aleatoria
RANDOM_IMAGE="${AVAILABLE_IMAGES[$RANDOM % ${#AVAILABLE_IMAGES[@]}]}"

# Guardar en el historial
echo "$RANDOM_IMAGE" >> "$HISTORY_FILE"

# Mantener solo las últimas 3 entradas en el historial
tail -n 3 "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

# Retornar la imagen seleccionada
echo "$RANDOM_IMAGE"
