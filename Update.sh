#!/bin/bash
swaymsg 'output DSI-1 power on' 2>/dev/null

LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/update

swaymsg 'output DSI-1 power off' 2>/dev/null
