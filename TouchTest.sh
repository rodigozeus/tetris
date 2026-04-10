#!/bin/bash
swaymsg 'output DSI-1 power on'

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/touchtest &

LOVE_PID=$!

# Aguarda a janela abrir e a posiciona em (0,0) para cobrir os dois outputs
sleep 1
swaymsg '[title="Touch Test"] floating enable, border none, move absolute position 0 0'

wait $LOVE_PID
swaymsg 'output DSI-1 power off'
