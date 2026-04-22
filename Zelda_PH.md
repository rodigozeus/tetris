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

## Seções do jogo que usam microfone

### Funciona com fake mic (botão)
- Chamar Astrid antes de entrar no Templo do Fogo
- Gritar para Eddo (braço de salvamento)
- Atordoar Pols Voice no Templo da Coragem
- Gritar para o jovem Goron na Ilha Goron
- Obter o baú de rúpia dourada na Ilha Dee Ess

### NÃO funciona — requer sopro real (detecção complexa de forma de onda)
- **Velas na Ilha do Ember** (para acessar o Templo do Fogo)
- **Velas no Templo do Fogo 3F**
- **Cataventos na Ilha de Gust** (para acessar o Templo do Vento)
- **Limpar poeira do mapa do Mar do Noroeste**

> Fonte: [RetroAchievements — Phantom Hourglass mic documentation](https://retroachievements.org/viewtopic.php?t=9847)

### Workaround: saves sancionados

O RetroAchievements disponibiliza saves posicionados logo após cada seção problemática:  
**[Phantom_Hourglass_RA_Sanctioned_Saves.7z](https://www.mediafire.com/file/0unap6povyukb5i/Phantom_Hourglass_RA_Sanctioned_Saves.7z/file)**

Para usar no DraStic:
1. Fazer backup do save atual: `cp /storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.dsv /storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.dsv.bak`
2. Transferir o save sancionado via SCP do PC para o console: `scp "Sanctioned Saves/00 - ....dsv" root@<IP>:/storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.dsv`
3. Abrir o jogo — ele carrega já passado da seção problemática
4. Continuar jogando normalmente a partir dali

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

#### Arquitetura completa

- **Hardware**: `card 0: rk817ext`, device de captura `pcmC0D0c` (48000Hz, stereo, S32LE)
- **Stack de áudio**: PipeWire (com compatibilidade PulseAudio via `pipewire-pulse`)
- **SDL**: usa backend `pulseaudio` → PipeWire → hardware
- **lib**: `libdrastouch.so` abre captura via `SDL_OpenAudioDevice`, computa RMS com `sqrtf` e compara com o threshold

#### Problema de roteamento do PipeWire

O PipeWire tem dois sources:
```
54  ...Speaker...monitor   ← monitor da saída (padrão incorreto)
55  ...Mic__source         ← microfone real
```

O default source aponta para o **monitor do speaker** (captura o que toca, não o mic). É necessário corrigir antes de abrir o DraStic. O script `Zelda_PH.sh` faz isso automaticamente.

#### Problema do threshold

`DSHOOK_MIC_THRESH` é convertido com `strtod` e comparado com o RMS do áudio em **float normalizado (escala 0.0 a 1.0)**. Valores como `30` são matematicamente impossíveis de atingir (máximo = 1.0) e nunca disparam. O valor correto fica entre `0.01` e `0.5`.

#### Configuração aplicada

```bash
# Threshold correto (float normalizado 0.0–1.0)
set_setting 'nds.microphone_sensitivity' 0.1

# Corrigir default source do PipeWire (feito pelo Zelda_PH.sh)
pactl set-default-source alsa_input._sys_devices_platform_sound_sound_card0.HiFi__Mic__source
```

Para ajustar sensibilidade se necessário:
```bash
set_setting 'nds.microphone_sensitivity' 0.05   # mais sensível
set_setting 'nds.microphone_sensitivity' 0.3    # menos sensível
```

> Esta configuração de threshold vale para **todos os jogos NDS** — resolve de vez qualquer jogo que use microfone.  
> O `pactl set-default-source` é necessário a cada boot — o `Zelda_PH.sh` já inclui isso, mas outros jogos NDS com mic precisarão do mesmo ajuste no script de lançamento.

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
