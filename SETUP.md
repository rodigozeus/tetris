# Ambiente de Desenvolvimento de Jogos

## Contexto

Desenvolvemos jogos em **Love2D (Lua)** para rodar em um **Anbernic RG DS** com **Rocknix** (Linux ARM aarch64). O desenvolvimento acontece no PC com VS Code + Claude Code. O jogo é transferido para o console via SCP e executado pelo menu **Ports** do EmulationStation.

---

## Dispositivo

| Item | Detalhe |
|------|---------|
| Console | Anbernic RG DS |
| Sistema | Rocknix (Linux aarch64) |
| Resolução | 640x480 |
| Conexão | SSH / SCP via rede local |
| Usuário SSH | `root` |
| IP | `192.168.68.111` (reservado no roteador, fixo) |

### Acesso SSH

Desde 2026-09-22 o acesso é **por chave**, não por senha — mais rápido e não depende de lembrar/adivinhar credencial:

| Chave | De onde | Uso |
|-------|---------|-----|
| `~/.ssh/id_ed25519` (`rodig@windows`) | Este PC | Acesso direto do PC de desenvolvimento |
| `~/.ssh/rgds_console` (no damaceno) | Servidor `damaceno` | Backup automático (cron), ver [backup_rgds.md](backup_rgds.md) |

Ambas já estão em `/root/.ssh/authorized_keys` no console. `ssh root@192.168.68.111` direto, sem senha.

> A senha `rocknix` documentada em versões antigas deste arquivo **não bateu** quando testada em 2026-09-22 (nem `rocknix` nem `root`/`root` funcionaram) — pode ter mudado numa reinstalação, ou nunca ter sido essa. Não gastar tempo tentando adivinhar: usar a chave SSH acima, ou pedir pra rodar o comando de `authorized_keys` (ver [backup_rgds.md](backup_rgds.md)) se for um console/chave novos.

---

## Armazenamento

Desde a migração de 2026-09-22 ([instala_emmc.md](instala_emmc.md)), o Rocknix roda **inteiramente da eMMC interna** (~29GB) — sistema e dados, sem depender do cartão SD pra funcionar:

| Partição eMMC | Conteúdo | Filesystem |
|---------------|----------|------------|
| `ROCKNIX` (`/dev/mmcblk0p1`, ~2GB) | kernel, SYSTEM, device trees, extlinux | FAT32 |
| `STORAGE` (`/dev/mmcblk0p2`, ~27GB) | ROMs, saves, configs, ports — tudo que fica em `/storage/` | ext4 |

O cartão SD **não é necessário** pro uso normal — só serve como mídia de boot alternativa em caso de emergência (ver [instala_emmc.md](instala_emmc.md)). Estrutura em `/storage/`:

```
/storage/
├── roms/
│   ├── nds/      ← ROMs de NDS
│   └── snes/     ← ROMs de SNES
├── ports/        ← Jogos Love2D (este repo) + PortMaster
└── .config/      ← Configs (retroarch, drastic, emulationstation...)
```

