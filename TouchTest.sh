#!/bin/bash
# Liga a tela de baixo (DSI-1 fica desligada por padrão no Sway)
swaymsg 'output DSI-1 power on'

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/touchtest

# Desliga a tela de baixo ao sair (comportamento padrão do sistema)
swaymsg 'output DSI-1 power off'
