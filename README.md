# Games — Anbernic RG DS

Jogos feitos em **Love2D (Lua)**, rodando num **Anbernic RG DS** com **Rocknix**. Desenvolvidos no PC com VS Code + Claude Code, transferidos pro console via SCP e lançados pelo menu **Ports** do EmulationStation.

---

## O Console

| | |
|---|---|
| **Hardware** | Anbernic RG DS |
| **Sistema** | Rocknix (Linux aarch64) |
| **Telas** | Dual screen — 2× 640×480 |
| **Engine** | Love2D 11.5 |
| **Acesso** | SSH / SCP via rede local |

---

## Jogos

### Snake
> O clássico. Come, cresce, morre, tenta de novo.

- Grade 32×22, célula de 20px
- Velocidade progressiva a cada comida
- **Recorde salvo** em disco entre sessões
- **Graça de colisão** — 0,5 s para mudar de direção e evitar a morte; mudar direção imediatamente retoma o jogo sem esperar
- **Turbo** — segurar A ou B dobra a velocidade enquanto pressionado
- Áudio procedural gerado em Lua (chirp de acerto, queda grave ao morrer, bip de pause)

**Controles:** D-pad para mover · A / B (segurar) para turbo · Start para pausar · B para novo jogo · Select/Back para sair

---

### Tetris
> Tetris completo com tudo que um Tetris precisa ter.

- 7 peças com cores canônicas (I, O, T, S, Z, J, L)
- **T-Spin** reconhecido e pontuado
- **DAS** (Delayed Auto Shift) — pressionar e segurar desloca suavemente
- **Lock Delay** — a peça não trava imediatamente ao tocar o chão
- Velocidade aumenta por nível seguindo a curva clássica do NES
- Sistema de **nome no placar** (tela de entrada de caracteres com D-pad)
- Prévia da próxima peça

**Controles:** D-pad para mover/descer · A/B/Cima para girar · Start para pausar

---

### Lê Comigo!
> Jogo educativo cooperativo de leitura de sílabas para crianças em alfabetização.

Pensado para ser jogado **em dupla**: a criança lê a sílaba em voz alta, o adulto avalia e pressiona o botão. Sem timer, sem tela de "ERROU!" — quem decide é o adulto, em conversa.

- Exibe uma sílaba por vez em letras grandes
- **Combo** — acertos consecutivos multiplicam os pontos
- **Celebração** a cada 5 acertos seguidos: confetes, animação e mensagem
- Recorde salvo automaticamente
- **Configurações** (menu pause → Start):
  - Ativar/desativar grupos de consoantes — útil pra focar na letra que está sendo estudada
  - Resetar recorde (com confirmação)
- Cobre todas as combinações consoante + vogal do Português (BA BE BI… até ZU)

| Ação | Botão (adulto) |
|------|----------------|
| Acertou | R1 · A · D-pad direita/cima |
| Tenta de novo | L1 · B · D-pad esquerda/baixo |

---

### Picross
> Nonograma com revelação progressiva de imagem em dual screen.

- **Tela superior** mostra a imagem que vai sendo revelada conforme você acerta células
- **Tela inferior** exibe a grade com dicas de linhas e colunas — interação por touch
- Dicas ficam **verdes** quando a linha ou coluna está corretamente resolvida
- Dois modos de marcação selecionáveis por botão: **Preencher** e **Marcar X**
- Arrastar o dedo preenche/apaga várias células de uma vez
- Puzzles em arquivos `.lua` individuais na pasta `puzzles/` — adicionar novos não requer alterar o código

**Controles:** Touch na tela inferior · Start: próximo puzzle · Select: sair

---

### Touch Test
> Utilitário para validar o funcionamento das duas telas e do touch.

- Janela de **1280×480** cobrindo DSI-2 (tela de cima) e DSI-1 (tela de baixo)
- Dois botões interativos, um em cada tela — mudam de cor ao toque
- Exibe as coordenadas brutas do toque em tempo real
- Usa Wayland (swaymsg) para ligar DSI-1 e posicionar a janela em (0, 0)

---

### Update
> Atualizador de jogos direto do console.

- Baixa o repositório do GitHub como `.zip` via `wget`
- Extrai e instala os arquivos em `/storage/roms/ports/`
- Interface com progresso em etapas (Conectando → Baixando → Extraindo → Instalando → Finalizando)
- Spinner animado, ícones de check/erro, fecha automaticamente após 5 s de sucesso

---

## Estrutura do Repositório

```
games/
├── snake/          main.lua + conf.lua
├── tetris/         main.lua + conf.lua
├── le_comigo/      main.lua + conf.lua
├── touchtest/      main.lua + conf.lua
├── update/         main.lua + conf.lua
├── picross/        main.lua + conf.lua
│   └── puzzles/    ← arquivos .lua com os puzzles (um por arquivo)
├── Snake.sh        ← script de lançamento no console
├── Tetris.sh
├── LeComigo.sh
├── TouchTest.sh
├── Update.sh
├── Picross.sh
└── SETUP.md        ← documentação técnica completa do ambiente
```

---

## Como Rodar no Console

Cada jogo tem um script `.sh` que aparece no menu Ports do EmulationStation:

```bash
# Jogo simples (tela única)
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/snake

# Jogo dual screen (TouchTest)
swaymsg 'output DSI-1 power on'
SDL_VIDEODRIVER=wayland \
LD_LIBRARY_PATH=/storage/roms/ports/moonlightnew/libs \
  /storage/roms/ports/moonlightnew/love \
  /storage/roms/ports/touchtest &
LOVE_PID=$!
sleep 1
swaymsg '[title="Touch Test"] floating enable, border none, move absolute position 0 0'
wait $LOVE_PID
swaymsg 'output DSI-1 power off'
```

Para enviar um jogo atualizado ao console:

```bash
scp main.lua root@<IP_DO_CONSOLE>:/storage/roms/ports/snake/main.lua
```

Senha SSH padrão do Rocknix: `rocknix`

---

## Documentação Técnica

Ver [SETUP.md](SETUP.md) para:
- Mapeamento completo de botões (gamepad + teclado)
- Como funciona o dual screen no Wayland (DSI-1 / DSI-2)
- Coordenadas de touch nas duas telas
- Fluxo completo do desenvolvimento ao console
- Template base de `main.lua` e `conf.lua`
