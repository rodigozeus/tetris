# Como Criar Novos Puzzles

## Onde colocar

Crie um arquivo `.lua` dentro da pasta `puzzles/`. O nome do arquivo vira a ordem de exibição (alfabética), então use prefixos numéricos se quiser controlar a sequência:

```
picross/puzzles/
├── 01_coracao.lua
├── 02_casa.lua
├── 03_cogumelo.lua
└── 04_meu_novo_puzzle.lua   ← seu novo puzzle aqui
```

O jogo detecta e carrega todos os `.lua` da pasta automaticamente. Não é preciso alterar nenhum outro arquivo.

---

## Formato do arquivo

```lua
return {
  name  = "Nome do Puzzle",
  color = { R, G, B },
  sol   = {
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
    { 0,0,0,0,0,0,0,0,0,0 },
  },
}
```

| Campo   | Descrição |
|---------|-----------|
| `name`  | Nome exibido no jogo |
| `color` | Cor dos pixels revelados na tela superior, em RGB de 0.0 a 1.0 |
| `sol`   | Grid 10×10 — `1` = célula preenchida, `0` = vazia |

---

## Como desenhar o pixel art

O grid tem **10 colunas × 10 linhas**. Cada `1` é um pixel preenchido; cada `0` é vazio.

Dica: desenhe em papel quadriculado ou numa ferramenta online como o **Piskel** (piskelapp.com) com canvas 10×10, depois transcreva linha a linha.

### Exemplo — Estrela

```
  1 2 3 4 5 6 7 8 9 10
1 { 0,0,0,0,1,0,0,0,0,0 }
2 { 0,0,0,1,1,1,0,0,0,0 }
3 { 1,1,1,1,1,1,1,1,0,0 }
4 { 0,1,1,1,1,1,1,0,0,0 }
5 { 0,0,1,1,1,1,0,0,0,0 }
6 { 0,1,0,0,1,0,0,1,0,0 }
7 { 1,0,0,0,0,0,0,0,1,0 }
...
```

---

## Cores de referência

| Cor        | Valor                    |
|------------|--------------------------|
| Vermelho   | `{ 0.92, 0.20, 0.20 }`  |
| Laranja    | `{ 1.00, 0.50, 0.10 }`  |
| Amarelo    | `{ 0.95, 0.85, 0.10 }`  |
| Verde      | `{ 0.30, 0.80, 0.35 }`  |
| Azul       | `{ 0.25, 0.55, 0.95 }`  |
| Roxo       | `{ 0.65, 0.30, 0.90 }`  |
| Rosa       | `{ 0.95, 0.45, 0.70 }`  |
| Branco     | `{ 0.90, 0.90, 0.90 }`  |
| Marrom     | `{ 0.60, 0.35, 0.15 }`  |
| Ciano      | `{ 0.20, 0.85, 0.85 }`  |

---

## Dicas para bons puzzles

- **Centralize** o desenho no grid — evite colar tudo num canto
- **Deixe 1–2 linhas/colunas vazias** nas bordas como respiro
- **Formas simples e simétricas** geram puzzles mais satisfatórios de resolver
- Evite puzzles com **solução ambígua** — cada linha e coluna deve ter pelo menos um número diferente de zero
- Puzzles mais fáceis têm poucos grupos por linha; mais difíceis têm muitos grupos pequenos (ex: `1 1 1`)

---

## Enviando para o console

Após criar o arquivo no PC, copie via SCP:

```bash
scp puzzles/meu_puzzle.lua root@<IP>:/storage/roms/ports/picross/puzzles/meu_puzzle.lua
```

O jogo carrega os puzzles ao iniciar — basta fechar e reabrir.
