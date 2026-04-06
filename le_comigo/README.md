# Lê Comigo!

Jogo educativo cooperativo de alfabetização inicial para o Anbernic RG DS (Love2D / Rocknix).

---

## Proposta

O jogo transforma a leitura de sílabas em uma atividade de dupla — uma criança e um adulto supervisor.
A avaliação é feita pelo supervisor, não pelo jogo, eliminando a frustração de errar na frente de uma máquina.
Não há "game over": erros apenas reiniciam a tentativa com a mesma sílaba, preservando os pontos já conquistados.

---

## Controles

| Quem | Ação | Botão físico | Love2D |
|------|------|-------------|--------|
| Supervisor | Leitura correta | **R1** / **A** / **D↑** / **D→** | `"rightshoulder"` / `"b"` / `"dpup"` / `"dpright"` |
| Supervisor | Tentar novamente | **L1** / **B** / **D↓** / **D←** | `"leftshoulder"` / `"a"` / `"dpdown"` / `"dpleft"` |
| Qualquer | Pausar / Encerrar | **Start** | `"start"` |

**Teclado (testes no PC):** `Espaço` / `→` / `↑` = correto · `←` / `↓` = errou · `Esc` = pausa

---

## Fluxo de Jogo

```
[ LEITURA - fundo azul ]
   Sílaba grande aparece na tela
   Criança lê em voz alta
   Supervisor avalia a pronúncia:
   R1 / A / D↑ / D→ (correto) ───→ [ ACERTO - fundo verde ] → nova sílaba
   L1 / B / D↓ / D← (errou)  ───→ [ ERRO - fundo laranja ] → mesma sílaba
```

A cada **5 acertos consecutivos**, uma celebração especial é exibida com confetes e animação.

---

## Pontuação

- Cada acerto vale **10 × combo atual**
  - 1º acerto seguido: +10 pts
  - 2º: +20 pts · 3º: +30 pts · etc.
- Erros zeram o combo, **sem subtrair** a pontuação acumulada
- O **recorde histórico** é salvo automaticamente ao encerrar a sessão (Start)
  - O jogo só salva se o recorde foi superado naquela sessão
  - Um banner **"NOVO RECORDE!"** aparece no momento em que o recorde é batido

---

## Sílabas

Cobre as combinações consoante+vogal do Português:
BA BE BI BO BU · CA CO CU · DA DE DI DO DU · FA FE FI FO FU ·
GA GO GU · JA JE JO JU · LA LE LI LO LU · MA ME MI MO MU ·
NA NE NI NO NU · PA PE PI PO PU · QUE QUI ·
RA RE RI RO RU · SA SE SI SO SU · TA TE TI TO TU ·
VA VE VI VO VU · ZA ZE ZI ZO ZU

---

## Deploy no Console

```bash
# Primeira vez
ssh root@<IP> "mkdir -p /storage/roms/ports/le_comigo"
scp LeComigo.sh root@<IP>:/storage/roms/ports/LeComigo.sh
ssh root@<IP> "chmod +x /storage/roms/ports/LeComigo.sh"

# Enviar / atualizar o jogo
scp le_comigo/main.lua le_comigo/conf.lua root@<IP>:/storage/roms/ports/le_comigo/
```

O recorde é salvo em `/root/.local/share/LOVE/le_comigo/highscore.txt` no console.
