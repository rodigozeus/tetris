#!/bin/bash
MODEL=$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0')

if echo "$MODEL" | grep -qi "rg-ds"; then
  swaymsg 'output DSI-1 power on'
fi

LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/update

if echo "$MODEL" | grep -qi "rg-ds"; then
  swaymsg 'output DSI-1 power off'
fi
