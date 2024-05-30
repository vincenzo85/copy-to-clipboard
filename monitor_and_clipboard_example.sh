#!/bin/bash

# File da monitorare
SOURCE_FILE="./file.txt" 

# Verifica se inotify-tools è installato
if ! command -v inotifywait &> /dev/null
then
    echo "inotifywait non è installato. Installalo con 'sudo apt install inotify-tools'."
    exit 1
fi

# Verifica se xclip è installato
if ! command -v xclip &> /dev/null
then
    echo "xclip non è installato. Installalo con 'sudo apt install xclip'."
    exit 1
fi

# Funzione per copiare il contenuto del file nella clipboard
copy_to_clipboard() {
    cat "$SOURCE_FILE" | xclip -selection clipboard
    echo "Contenuto copiato nella clipboard da $SOURCE_FILE"
}

# Funzione per monitorare il file utilizzando polling
monitor_file() {
    LAST_CONTENT=$(cat "$SOURCE_FILE")
    copy_to_clipboard
    while true; do
        CURRENT_CONTENT=$(cat "$SOURCE_FILE")
        if [ "$CURRENT_CONTENT" != "$LAST_CONTENT" ]; then
            LAST_CONTENT="$CURRENT_CONTENT"
            copy_to_clipboard
        fi
        sleep 2  # Intervallo di polling di 2 secondi (modifica secondo necessità)
    done
}

# Esegui la funzione di monitoraggio
monitor_file
