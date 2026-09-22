#!/bin/bash
swaymsg 'output DSI-1 enable' 2>/dev/null
swaymsg 'output DSI-1 power on' 2>/dev/null

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/touchtest &

LOVE_PID=$!
sleep 1
swaymsg '[title="Touch Test"] floating enable, border none, move absolute position 0 0' 2>/dev/null

# Vigia desacoplado (setsid = grupo de processo próprio): sobrevive mesmo se
# este script e o love forem mortos juntos.
#
# O 'disable' é o que importa: este aparelho tem DOIS seats no Sway e o joypad
# está nos dois. Ao fechar o jogo, o seat1 fica preso no workspace vazio da
# DSI-1 e nenhum comando de 'focus' o alcança (comandos via IPC rodam só no
# seat0) — daí o input morto. Desabilitar o output destrói esse workspace e
# força o seat1 de volta pro EmulationStation. Ver SETUP.md.
setsid bash -c "
  while kill -0 $LOVE_PID 2>/dev/null; do sleep 0.2; done
  swaymsg 'output DSI-1 disable' 2>/dev/null
  swaymsg 'output DSI-1 enable' 2>/dev/null
  swaymsg 'output DSI-1 power off' 2>/dev/null
" < /dev/null > /dev/null 2>&1 &
disown

wait $LOVE_PID
