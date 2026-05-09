#!/bin/bash
swaymsg 'output DSI-1 power off' 2>/dev/null

LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/tetris &

LOVE_PID=$!
sleep 1
swaymsg '[app_id="love"] floating enable, border none, move absolute position 0 0' 2>/dev/null

wait $LOVE_PID
