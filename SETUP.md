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
| Senha SSH | `rocknix` |

---

## Armazenamento

O Rocknix está instalado na **eMMC interna** (~29GB). O SD card é dedicado exclusivamente a ROMs e saves, formatado em **FAT32** para acesso direto pelo Windows.

| Dispositivo | Conteúdo | Filesystem |
|-------------|----------|------------|
| eMMC (`/dev/mmcblk0`) | Sistema Rocknix | ext4 |
| SD card (`/dev/mmcblk1`) | ROMs, saves, configs | FAT32 |

O Rocknix auto-monta o SD card em `/storage/` na inicialização. Estrutura esperada na raiz do SD:

```
SD:/
├── roms/
│   ├── nds/      ← ROMs de NDS
│   └── snes/     ← ROMs de SNES
└── saves/        ← Saves flat (sem subpastas), ex: "Mario Kart DS.dsv"
```

Para adicionar ROMs: conectar o SD no PC e copiar para a pasta do sistema correspondente. Para adicionar saves: copiar os arquivos `.dsv` / `.sav` / `.srm` diretamente para `saves/`.

Ver [instala_emmc.md](instala_emmc.md) para detalhes da instalação na eMMC.

---

## Love2D no Console

O binário do Love2D **já está instalado** no console, instalado como dependência do port "moonlightnew":

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
C:/Users/rodig/OneDrive/Área de Trabalho/games/nome_do_jogo/
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

| Jogo | Pasta | Script | Descrição |
|------|-------|--------|-----------|
| Tetris     | `tetris/`     | `Tetris.sh`     | Tetris clássico com níveis e score |
| Snake      | `snake/`      | `Snake.sh`      | Snake com velocidade progressiva e recorde persistente |
| TouchTest  | `touchtest/`  | `TouchTest.sh`  | Teste de dual screen + touch nas duas telas |
| Lê Comigo  | `le_comigo/`  | `LeComigo.sh`   | Jogo educativo cooperativo de leitura de sílabas |
| Picross    | `picross/`    | `Picross.sh`    | Picross com revelação de imagem na tela superior e grade interativa na inferior (dual screen) |
| Update     | `update/`     | `Update.sh`     | Utilitário de atualização de jogos baixando o repositório do GitHub (dual screen) |

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

## Rocknix — Downloads e Atualizações

O RG DS só tem suporte nas **nightly builds** do Rocknix (versões estáveis no GitHub não incluem o dispositivo).

| Tipo | URL |
|------|-----|
| Releases estáveis | [github.com/ROCKNIX/distribution/releases](https://github.com/ROCKNIX/distribution/releases) |
| Nightly builds | [github.com/ROCKNIX/distribution-nightly/releases](https://github.com/ROCKNIX/distribution-nightly/releases) |

Para o RG DS baixar: **`ROCKNIX-RK3566.aarch64-<DATA>-Specific.img.gz`**

O servidor de atualização automática (`update.rocknix.org`) **não lista as nightly builds de 2026** — para downgrade manual, usar o GitHub acima.

---

## Notas

- O console fica acessível via SSH enquanto estiver na mesma rede Wi-Fi
- Descobrir o IP do console: EmulationStation → **Main Menu → Network Settings**
- Não há necessidade de reiniciar o console para testar atualizações — basta sair do jogo e abrir de novo pelo menu
