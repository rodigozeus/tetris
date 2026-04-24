#!/bin/bash
swaymsg 'output DSI-1 power on' 2>/dev/null

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/zelda_ph_saves &

LOVE_PID=$!
sleep 1
swaymsg '[title="Zelda PH · Saves"] floating enable, border none, move absolute position 0 0' 2>/dev/null

wait $LOVE_PID
swaymsg 'output DSI-1 power off' 2>/dev/null
