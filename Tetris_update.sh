#!/bin/bash

REPO_URL="https://github.com/rodigozeus/tetris/archive/refs/heads/master.zip"
TMP_DIR="/tmp/tetris_update"
PORTS_DIR="/storage/roms/ports"

echo "Baixando atualização..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

wget -q "$REPO_URL" -O "$TMP_DIR/update.zip"
if [ $? -ne 0 ]; then
  echo "Erro ao baixar. Verifique a conexão."
  exit 1
fi

echo "Extraindo..."
unzip -q "$TMP_DIR/update.zip" -d "$TMP_DIR"

echo "Instalando..."
cp -r "$TMP_DIR/tetris-master/"* "$PORTS_DIR/"

echo "Limpando..."
rm -rf "$TMP_DIR"

echo "Atualização concluída!"
