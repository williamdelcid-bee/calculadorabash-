#!/bin/bash

# Verificar si 'bc' está instalado
if ! command -v bc &> /dev/null; then
    echo "Error: Se requiere 'bc' para esta calculadora."
    exit 1
fi

SCALE=4
HISTORIAL="historial_calc.txt"

# FUNCIÓN PARA DIBUJAR LA INTERFAZ VISUAL
mostrar_menu() {
    echo "======================================"
    echo "     Calculadora Científica           "
    echo "======================================"
    echo "Comandos especiales:"
    echo "  cls / clear   : Limpia las operaciones visibles"
    echo "  historial     : Ver operaciones guardadas"
    echo "  limpiar       : Borrar el archivo de historial"
    echo "  decimales <N> : Cambia los decimales"
    echo "--------------------------------------"
    echo "Escribe 'salir', 'exit' o 'q' para terminar."
    echo "======================================"
}

# Mostrar la interfaz al arrancar por primera vez
clear
mostrar_menu

while true; do
    read -p "Calcular> " expr

    if [[ "$expr" == "salir" || "$expr" == "exit" || "$expr" == "q" ]]; then
        echo "¡Adiós!"
        break
    fi

    if [[ -z "$expr" ]]; then
        continue
    fi

    # COMANDO CLS: Limpia pantalla Y vuelve a mostrar la interfaz visual
    if [[ "$expr" == "cls" || "$expr" == "clear" ]]; then
        clear
        mostrar_menu
        continue
    fi

    # Comando para ver el historial
    if [[ "$expr" == "historial" || "$expr" == "h" ]]; then
        echo "--- Historial ---"
        if [[ -f "$HISTORIAL" ]]; then
            cat "$HISTORIAL"
        else
            echo "Vacío."
        fi
        echo "-----------------"
        continue
    fi

    # Comando para borrar el historial
    if [[ "$expr" == "limpiar" || "$expr" == "borrar" ]]; then
        if [[ -f "$HISTORIAL" ]]; then
            rm "$HISTORIAL"
            echo "🗑️ Archivo de historial borrado."
        else
            echo "El historial ya estaba vacío."
        fi
        continue
    fi

    if [[ "$expr" =~ ^decimales[[:space:]]+([0-9]+)$ ]]; then
        SCALE="${BASH_REMATCH[1]}"
        echo "✅ Decimales: $SCALE"
        continue
    fi

    parsed_expr=$(echo "$expr" | sed -E -e 's/tan\(([^)]+)\)/(s(\1)\/c(\1))/g' -e 's/sin/s/g' -e 's/cos/c/g' -e 's/ln/l/g' -e 's/exp/e/g' -e 's/pi/(4*a(1))/g')

    result=$(echo "scale=$SCALE; $parsed_expr" | bc -l 2>/dev/null)

    if [[ -z "$result" ]]; then
        echo "❌ Error de sintaxis."
    else
        formatted_result=$(echo "$result" | awk '{if($0 ~ /^\./) print "0"$0; else if($0 ~ /^-\./) print "-0"substr($0,2); else print}')
        echo "Resultado: $formatted_result"
        echo "$expr = $formatted_result" >> "$HISTORIAL"
    fi
done
