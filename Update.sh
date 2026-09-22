#!/bin/bash
swaymsg 'output DSI-1 power on' 2>/dev/null

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/update &

LOVE_PID=$!
sleep 1
swaymsg '[title="Atualizar Jogos"] floating enable, border none, move absolute position 0 0' 2>/dev/null

# Vigia desacoplado (setsid = grupo de processo próprio): sobrevive mesmo se
# este script e o love forem mortos juntos. Reiniciar o essway.service é a
# forma confiável de voltar pro EmulationStation limpo — tentativas de
# restaurar foco/workspace do Sway na mão (workspace, focus, power off)
# funcionavam só às vezes; reiniciar o serviço sempre funcionou nos testes.
setsid bash -c "
  while kill -0 $LOVE_PID 2>/dev/null; do sleep 0.2; done
  swaymsg 'output DSI-1 power off' 2>/dev/null
  systemctl restart essway.service 2>/dev/null
" < /dev/null > /dev/null 2>&1 &
disown

wait $LOVE_PID
