-- title: Quiz
-- author: voce
-- desc: Jogo de perguntas e respostas
-- script: lua

local questions = {
  {
    q = "Qual e a capital do Brasil?",
    opts = {"Sao Paulo", "Rio de Janeiro", "Brasilia", "Salvador"},
    ans = 3
  },
  {
    q = "Quanto e 7 x 8?",
    opts = {"54", "56", "62", "64"},
    ans = 2
  },
  {
    q = "Qual o maior planeta do sistema solar?",
    opts = {"Saturno", "Jupiter", "Netuno", "Urano"},
    ans = 2
  },
  {
    q = "Em que ano o Brasil foi descoberto?",
    opts = {"1492", "1498", "1500", "1502"},
    ans = 3
  },
}

-- estado do jogo
local state = "intro"
local qi = 1         -- indice da pergunta atual
local sel = 1        -- opcao selecionada
local score = 0
local correct = false
local timer = 0

function TIC()
  cls(0)
  timer = timer + 1

  if     state == "intro"    then do_intro()
  elseif state == "question" then do_question()
  elseif state == "feedback" then do_feedback()
  elseif state == "finish"   then do_finish()
  end
end

-- ─── INTRO ───────────────────────────────────────────────────────────────────

function do_intro()
  print("Q U I Z", 90, 45, 11, false, 2)
  print("Responda as perguntas", 52, 85, 6)
  print("com o direcional e botao A", 38, 95, 6)
  blink_text("Pressione A para comecar", 44, 115, 7)

  if btnp(4) then
    qi = 1
    sel = 1
    score = 0
    state = "question"
  end
end

-- ─── PERGUNTA ────────────────────────────────────────────────────────────────

function do_question()
  local q = questions[qi]

  -- cabecalho
  print("Pergunta "..qi.."/"..#questions, 4, 4, 6)
  print("Pontos: "..score, 185, 4, 11)
  line(0, 13, 239, 13, 5)

  -- texto da pergunta
  print(q.q, 4, 22, 7)

  -- opcoes
  for i = 1, #q.opts do
    local y = 45 + (i - 1) * 20
    local col = 6
    if i == sel then
      col = 11
      rectb(8, y - 2, 220, 14, 11)
    end
    print(i..". "..q.opts[i], 14, y, col)
  end

  -- dica de controles
  print("^v mover   A confirmar", 52, 128, 5)

  -- input
  if btnp(0) then sel = sel - 1; if sel < 1 then sel = #q.opts end end
  if btnp(1) then sel = sel + 1; if sel > #q.opts then sel = 1 end end

  if btnp(4) then
    correct = (sel == q.ans)
    if correct then score = score + 1 end
    timer = 0
    state = "feedback"
  end
end

-- ─── FEEDBACK ────────────────────────────────────────────────────────────────

function do_feedback()
  local q = questions[qi]

  if correct then
    print("CORRETO!", 84, 40, 11, false, 2)
    print(":)", 113, 70, 11)
  else
    print("ERROU!", 90, 40, 8, false, 2)
    print("Resposta certa:", 72, 68, 6)
    print(q.opts[q.ans], 72, 79, 7)
  end

  -- barra de progresso (tempo restante)
  local total = 100
  local remaining = total - timer
  if remaining < 0 then remaining = 0 end
  rect(20, 118, math.floor((200 * remaining) / total), 6, correct and 11 or 8)
  rectb(20, 118, 200, 6, 5)

  if timer >= total then
    qi = qi + 1
    if qi > #questions then
      state = "finish"
    else
      sel = 1
      state = "question"
    end
    timer = 0
  end
end

-- ─── FIM ─────────────────────────────────────────────────────────────────────

function do_finish()
  print("FIM DO QUIZ!", 72, 20, 7, false, 1)
  line(0, 34, 239, 34, 5)

  print("Voce acertou:", 80, 50, 6)
  print(score.." de "..#questions, 95, 65, 11, false, 2)

  if score == #questions then
    print("Perfeito! Incrivel!", 62, 95, 11)
  elseif score >= math.ceil(#questions / 2) then
    print("Bom trabalho!", 74, 95, 7)
  else
    print("Tente novamente!", 66, 95, 8)
  end

  blink_text("Pressione A para jogar de novo", 24, 118, 6)

  if btnp(4) then
    state = "intro"
  end
end

-- ─── UTILITARIOS ─────────────────────────────────────────────────────────────

function blink_text(text, x, y, col)
  if (timer // 30) % 2 == 0 then
    print(text, x, y, col)
  end
end
