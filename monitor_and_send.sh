#!/bin/bash

# File locale da aggiornare
LOCAL_FILE="/home/vincenzo/Scrivania/sh/file_da_monitorare.txt"

# Indirizzo e utente remoto
REMOTE_USER="vincenzo"
REMOTE_HOST="192.168.1.102"
REMOTE_FILE_PATH="/home/vincenzo/Scrivania/diario/sh/file_da_monitorare.txt"

# Verifica se xclip è installato
if ! command -v xclip &> /dev/null
then
    echo "xclip non è installato. Installalo con 'sudo apt install xclip'."
    exit 1
fi

# Verifica se scp è installato
if ! command -v scp &> /dev/null
then
    echo "scp non è installato. Installalo con 'sudo apt install openssh-client'."
    exit 1
fi

# Funzione per ottenere il contenuto corrente della clipboard
get_clipboard_content() {
    xclip -selection clipboard -o
}

# Funzione per eseguire un'azione quando il contenuto della clipboard cambia
on_clipboard_change() {
    NEW_CONTENT=$(get_clipboard_content)
    echo "La clipboard è cambiata: $NEW_CONTENT"
    
    # Aggiorna il file locale
    echo "$NEW_CONTENT" > "$LOCAL_FILE"
    echo "Contenuto copiato in $LOCAL_FILE"
    
    # Invia il file al PC remoto
    echo "Eseguendo SCP..."
    scp "$LOCAL_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_FILE_PATH"
    
    # Verifica se SCP ha avuto successo
    if [ $? -eq 0 ]; then
        echo "File inviato con successo a $REMOTE_USER@$REMOTE_HOST:$REMOTE_FILE_PATH"
    else
        echo "Errore nell'invio del file a $REMOTE_USER@$REMOTE_HOST:$REMOTE_FILE_PATH"
    fi
}

# Inizializza il contenuto precedente della clipboard
LAST_CONTENT=$(get_clipboard_content)

# Loop di monitoraggio
while true; do
    CURRENT_CONTENT=$(get_clipboard_content)
    if [ "$CURRENT_CONTENT" != "$LAST_CONTENT" ]; then
        LAST_CONTENT="$CURRENT_CONTENT"
        on_clipboard_change
    fi
    sleep 1  # Intervallo di polling di 1 secondo (modifica secondo necessità)
done

