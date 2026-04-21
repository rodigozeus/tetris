# Zelda: Phantom Hourglass — RG DS / DraStic

ROM: `Zelda_PH_PTBR_Dpad_Final.nds`  
Script de lançamento: [`Zelda_PH.sh`](Zelda_PH.sh) (em `/storage/roms/ports/`)

---

## Estado atual

| Item | Status |
|------|--------|
| Tradução pt-br | ✅ ROM já traduzida |
| Controle por botões/analógico | ✅ ROM patched (`Dpad_Final`) |
| Telas invertidas (Link em cima, mapa embaixo) | ✅ via `screen_swap = 1` + `mirror_touch = 1` no script |

> A Nintendo projetou o Phantom Hourglass com a movimentação na tela de toque inferior por causa das limitações de hardware do DS original — o touch só existia embaixo. No RG DS, com as telas trocadas, a experiência fica muito mais natural.

---

## Problema atual: microfone não funciona para soprar vela

### Contexto
Em determinado trecho do jogo é necessário **assoprar uma vela** — ação que usa o microfone do DS original. O hardware de microfone existe no Anbernic RG DS, mas o DraStic não está capturando o áudio.

### O que já foi tentado

**Fake Microphone (botão):** o DraStic tem `CONTROL_INDEX_FAKE_MICROPHONE` mapeado para um botão físico e ele funciona para ações simples de mic (ex: chamar um NPC). Porém, **não funciona para o sopro da vela**: o jogo faz uma leitura mais complexa da forma de onda (amplitude contínua), e o pulso digital do fake mic não passa nessa verificação.

```
controls_a[CONTROL_INDEX_FAKE_MICROPHONE] = 1036
controls_b[CONTROL_INDEX_FAKE_MICROPHONE] = 327
```

### Solução: microfone real via libdrastouch.so

O `libdrastouch.so` (a mesma lib que gerencia o touch no RG DS) **já tem suporte a microfone real implementado** via a função `mic_audio_callback`. O controle é feito pela variável de ambiente `DSHOOK_MIC_THRESH`, que o `start_drastic.sh` exporta com base na config do EmulationStation.

Hardware disponível: `card 0: rk817ext`, device de captura `pcmC0D0c`.

**Configuração aplicada:**

```bash
set_setting 'nds.microphone_sensitivity' 30
```

Isso escreve `nds.microphone_sensitivity=30` em `/storage/.config/system/configs/system.cfg`, fazendo `get_setting microphone_sensitivity "nds" "..."` retornar `30` para qualquer jogo NDS. O `start_drastic.sh` passa esse valor como `DSHOOK_MIC_THRESH=30` para a lib.

Para ajustar a sensibilidade se necessário (menor = mais sensível):

```bash
set_setting 'nds.microphone_sensitivity' 20   # mais sensível
set_setting 'nds.microphone_sensitivity' 50   # menos sensível
```

> Esta configuração vale para **todos os jogos NDS** — resolve de vez qualquer jogo que use microfone.

---

## Script de lançamento

```bash
#!/bin/bash
CFG=/storage/.config/drastic/config/drastic.cfg

sed -i 's/^screen_swap = .*/screen_swap = 1/' "$CFG"
sed -i 's/^mirror_touch = .*/mirror_touch = 1/' "$CFG"

/usr/bin/start_drastic.sh "/storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.nds"

sed -i 's/^screen_swap = .*/screen_swap = 0/' "$CFG"
sed -i 's/^mirror_touch = .*/mirror_touch = 0/' "$CFG"
```

> Se a solução do microfone exigir parâmetros extras no cfg, adicionar os `sed -i` correspondentes aqui, restaurando os valores originais após sair do jogo.

---

## Referências úteis

- Seção DraStic no [SETUP.md](SETUP.md#drastic--emulação-de-nds)
- Config do DraStic: `/storage/.config/drastic/config/drastic.cfg`
- Script de lançamento: `/storage/roms/ports/Zelda_PH.sh`
