#!/bin/bash

REPO_URL="https://github.com/rodigozeus/tetris/archive/refs/heads/master.zip"
TMP_DIR="/tmp/tetris_update"
PORTS_DIR="/storage/roms/ports"

msg() {
  dialog --infobox "$1" 6 50
}

msg "Baixando atualização..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

wget -q "$REPO_URL" -O "$TMP_DIR/update.zip"
if [ $? -ne 0 ]; then
  dialog --msgbox "Erro ao baixar.\nVerifique a conexão." 6 50
  exit 1
fi

msg "Extraindo arquivos..."
unzip -q "$TMP_DIR/update.zip" -d "$TMP_DIR"

msg "Instalando..."
cp -r "$TMP_DIR/tetris-master/"* "$PORTS_DIR/"

msg "Limpando arquivos temporários..."
rm -rf "$TMP_DIR"

dialog --msgbox "Atualização concluída!" 6 50