Para adicionar ROMs ou saves: `scp` direto pro caminho correspondente em `/storage/` (ver [Onde estão os ROMs](#onde-estão-os-roms) abaixo). Backup automático desse `/storage` inteiro a cada 15min — ver [backup_rgds.md](backup_rgds.md).

---

## Onde estão os ROMs

Duas pastas parecidas, propósitos diferentes — fácil de confundir:

| Pasta | O que é | Tamanho |
|-------|---------|---------|
| `games/roms/` (neste repo, gitignored) | Subconjunto do que já foi levado pro console + mídia de scraper (capas, manuais, vídeos) pro EmulationStation. **Não é a fonte pra achar ROM nova.** | 27 `.nds` |
| `C:\Users\rodig\OneDrive\Roms - Retrô\` | Biblioteca completa, organizada por sistema/idioma (ex: `Nintendo DS\PT-BR\`). **É aqui que se procura uma ROM que ainda não está no console.** | 290 `.nds` só de NDS |

Exemplo real (2026-09-22): a ROM patched do Zelda PH (`Zelda_PH_PTBR_Dpad_Final.nds`, ver [Zelda_PH.md](Zelda_PH.md)) não estava em nenhum dos dois lugares "óbvios" do console nem do `games/roms/` — estava em `Roms - Retrô\Nintendo DS\PT-BR\`. Procurar lá primeiro quando uma ROM "sumir" depois de uma reinstalação.

---

## Love2D no Console

> ⚠️ O Love2D **não sobrevive a uma reinstalação do Rocknix** (reinstala/clona a eMMC do zero, restaura Android, etc.) — ele é uma dependência do port "moonlightnew" do PortMaster, não faz parte do sistema base. Depois de qualquer reinstalação, conferir se existe antes de tentar rodar os jogos deste repo (ver [checklist abaixo](#checklist-pós-reinstalação-de-osemmc)).

O binário do Love2D, quando instalado, fica como dependência do port "moonlightnew":

| Arquivo | Caminho |
|---------|---------|
| Binário | `/storage/roms/ports/moonlightnew/love` |
| Bibliotecas | `/storage/roms/ports/moonlightnew/libs/` |
| Versão | Love2D 11.5 |

Para rodar qualquer jogo é necessário definir o `LD_LIBRARY_PATH` apontando para a pasta de libs.

---

## Estrutura de um Jogo

Cada jogo tem sua própria pasta em `/storage/roms/ports/` e um script `.sh` de lançamento:

```
/storage/roms/ports/
├── MeuJogo.sh          ← script que aparece no menu Ports
└── meujogo/
    ├── main.lua        ← lógica do jogo
    └── conf.lua        ← configurações de janela
```

### conf.lua (padrão para todos os jogos)

```lua
function love.conf(t)
  t.window.title      = "Nome do Jogo"
  t.window.width      = 640
  t.window.height     = 480
  t.window.fullscreen = true
end
```

### MeuJogo.sh (script de lançamento)

```bash
#!/bin/bash
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/meujogo
```

---

## Mapeamento de Botões (Love2D)

Dispositivo detectado: **retrogame_joypad** (via KeyMapper).

Usar `love.gamepadpressed(_, button)` para botões digitais e `love.gamepadaxis(_, axis, value)` para gatilhos/analógicos:

| Botão físico       | Nome no Love2D        | Tipo |
|--------------------|-----------------------|------|
| D-pad cima         | `"dpup"`              | button |
| D-pad baixo        | `"dpdown"`            | button |
| D-pad esquerda     | `"dpleft"`            | button |
| D-pad direita      | `"dpright"`           | button |
| Botão A            | `"b"`                 | button |
| Botão B            | `"a"`                 | button |
| Botão X            | `"x"`                 | button |
| Botão Y            | `"y"`                 | button |
| Start              | `"start"`             | button |
| Select / Back      | `"back"`              | button |
| L1 (ombro esq.)    | `"leftshoulder"`      | button |
| L2 (gatilho esq.)  | `"triggerleft"`       | axis (gamepadaxis) |
| R1 (ombro dir.)    | `"rightshoulder"`     | button |
| R2 (gatilho dir.)  | `"triggerright"`      | axis (gamepadaxis) |
| Analógico esq. (click) | `"leftstick"`     | button |
| Analógico esq. X   | `"leftx"`             | axis |
| Analógico esq. Y   | `"lefty"`             | axis |
| Analógico dir. (click) | `"rightstick"`    | button |
| Analógico dir. X   | `"rightx"`            | axis |
| Analógico dir. Y   | `"righty"`            | axis |

> **Atenção:** A e B estão **invertidos** em relação ao que o nome sugere — o botão físico A reporta `"b"` e vice-versa.

> **L2/R2** chegam como eixo analógico, não como botão. Usar `love.gamepadaxis(_, axis, value)` com `axis == "triggerleft"` / `"triggerright"` e `value > 0.5`.

> **lstick_x** e **rstick_y** foram capturados com o mesmo eixo duas vezes no KeyMapper — os nomes acima (`"leftx"` / `"righty"`) são os valores padrão corretos do Love2D.

Para testes no PC usar também `love.keypressed(key)` com as teclas do teclado.

---

## Fluxo Completo: Do Código ao Console

### 1. Criar o jogo no PC

Arquivos ficam em:
```
C:/Users/rodig/OneDrive/Projetos/games/nome_do_jogo/
├── main.lua
└── conf.lua
```

### 2. Criar a estrutura no console (primeira vez)

Via SSH:
```bash
ssh root@<IP_DO_CONSOLE>
mkdir -p /storage/roms/ports/meujogo
cat > /storage/roms/ports/MeuJogo.sh << 'EOF'
#!/bin/bash
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs /storage/roms/ports/moonlightnew/love /storage/roms/ports/meujogo
EOF
chmod +x /storage/roms/ports/MeuJogo.sh
```

### 3. Transferir os arquivos Lua

```bash
scp main.lua  root@<IP>:/storage/roms/ports/meujogo/main.lua
scp conf.lua  root@<IP>:/storage/roms/ports/meujogo/conf.lua
```

> Dica: para atualizações basta repetir o SCP do `main.lua`. O `conf.lua` raramente muda.

### 4. Atualizar a lista de jogos no console

No EmulationStation: **Start → Update Games List**

O jogo aparece em **Ports**.

---

## Estrutura Base do main.lua

```lua
-- Variáveis globais de estado aqui

function love.load()
  -- inicialização: fontes, variáveis, assets
end

function love.update(dt)
  -- lógica por frame (dt = delta time em segundos)
end

function love.draw()
  -- renderização
end

function love.gamepadpressed(_, button)
  -- input do console
end

function love.keypressed(key)
  -- input do teclado (testes no PC)
end
```

---

## Jogos Criados

| Jogo | Pasta | Script | Telas | Descrição |
|------|-------|--------|-------|-----------|
| Snake          | `snake/`          | `Snake.sh`          | 1 | Snake com velocidade progressiva e recorde persistente |
| Tetris         | `tetris/`         | `Tetris.sh`         | 1 | Tetris clássico com níveis, score e multi-user |
| Lê Comigo      | `le_comigo/`      | `LeComigo.sh`       | 1 | Jogo educativo cooperativo de leitura de sílabas |
| Lê e Vence     | `le_vence/`       | `Gustavo.sh`        | 2 | Jogo educativo de leitura e compreensão com múltipla escolha |
| Zelda PH Saves | `zelda_ph_saves/` | `Zelda_PH_Saves.sh` | 2 | Gerenciador de saves sancionados para Zelda PH |
| Update         | `update/`         | `Update.sh`         | 2 | Utilitário de atualização de jogos via GitHub (dual screen) |
| TouchTest      | `touchtest/`      | `TouchTest.sh`      | 2 | Utilitário de dev para testar touch nas duas telas |

---

## Dual Screen e Touch

O Anbernic RG DS tem duas telas de **640x480** cada, gerenciadas pelo Wayland (Sway) como dois outputs DSI separados:

| Output | Posição Wayland | Tela física |
|--------|----------------|-------------|
| DSI-2  | x=0, y=0       | Tela de cima |
| DSI-1  | x=640, y=0     | Tela de baixo |

O espaço virtual total é **1280x480**. DSI-1 fica **desligado por padrão** (o EmulationStation o desliga ao iniciar).

### Como usar as duas telas num jogo

**conf.lua:**
```lua
function love.conf(t)
  t.window.width      = 1280   -- cobre os dois outputs
  t.window.height     = 480
  t.window.fullscreen = false
  t.window.borderless = true
  t.window.x          = 0
  t.window.y          = 0
end
```

**Script de lançamento (.sh):**
```bash
#!/bin/bash
swaymsg 'output DSI-1 power on'

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/meujogo &

LOVE_PID=$!
sleep 1
swaymsg '[title="Título do Jogo"] floating enable, border none, move absolute position 0 0'

wait $LOVE_PID
swaymsg 'output DSI-1 power off'
```

> O `sleep 1` + `swaymsg` é necessário porque o Sway centraliza janelas floating no output ativo (DSI-2), deslocando a janela de 1280px em -320px. O swaymsg força a posição (0,0) depois que a janela abre.

### ⚠️ Bug: input trava depois de fechar um jogo dual screen

**Sintoma:** o jogo abre e roda normal. Ao fechar (`love.event.quit()`, ex. botão Select/Back), a tela de baixo desliga, a tela de cima mostra o EmulationStation (ou fica preta) — mas os botões **não respondem mais**. Às vezes reaparece depois de alguns segundos, às vezes nunca.

**Causa:** quando a janela floating do jogo (que ocupa os dois outputs, `DSI-2`+`DSI-1`) fecha, o Sway às vezes não devolve o foco pro EmulationStation de forma confiável — o foco fica preso no workspace vazio da tela de baixo, ou a própria janela do ES é reparentada pro workspace errado. É uma corrida assíncrona entre o Sway processando o fechamento e qualquer tentativa de restaurar foco manualmente (`swaymsg focus`, `swaymsg move to workspace`) — tentamos várias combinações (trap, sleep, retries) e nenhuma foi 100% confiável.

**O que resolve de verdade:** reiniciar o serviço systemd do EmulationStation, não remendar o estado do Sway na mão:
```bash
systemctl restart essway.service
```
Isso reresseta o ES (SDL, foco de input, tudo) do zero em ~2s — visivelmente mais devagar que um "volta e já era", mas **confiável** em todos os testes, ao contrário das tentativas de restaurar foco manualmente.

**Padrão usado em todo script dual screen** (`Gustavo.sh`, `Update.sh`, `Zelda_PH_Saves.sh`): um "vigia" desacoplado via `setsid` que espera o `love` terminar e então reinicia o serviço — sobrevive mesmo se o script principal for morto junto com o jogo:
```bash
#!/bin/bash
swaymsg 'output DSI-1 power on' 2>/dev/null

SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/meujogo &

LOVE_PID=$!
sleep 1
swaymsg '[title="Título do Jogo"] floating enable, border none, move absolute position 0 0' 2>/dev/null

setsid bash -c "
  while kill -0 $LOVE_PID 2>/dev/null; do sleep 0.2; done
  swaymsg 'output DSI-1 power off' 2>/dev/null
  systemctl restart essway.service 2>/dev/null
" < /dev/null > /dev/null 2>&1 &
disown

wait $LOVE_PID
```

> `essway.service` é o unit systemd que roda `start_es.sh` (EmulationStation) com `Restart=always` — confirmar com `systemctl cat essway.service`.

> **STARTUP_DELAY:** mesmo com o swaymsg, a janela já renderiza deslocada durante o primeiro segundo. A solução é fazer o `love.draw()` pintar tela preta enquanto o timer não expirar, evitando o flash deslocado. Um delay de **0,3 s** já é suficiente e não prejudica a experiência:
> ```lua
> local startup_timer = 0
> local STARTUP_DELAY = 0.3
>
> function love.update(dt)
>   startup_timer = startup_timer + dt
>   if startup_timer < STARTUP_DELAY then return end
>   -- lógica normal...
> end
>
> function love.draw()
>   if startup_timer < STARTUP_DELAY then
>     love.graphics.clear(0, 0, 0)
>     return
>   end
>   -- desenho normal...
> end
> ```

### Coordenadas no main.lua

```
Tela de cima (DSI-2): x = 0  .. 639  →  centro x = 320
Tela de baixo (DSI-1): x = 640 .. 1279 →  centro x = 960
```

### Touch

- Touch funciona nas **duas telas**
- Coordenadas chegam em `love.touchpressed(id, x, y)` no espaço da janela (0..1279)
- Tela de cima: x = 0..639 | Tela de baixo: x = 640..1279

---

## DraStic — Emulação de NDS

O DraStic é lançado pelo Rocknix via `/usr/bin/start_drastic.sh <rom>`, que configura variáveis de ambiente e usa `LD_PRELOAD=/usr/lib/libdrastouch.so` para gerenciar as duas telas e o touch no RG DS.

### Arquitetura do DraStic no RG DS

- O DraStic renderiza **direto no framebuffer DRM/KMS**, ignorando o compositor Sway. Trocar posições de outputs via `swaymsg` não afeta o display.
- O `libdrastouch.so` lê os eventos de touch **direto do evdev**, ignorando o mapeamento de touch do Sway. Trocar `map_to_output` também não funciona.
- As duas touchscreens são dispositivos **Goodix Capacitive TouchScreen** com o mesmo identificador Sway (`1046:911:Goodix_Capacitive_TouchScreen`):
  - `event1` → `/devices/platform/fe5c0000.i2c/` → tela de cima (DSI-2)
  - `event2` → `/devices/platform/fe5e0000.i2c/` → tela de baixo (DSI-1)

### Configuração do DraStic

O config fica em `/storage/.config/drastic/config/drastic.cfg`. Parâmetros relevantes:

| Parâmetro | Valores | Descrição |
|-----------|---------|-----------|
| `screen_swap` | `0` / `1` | Troca visualmente as telas DS |
| `mirror_touch` | `0` / `1` | Faz o touch seguir o swap visual |

Para trocar as telas **com touch funcionando corretamente**, ambos devem ser `1` juntos. Ativar só `screen_swap` troca o display mas o touch continua na tela de baixo.

### Lançar um jogo DS com telas trocadas

Criar um script em `/storage/roms/ports/NomeDoJogo.sh` que ativa as opções antes de abrir e restaura ao sair:

```bash
#!/bin/bash
CFG=/storage/.config/drastic/config/drastic.cfg

sed -i 's/^screen_swap = .*/screen_swap = 1/' "$CFG"
sed -i 's/^mirror_touch = .*/mirror_touch = 1/' "$CFG"

/usr/bin/start_drastic.sh "/storage/roms/nds/NomeDoJogo.nds"

sed -i 's/^screen_swap = .*/screen_swap = 0/' "$CFG"
sed -i 's/^mirror_touch = .*/mirror_touch = 0/' "$CFG"
```

O jogo aparece em **Ports** no EmulationStation após **Start → Update Games List**.

### Microfone em jogos NDS

O `libdrastouch.so` implementa captura de microfone real via SDL + PipeWire. Requer duas configurações:

**1. Threshold de sensibilidade** (persiste entre boots):
```bash
set_setting 'nds.microphone_sensitivity' 0.1
```
O valor é float normalizado (0.0–1.0). Valores inteiros como `30` nunca disparam — o RMS do áudio float nunca ultrapassa 1.0. Válido para todos os jogos NDS.

**2. Default source do PipeWire** (necessário a cada boot):

Por padrão o PipeWire aponta o source de captura para o monitor do speaker, não para o microfone. Corrigir antes de abrir o DraStic:
```bash
pactl set-default-source alsa_input._sys_devices_platform_sound_sound_card0.HiFi__Mic__source
```

Incluir esse comando no script `.sh` de lançamento de qualquer jogo NDS que use microfone (ver [`Zelda_PH.sh`](Zelda_PH.sh) como referência).

> Não é necessário mexer nos outputs do Sway — o DraStic gerencia suas próprias telas via SDL + libdrastouch.so.

### Zelda PH — Workaround das velas

O detector de sopro de vela em Zelda: Phantom Hourglass requer uma forma de onda contínua de baixa frequência que o microfone do RG DS não consegue reproduzir de forma confiável.

**Solução adotada:** saves sancionados gerenciados pelo app `zelda_ph_saves` ([Zelda_PH_Saves.sh](Zelda_PH_Saves.sh)).

- A pasta `Sanctioned Saves/` no repositório contém saves `.dsv` tirados logo após cada cena de vela
- O app permite aplicar qualquer save com backup automático do save atual
- No console, os saves ficam em `/storage/roms/ports/Sanctioned Saves/`

---

## Rocknix — Downloads e Atualizações

O RG DS só tem suporte nas **nightly builds** do Rocknix (versões estáveis no GitHub não incluem o dispositivo).

| Tipo | URL |
|------|-----|
| Releases estáveis | [github.com/ROCKNIX/distribution/releases](https://github.com/ROCKNIX/distribution/releases) |
| Nightly builds | [github.com/ROCKNIX/distribution-nightly/releases](https://github.com/ROCKNIX/distribution-nightly/releases) |

Para o RG DS baixar: **`ROCKNIX-RK3566.aarch64-<DATA>-Specific.img.gz`**

O servidor de atualização automática (`update.rocknix.org`) **não lista as nightly builds de 2026** — para downgrade manual, usar o GitHub acima.

---

## Acesso SSH Programático

### Via chave (preferido desde 2026-09-22)

Com a chave SSH já instalada no console (ver [Acesso SSH](#acesso-ssh) acima), `ssh`/`scp` direto do Git Bash funcionam sem senha nem paramiko:

```bash
ssh root@192.168.68.111 "comando aqui"
scp arquivo_local.sh root@192.168.68.111:/storage/roms/ports/arquivo_local.sh
```

Isso resolve o problema original que motivou o paramiko (SSH interativo com senha não funciona bem em automações, sem `sshpass` no Windows) — sem depender de senha, o Git Bash já basta.

### Via Python + Paramiko (alternativa, se precisar de senha)

Útil se algum dia o acesso por chave não estiver disponível (console novo, chave não copiada ainda) e for preciso usar senha em vez disso.

### Instalação

```bash
pip install paramiko
```

### Padrão de uso

Criar um script temporário `_cmd.py` na raiz do projeto e rodar com o Python do Anaconda:

```python
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('<IP_DO_CONSOLE>', username='root', password='rocknix', timeout=10)

# Executar comando
_, stdout, stderr = ssh.exec_command('comando aqui', timeout=30)
print(stdout.read().decode())

# Transferir arquivo (SFTP)
sftp = ssh.open_sftp()
sftp.put('arquivo_local.sh', '/storage/roms/ports/arquivo_local.sh')
sftp.close()

ssh.close()
```

Rodar via PowerShell:
```powershell
& "C:\Users\rodig\anaconda3\python.exe" _cmd.py
```

### Transferência de arquivos grandes

Para arquivos grandes (ex: imagem `.img.gz`) com barra de progresso:

```python
import paramiko, os, time

def progress(sent, total):
    pct = sent / total * 100
    speed = sent / (time.time() - start) / 1024 / 1024
    print(f'\r{pct:.1f}%  {sent//1024//1024}/{total//1024//1024} MB  {speed:.1f} MB/s', end='')

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('<IP>', username='root', password='rocknix', timeout=10)
start = time.time()
sftp = ssh.open_sftp()
sftp.put('releases/ROCKNIX-RK3566.aarch64-20260409-Specific.img.gz',
         '/storage/ROCKNIX-RK3566.aarch64-20260409-Specific.img.gz',
         callback=progress)
sftp.close()
ssh.close()
```

### Notas

- `exec_command` com timeout curto pode dar `TimeoutError` em comandos longos — use timeout adequado ou rode com `&` em background e monitore separadamente
- Para comandos que demoram (ex: `dd`), rodar em background e checar `/proc/diskstats` ou um arquivo de log para monitorar progresso
- O `dd` do BusyBox não suporta `status=progress` — usar `/proc/diskstats` para estimar bytes escritos:
  ```bash
  grep 'mmcblk0 ' /proc/diskstats | awk '{print $10 * 512 / 1024 / 1024 " MB escritos"}'
  ```

---

## Checklist pós-reinstalação de OS/eMMC

Toda vez que o Rocknix é reinstalado, clonado ou a eMMC é trocada (ver [instala_emmc.md](instala_emmc.md)), o que volta "de graça" (estava no `/storage` clonado) e o que **não** volta:

| Item | Volta sozinho? | Como verificar / recriar |
|------|-----------------|---------------------------|
| Configs, saves, ROMs já existentes | ✅ se clonado do `/storage` de uma instalação anterior | — |
| **Love2D (runtime "moonlightnew")** | ❌ nunca | `ls /storage/roms/ports/moonlightnew/love` — se faltar, instalar com `harbourmaster install moonlightnew.zip` (PortMaster) |
| **Jogos deste repo** (Snake, Tetris, Lê Comigo, Lê e Vence, Zelda PH Saves, Update, TouchTest) | ✅ se estavam no `/storage` clonado, ❌ se a instalação é "do zero" | `ls /storage/roms/ports/*.sh` — se faltar, resubir (ver seção "Como Rodar no Console" no [README.md](README.md)) |
| **ROM do Zelda PH** (`Zelda_PH_PTBR_Dpad_Final.nds`) | Igual acima | `ls /storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.nds` — se faltar, está em `Roms - Retrô\Nintendo DS\PT-BR\` (ver [Onde estão os ROMs](#onde-estão-os-roms)) |
| **Backup automático** (cron no damaceno) | ✅ — não depende do console, só do IP dele | Confirmar que o IP do console não mudou (`192.168.68.111`, reservado no roteador); ver [backup_rgds.md](backup_rgds.md) |
| Chaves SSH (`authorized_keys`) | ✅ se clonado do `/storage`, ❌ se `/root/.ssh` não é persistido em `/storage` nesse Rocknix | `cat ~/.ssh/authorized_keys` no console — se vazio, seguir [Acesso SSH](#acesso-ssh) |

> Regra prática: **`/storage` é o que sobrevive** a uma reinstalação (se for clonado, como em [instala_emmc.md](instala_emmc.md)); qualquer coisa que vive **fora** de `/storage` (binários de sistema, runtime do Love2D, `/root/.ssh` dependendo da versão) precisa ser reconferida.

---

## Notas

- O console fica acessível via SSH enquanto estiver na mesma rede Wi-Fi
- Descobrir o IP do console: EmulationStation → **Main Menu → Network Settings**
- Não há necessidade de reiniciar o console para testar atualizações — basta sair do jogo e abrir de novo pelo menu
