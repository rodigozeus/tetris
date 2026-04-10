#!/bin/bash
swaymsg 'output DSI-1 power on'

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/update &

LOVE_PID=$!
sleep 1
swaymsg '[title="Atualizar Jogos"] floating enable, border none, move absolute position 0 0'

wait $LOVE_PID
swaymsg 'output DSI-1 power off'
