# Zelda PH — Plano: Microfone Virtual para Sopro da Vela

Ideia: criar um sink virtual no PipeWire que reproduz um WAV de sopro em loop,
fazendo o DraStic "ouvir" sopro contínuo sem depender do mic real ou do fake mic.

---

## Por que pode funcionar

O mic real captura áudio e o DraStic recebe os dados — isso já foi confirmado
(o source fica `RUNNING` com o jogo aberto e o teste de mic do menu passa).
O problema é que o som captado pelo mic do RG DS não tem as características
de frequência que o detector de sopro da vela espera.

Com o mic virtual, controlamos exatamente o que o DraStic recebe: frequência,
amplitude e duração. Podemos ajustar o WAV até o detector aceitar.

---

## Passo a passo

### 1. Verificar dependências

```bash
which sox
which aplay
```

Se `sox` não estiver disponível:
```bash
# tentar instalar (Rocknix pode ter opkg ou similar)
opkg install sox
```

### 2. Gerar o WAV de sopro

Sopro real = ruído branco com energia concentrada em baixa frequência (80–300 Hz).

```bash
sox -n -r 48000 -c 2 /tmp/blow.wav synth 3 whitenoise band 80 300 vol 0.5
```

Parâmetros ajustáveis:
| Parâmetro | Valor inicial | O que muda |
|-----------|---------------|------------|
| `band 80 300` | 80–300 Hz | frequência do sopro (tentar 100–200, 50–400) |
| `vol 0.5` | 0.5 | volume/amplitude (tentar 0.3, 0.8, 1.0) |
| `synth 3` | 3 segundos | duração do loop |

Verificar o WAV gerado:
```bash
aplay /tmp/blow.wav
```

### 3. Criar o sink virtual no PipeWire

```bash
pactl load-module module-null-sink sink_name=blow_mic sink_properties=device.description=BlowMic
```

Confirmar que foi criado:
```bash
pactl list sinks short | grep blow
pactl list sources short | grep blow
```

Deve aparecer `blow_mic` (sink) e `blow_mic.monitor` (source).

### 4. Tocar o WAV em loop no sink virtual

```bash
aplay -D blow_mic --loop /tmp/blow.wav &
BLOW_PID=$!
echo "Blow PID: $BLOW_PID"
```

### 5. Apontar o DraStic para o mic virtual

```bash
pactl set-default-source blow_mic.monitor
```

### 6. Testar no jogo

Com o DraStic já aberto (e o source trocado), ir até a vela. O DraStic já está
capturando do `blow_mic.monitor` — se o WAV tiver as características certas,
a vela apaga.

### 7. Desativar após uso

```bash
# Matar o aplay em loop
kill $BLOW_PID

# Restaurar o mic real como source padrão
pactl set-default-source alsa_input._sys_devices_platform_sound_sound_card0.HiFi__Mic__source

# Remover o sink virtual
pactl unload-module module-null-sink
```

---

## Script completo: blow_candle.sh

Para facilitar, criar `/storage/roms/ports/blow_candle.sh`:

```bash
#!/bin/bash
# Ativa mic virtual com som de sopro para a cena da vela no Zelda PH.
# Uso: rodar via SSH antes de chegar na vela. Matar com Ctrl+C ou kill quando terminar.

SOX_ARGS="-n -r 48000 -c 2 /tmp/blow.wav synth 3 whitenoise band 80 300 vol 0.5"
MIC_SOURCE="alsa_input._sys_devices_platform_sound_sound_card0.HiFi__Mic__source"

echo "Gerando WAV de sopro..."
sox $SOX_ARGS

echo "Criando sink virtual..."
MODULE_ID=$(pactl load-module module-null-sink sink_name=blow_mic \
  sink_properties=device.description=BlowMic)

echo "Iniciando loop de sopro..."
aplay -D blow_mic --loop /tmp/blow.wav &
BLOW_PID=$!

echo "Apontando DraStic para mic virtual..."
pactl set-default-source blow_mic.monitor

echo "Mic virtual ativo. Vá até a vela e sopre."
echo "Pressione Enter para desativar."
read

kill $BLOW_PID 2>/dev/null
pactl set-default-source "$MIC_SOURCE"
pactl unload-module "$MODULE_ID"
echo "Mic virtual desativado. Mic real restaurado."
```

---

## Variações a tentar se não funcionar de primeira

| Tentativa | Ajuste |
|-----------|--------|
| 1 | `band 80 300 vol 0.5` (padrão) |
| 2 | `band 100 200 vol 0.8` (faixa mais estreita, mais alto) |
| 3 | `band 50 500 vol 0.3` (faixa mais ampla, mais suave) |
| 4 | `vol 1.0` (amplitude máxima) |
| 5 | Gravar sopro real: `arecord -D hw:0,0 -f S16_LE -r 48000 -c 2 -d 3 /tmp/blow.wav` |

A tentativa 5 usa um sopro real gravado do próprio mic do RG DS — pode ser que
o detector aceite melhor um sopro real gravado do que ruído sintético.

---

## Referências

- [Zelda_PH.md](Zelda_PH.md) — contexto geral do jogo e problema do mic
- [Zelda_PH.sh](Zelda_PH.sh) — script de lançamento (já inclui `pactl set-default-source`)
- [SETUP.md](SETUP.md) — documentação do DraStic e microfone NDS
