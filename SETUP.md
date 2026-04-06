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
C:/Users/rodig/OneDrive/Área de Trabalho/pico8/nome_do_jogo/
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
| Quiz      | `quiz_love/`  | `Quiz.sh`      | Quiz de múltipla escolha, 4 perguntas |
| Tetris    | `tetris/`     | `Tetris.sh`    | Tetris clássico com níveis e score |
| Snake     | `snake/`      | `Snake.sh`     | Snake com velocidade progressiva e recorde persistente |
| KeyMapper | `keymapper/`  | `KeyMapper.sh` | Utilitário para detectar e salvar o mapeamento de botões do gamepad |

---

## Notas

- O console fica acessível via SSH enquanto estiver na mesma rede Wi-Fi
- Descobrir o IP do console: EmulationStation → **Main Menu → Network Settings**
- Não há necessidade de reiniciar o console para testar atualizações — basta sair do jogo e abrir de novo pelo menu
