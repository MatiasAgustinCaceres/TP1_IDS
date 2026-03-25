#!/bin/bash

BASE_DIR="$HOME/EPNro1"
ENTRADA="$BASE_DIR/entrada"
SALIDA="$BASE_DIR/salida"
PROCESADO="$BASE_DIR/procesado"
PID_FILE="$BASE_DIR/proceso.pid"

# Validar variable de entorno
if [ -z "$FILENAME" ]; then
    echo "Error: Debe definir la variable de entorno FILENAME"
    exit 1
fi

ARCHIVO_SALIDA="$SALIDA/$FILENAME.txt"

# Parámetro opcional -d
if [ "$1" == "-d" ]; then
    echo "Eliminando entorno..."

    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
        echo "Proceso en background detenido."
    fi

    rm -rf "$BASE_DIR"
    echo "Entorno eliminado."
    exit 0
fi

while true; do
    echo ""
    echo "===== MENÚ ====="
    echo "1) Crear entorno"
    echo "2) Correr proceso"
    echo "3) Listar alumnos ordenados por padrón"
    echo "4) Mostrar 10 notas más altas"
    echo "5) Buscar por padrón"
    echo "6) Salir"
    echo "================"

    read -p "Seleccione una opción: " opcion

    case $opcion in
        1)
            mkdir -p "$ENTRADA" "$SALIDA" "$PROCESADO"
            echo "Entorno creado en $BASE_DIR"

            # Crear consolidar.sh
            cat << 'EOF' > "$BASE_DIR/consolidar.sh"
#!/bin/bash

BASE_DIR="$HOME/EPNro1"
ENTRADA="$BASE_DIR/entrada"
SALIDA="$BASE_DIR/salida"
PROCESADO="$BASE_DIR/procesado"

ARCHIVO_SALIDA="$SALIDA/$FILENAME.txt"

touch "$ARCHIVO_SALIDA"

while true; do
    for file in "$ENTRADA"/*.txt; do
        [ -e "$file" ] || continue

        cat "$file" >> "$ARCHIVO_SALIDA"
        mv "$file" "$PROCESADO"
    done

    sleep 5
done
EOF

            chmod +x "$BASE_DIR/consolidar.sh"
            ;;
        2)
            if [ -f "$PID_FILE" ]; then
                echo "El proceso ya está corriendo."
            else
                nohup bash "$BASE_DIR/consolidar.sh" >/dev/null 2>&1 &
                echo $! > "$PID_FILE"
                echo "Proceso iniciado en background."
            fi
            ;;
        3)
            if [ -f "$ARCHIVO_SALIDA" ]; then
                sort -n "$ARCHIVO_SALIDA"
            else
                echo "No existe el archivo."
            fi
            ;;
        4)
            if [ -f "$ARCHIVO_SALIDA" ]; then
                sort -k4 -nr "$ARCHIVO_SALIDA" | head -n 10
            else
                echo "No existe el archivo."
            fi
            ;;
        5)
            if [ -f "$ARCHIVO_SALIDA" ]; then
                read -p "Ingrese padrón: " padron
                grep "^$padron " "$ARCHIVO_SALIDA"
            else
                echo "No existe el archivo."
            fi
            ;;
        6)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción inválida"
            ;;
    esac
done

