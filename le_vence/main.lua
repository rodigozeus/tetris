-- Lê e Vence! — Desafio de leitura e compreensão para crianças
-- Console : Anbernic RG DS | Engine : Love2D 11.5
-- Tela de cima  (DSI-2) : x   0.. 639 — texto para leitura
-- Tela de baixo (DSI-1) : x 640..1279 — pergunta + 4 alternativas (touch)

-- ═══════════════════════════════════════════════════════════════════════════
--  QUESTÕES
-- ═══════════════════════════════════════════════════════════════════════════
local QUESTOES = {
  -- ── Nível 1 – Fácil ─────────────────────────────────────────────────────
  {
    texto    = "O gato é um animal. Ele tem quatro patas e bigodes.\nO gato gosta muito de dormir.",
    pergunta = "Quantas patas tem o gato?",
    opcoes   = {"Duas", "Quatro", "Seis", "Oito"},
    correta  = 2,
    bg       = {0.85, 0.93, 1.00},
  },
  {
    texto    = "O cachorro late quando tem medo. Ele abana o rabo quando está feliz. O dono do cachorro se chama Pedro.",
    pergunta = "O que o cachorro faz quando está feliz?",
    opcoes   = {"Late", "Dorme", "Abana o rabo", "Come"},
    correta  = 3,
    bg       = {0.85, 1.00, 0.88},
  },
  {
    texto    = "Ana foi para a escola de manhã. Ela levou sua mochila azul. Na escola, Ana aprendeu a escrever.",
    pergunta = "De que cor era a mochila de Ana?",
    opcoes   = {"Verde", "Vermelha", "Amarela", "Azul"},
    correta  = 4,
    bg       = {1.00, 0.97, 0.82},
  },
  {
    texto    = "A banana é uma fruta amarela. Ela é doce e muito gostosa.\nOs macacos adoram banana.",
    pergunta = "De que cor é a banana?",
    opcoes   = {"Vermelha", "Roxa", "Amarela", "Verde"},
    correta  = 3,
    bg       = {1.00, 0.87, 0.90},
  },
  {
    texto    = "O sol nasce de manhã e se esconde à noite. Ele aquece a Terra e dá luz. À noite aparece a lua.",
    pergunta = "Quando o sol nasce?",
    opcoes   = {"À noite", "De manhã", "À tarde", "No inverno"},
    correta  = 2,
    bg       = {1.00, 0.93, 0.80},
  },
  -- ── Nível 2 – Médio ─────────────────────────────────────────────────────
  {
    texto    = "Hoje está chovendo muito. Bia pegou o guarda-chuva e saiu de casa. Na rua, ela viu uma poça d'água e pulou por cima.",
    pergunta = "Por que Bia pegou o guarda-chuva?",
    opcoes   = {"Para brincar", "Porque estava chovendo", "Para se proteger do sol", "Porque estava frio"},
    correta  = 2,
    bg       = {0.91, 0.87, 1.00},
  },
  {
    texto    = "O peixe vive na água. Ele tem nadadeiras e escamas. Alguns peixes vivem no mar e outros vivem no rio.",
    pergunta = "Onde o peixe vive?",
    opcoes   = {"Na terra", "No ar", "Na água", "Na floresta"},
    correta  = 3,
    bg       = {0.80, 0.97, 1.00},
  },
  {
    texto    = "Hoje é o aniversário do Lucas. Ele vai fazer sete anos. A mamãe fez um bolo de chocolate com velas.",
    pergunta = "Quantos anos Lucas vai fazer?",
    opcoes   = {"Cinco", "Seis", "Sete", "Oito"},
    correta  = 3,
    bg       = {1.00, 0.85, 0.92},
  },
  {
    texto    = "A borboleta começou como uma lagarta. Depois ficou dentro de um casulo. Quando saiu do casulo, ela tinha asas coloridas.",
    pergunta = "Como a borboleta começa a vida?",
    opcoes   = {"Com asas", "Como um pássaro", "Como uma lagarta", "Como um ovo"},
    correta  = 3,
    bg       = {0.82, 1.00, 0.92},
  },
  {
    texto    = "Na biblioteca, as pessoas leem livros em silêncio. João foi à biblioteca para pegar um livro sobre dinossauros. Ele ficou duas horas lendo.",
    pergunta = "Por que João foi à biblioteca?",
    opcoes   = {"Para brincar", "Para comer", "Para dormir", "Para pegar um livro"},
    correta  = 4,
    bg       = {0.87, 0.92, 1.00},
  },
  {
    texto    = "No inverno, os dias são frios. As pessoas usam casaco e cachecol para se aquecer. Em alguns lugares, cai neve no inverno.",
    pergunta = "O que as pessoas usam para se aquecer no inverno?",
    opcoes   = {"Camiseta e shorts", "Casaco e cachecol", "Boné e óculos", "Sandália e vestido"},
    correta  = 2,
    bg       = {0.88, 0.93, 0.98},
  },
  {
    texto    = "Dona Rosa tem uma horta no quintal. Ela planta tomates, cenouras e alface. Todo dia pela manhã ela rega as plantas.",
    pergunta = "Quando Dona Rosa rega as plantas?",
    opcoes   = {"À noite", "À tarde", "De manhã", "Toda semana"},
    correta  = 3,
    bg       = {0.88, 1.00, 0.83},
  },
  {
    texto    = "Miguel ganhou um robô de presente. O robô é vermelho e anda sozinho. Miguel aperta um botão e o robô dança.",
    pergunta = "O que acontece quando Miguel aperta o botão?",
    opcoes   = {"O robô para", "O robô dança", "O robô fala", "O robô some"},
    correta  = 2,
    bg       = {0.87, 0.90, 0.97},
  },
  {
    texto    = "Carla foi à praia com sua família. O mar estava azul e quente. Ela nadou, brincou na areia e comeu sorvete de morango.",
    pergunta = "Qual sabor de sorvete Carla comeu?",
    opcoes   = {"Chocolate", "Baunilha", "Limão", "Morango"},
    correta  = 4,
    bg       = {0.80, 0.97, 0.95},
  },
  -- ── Nível 3 – Difícil ───────────────────────────────────────────────────
  {
    texto    = "A tartaruga é um animal muito lento. Ela carrega uma carapaça dura nas costas. Quando sente perigo, a tartaruga esconde a cabeça dentro da carapaça.",
    pergunta = "O que a tartaruga faz quando sente perigo?",
    opcoes   = {"Corre rápido", "Morde", "Voa", "Esconde a cabeça"},
    correta  = 4,
    bg       = {0.93, 0.97, 0.83},
  },
  {
    texto    = "A mãe de Pedro foi ao mercado comprar frutas. Ela comprou maçã, laranja e uva. Na hora de pagar, ela usou um cartão.",
    pergunta = "Como a mãe de Pedro pagou no mercado?",
    opcoes   = {"Com dinheiro", "Com cheque", "Com cartão", "Com troca"},
    correta  = 3,
    bg       = {1.00, 0.96, 0.78},
  },
  {
    texto    = "No Dia das Crianças, as escolas ficam fechadas. As crianças ganham brinquedos e comem guloseimas. É um dia de muita alegria para todos.",
    pergunta = "O que acontece com as escolas no Dia das Crianças?",
    opcoes   = {"Ficam abertas", "Ficam cheias", "Ficam pintadas", "Ficam fechadas"},
    correta  = 4,
    bg       = {1.00, 0.88, 0.95},
  },
  {
    texto    = "O urso polar vive em lugares muito frios, como o Ártico. Sua pelagem branca o ajuda a se esconder na neve. Ele é um ótimo nadador e come peixe.",
    pergunta = "Para que serve a pelagem branca do urso polar?",
    opcoes   = {"Para aquecer no calor", "Para nadar mais rápido", "Para se esconder na neve", "Para assustar outros animais"},
    correta  = 3,
    bg       = {0.83, 0.95, 1.00},
  },
  {
    texto    = "Papai estava cansado e quis pedir pizza. Mas Vovó queria fazer macarrão em casa. No final, todos ajudaram a cozinhar e o macarrão ficou delicioso.",
    pergunta = "O que Papai queria fazer para o jantar?",
    opcoes   = {"Fazer macarrão", "Pedir macarrão", "Fazer pizza", "Pedir pizza"},
    correta  = 4,
    bg       = {1.00, 0.93, 0.83},
  },
  {
    texto    = "Sofia sonhou que podia voar sobre as nuvens. No sonho, ela viu cidades pequenas lá embaixo e tocou nas estrelas. Quando acordou, quis dormir de novo para continuar o sonho.",
    pergunta = "Por que Sofia quis dormir de novo?",
    opcoes   = {"Porque estava com sono", "Porque era muito cedo", "Para ir à escola no sonho", "Para continuar o sonho"},
    correta  = 4,
    bg       = {0.93, 0.88, 1.00},
  },
}

-- ═══════════════════════════════════════════════════════════════════════════
--  CONSTANTES
-- ═══════════════════════════════════════════════════════════════════════════
local TOTAL        = #QUESTOES
local META_ACERTOS = math.ceil(TOTAL * 0.8)   -- 16 de 20

-- Posição global dos 4 botões de alternativa (na tela de baixo)
-- Tela de baixo: x 640..1279 (640px), y 0..479 (480px)
-- Caixa de pergunta ocupa y 8..135 (128px); botões ocupam y 136..480 (344px / 2 linhas)
local BTNS = {
  {x = 650, y = 136, w = 298, h = 168},  -- A  (superior esquerdo)
  {x = 956, y = 136, w = 298, h = 168},  -- B  (superior direito)
  {x = 650, y = 312, w = 298, h = 168},  -- C  (inferior esquerdo)
  {x = 956, y = 312, w = 298, h = 168},  -- D  (inferior direito)
}
local LABELS = {"A", "B", "C", "D"}

-- Cor única para todos os botões de alternativa
local COR_BTN     = {0.94, 0.96, 1.00}
local COR_BTN_TXT = {0.10, 0.14, 0.32}
local COR_CORRETO  = {0.22, 0.82, 0.36}
local COR_ERRADO   = {0.88, 0.24, 0.24}
local COR_CORRETO_TXT = {1, 1, 1}
local COR_ERRADO_TXT  = {1, 1, 1}

-- ═══════════════════════════════════════════════════════════════════════════
--  ESTADO
-- ═══════════════════════════════════════════════════════════════════════════
local estado     = "intro"   -- intro | questao | feedback | resultado
local ordem      = {}
local idx        = 1
local acertos    = 0
local escolha    = 0         -- botão selecionado (1-4), 0 = nenhum
local t_feedback = 0
local FB_DUR     = 1.8       -- segundos mostrando feedback antes de avançar

-- Fontes (carregadas em love.load)
local f_body   -- 31px — texto de leitura
local f_ui     -- 27px — pergunta
local f_btn    -- 26px — alternativas nos botões
local f_big    -- 48px — títulos e destaques
local f_huge   -- 99px — placar final
local f_sm     -- 20px — indicadores secundários (progresso, etc.)

-- Sons (gerados em love.load)
local snd_click, snd_correto, snd_errado

-- ═══════════════════════════════════════════════════════════════════════════
--  UTILITÁRIOS
-- ═══════════════════════════════════════════════════════════════════════════
local function rrect(x, y, w, h, r, mode)
  love.graphics.rectangle(mode or "fill", x, y, w, h, r, r)
end

local function questao()
  return QUESTOES[ordem[idx]]
end

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

local function play(snd)
  if snd then snd:stop(); snd:play() end
end

-- Gera um tom sintético simples
local function make_tone(freq, dur, vol, waveform)
  local rate = 44100
  local n    = math.floor(rate * dur)
  local sd   = love.sound.newSoundData(n, rate, 16, 1)
  for i = 0, n - 1 do
    local t   = i / rate
    local env = math.min(1, t / 0.005) * math.min(1, (dur - t) / 0.04)
    local s
    if waveform == "square" then
      s = (math.sin(2 * math.pi * freq * t) >= 0) and 1.0 or -1.0
    else
      s = math.sin(2 * math.pi * freq * t)
    end
    sd:setSample(i, s * env * vol)
  end
  return love.audio.newSource(sd, "static")
end

-- Gera uma sequência de notas
local function make_seq(notes, vol)
  local rate    = 44100
  local total   = 0
  for _, n in ipairs(notes) do total = total + math.floor(rate * n.dur) end
  local sd      = love.sound.newSoundData(total, rate, 16, 1)
  local cursor  = 0
  for _, note in ipairs(notes) do
    local n = math.floor(rate * note.dur)
    for i = 0, n - 1 do
      local t   = i / rate
      local env = math.min(1, t / 0.008) * math.min(1, (note.dur - t) / 0.05)
      local s   = note.freq > 0 and math.sin(2 * math.pi * note.freq * t) or 0
      sd:setSample(cursor + i, s * env * vol)
    end
    cursor = cursor + n
  end
  return love.audio.newSource(sd, "static")
end

-- ═══════════════════════════════════════════════════════════════════════════
--  LOVE.LOAD
-- ═══════════════════════════════════════════════════════════════════════════
function love.load()
  f_body = love.graphics.newFont(31)
  f_ui   = love.graphics.newFont(27)
  f_btn  = love.graphics.newFont(26)
  f_big  = love.graphics.newFont(48)
  f_huge = love.graphics.newFont(99)
  f_sm   = love.graphics.newFont(20)

  -- click: toque sutil de alta frequência
  snd_click   = make_tone(1100, 0.06, 0.35, "sine")
  -- correto: arpegio ascendente animado
  snd_correto = make_seq({
    {freq=523, dur=0.10},  -- C5
    {freq=659, dur=0.10},  -- E5
    {freq=784, dur=0.18},  -- G5
  }, 0.55)
  -- errado: nota grave descendente
  snd_errado  = make_seq({
    {freq=300, dur=0.12},
    {freq=220, dur=0.20},
  }, 0.55)

  for i = 1, TOTAL do ordem[i] = i end
  shuffle(ordem)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  LOVE.UPDATE
-- ═══════════════════════════════════════════════════════════════════════════
function love.update(dt)
  if estado == "feedback" then
    t_feedback = t_feedback + dt
    if t_feedback >= FB_DUR then
      t_feedback = 0
      escolha    = 0
      if idx < TOTAL then
        idx    = idx + 1
        estado = "questao"
      else
        estado = "resultado"
      end
    end
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  DRAW — helpers
-- ═══════════════════════════════════════════════════════════════════════════

-- Tela de cima: fundo pastel + card branco com borda arredondada
local function draw_card_top(bg, content_fn)
  love.graphics.setColor(bg)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  -- sombra leve
  love.graphics.setColor(0, 0, 0, 0.08)
  rrect(19, 19, 610, 450, 22)

  -- card
  love.graphics.setColor(1, 1, 1, 0.94)
  rrect(15, 15, 610, 450, 20)

  -- borda suave
  love.graphics.setColor(0, 0, 0, 0.08)
  love.graphics.setLineWidth(1.5)
  rrect(15, 15, 610, 450, 20, "line")

  content_fn()
end

local function draw_tela_cima()
  local q = questao()

  if estado == "feedback" then
    -- tela de cima vira um painel grande de acerto/erro
    local acertou = (escolha == q.correta)
    local bg  = acertou and {0.15, 0.72, 0.30} or {0.82, 0.18, 0.18}
    local txt = acertou and "Acertou!" or "Errou!"

    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(f_huge)
    love.graphics.printf(txt, 0, 480/2 - f_huge:getHeight()/2, 640, "center")
    return
  end

  draw_card_top(q.bg, function()
    -- indicador de progresso
    love.graphics.setFont(f_sm)
    love.graphics.setColor(0.50, 0.50, 0.55)
    love.graphics.printf(
      string.format("Pergunta %d de %d", idx, TOTAL),
      40, 26, 560, "right"
    )

    -- texto principal de leitura
    love.graphics.setFont(f_body)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(q.texto, 40, 58, 560, "left")
  end)
end

local function draw_tela_baixo()
  local q  = questao()
  local bg = q.bg

  if estado == "feedback" then
    love.graphics.setColor(0.14, 0.14, 0.18)
    love.graphics.rectangle("fill", 640, 0, 640, 480)
    love.graphics.setColor(0.55, 0.58, 0.65)
    love.graphics.setFont(f_ui)
    love.graphics.printf(
      "Carregando próxima pergunta...",
      640, 480/2 - f_ui:getHeight()/2, 640, "center"
    )
    return
  end

  -- fundo levemente mais escuro que a tela de cima
  love.graphics.setColor(bg[1] * 0.66, bg[2] * 0.66, bg[3] * 0.66)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  -- box da pergunta
  love.graphics.setColor(1, 1, 1, 0.90)
  rrect(648, 8, 624, 120, 14)
  love.graphics.setColor(0.10, 0.10, 0.18)
  love.graphics.setFont(f_ui)
  love.graphics.printf(q.pergunta, 660, 20, 602, "center")

  -- 4 botões de alternativa
  for i, btn in ipairs(BTNS) do
    local bc = COR_BTN
    local tc = COR_BTN_TXT

    if estado == "feedback" then
      if i == q.correta then
        bc = COR_CORRETO
        tc = COR_CORRETO_TXT
      elseif i == escolha then
        bc = COR_ERRADO
        tc = COR_ERRADO_TXT
      end
    end

    -- sombra do botão
    love.graphics.setColor(0, 0, 0, 0.10)
    rrect(btn.x + 2, btn.y + 3, btn.w, btn.h, 14)

    -- corpo do botão
    love.graphics.setColor(bc)
    rrect(btn.x, btn.y, btn.w, btn.h, 14)

    -- borda
    love.graphics.setColor(0, 0, 0, 0.12)
    love.graphics.setLineWidth(1.5)
    rrect(btn.x, btn.y, btn.w, btn.h, 14, "line")

    -- texto centrado verticalmente (comporta até 2 linhas com fonte maior)
    love.graphics.setColor(tc)
    love.graphics.setFont(f_btn)
    local txt = LABELS[i] .. ")  " .. q.opcoes[i]
    local ty  = btn.y + math.floor(btn.h / 2 - f_btn:getHeight())
    love.graphics.printf(txt, btn.x + 12, ty, btn.w - 24, "center")
  end
end

local function draw_intro()
  -- ── Tela de cima ──────────────────────────────────────────────────────
  draw_card_top({0.90, 0.92, 1.00}, function()
    love.graphics.setFont(f_big)
    love.graphics.setColor(0.15, 0.25, 0.60)
    love.graphics.printf("Lê e Vence!", 40, 65, 560, "center")

    love.graphics.setFont(f_body)
    love.graphics.setColor(0.10, 0.10, 0.20)
    love.graphics.printf(
      "Olá, Gustavo!\n\n" ..
      "Você vai ler 20 textos curtos e responder\n" ..
      "uma pergunta sobre cada um.\n\n" ..
      "Para ganhar, precisa acertar pelo menos\n" ..
      "16 de 20 perguntas (80%).\n\n" ..
      "Leia com calma e boa sorte!",
      55, 148, 530, "left"
    )
  end)

  -- ── Tela de baixo ─────────────────────────────────────────────────────
  love.graphics.setColor(0.75, 0.80, 1.00)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  -- sombra do botão grande
  love.graphics.setColor(0, 0, 0, 0.15)
  rrect(724, 162, 480, 158, 22)

  -- botão de início
  love.graphics.setColor(0.28, 0.52, 0.95)
  rrect(720, 158, 480, 158, 22)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(f_big)
  love.graphics.printf("Toque aqui\npara começar!", 720, 186, 480, "center")
end

local function draw_resultado()
  local pct    = math.floor(acertos / TOTAL * 100 + 0.5)
  local passou = acertos >= META_ACERTOS

  local bg_top = passou and {0.82, 1.00, 0.86} or {1.00, 0.88, 0.82}
  local bg_bot = passou and {0.52, 0.88, 0.58} or {0.90, 0.55, 0.52}
  local ink    = passou and {0.06, 0.36, 0.13} or {0.36, 0.08, 0.05}

  -- ── Tela de cima ──────────────────────────────────────────────────────
  draw_card_top(bg_top, function()
    love.graphics.setFont(f_big)
    love.graphics.setColor(ink)
    local titulo = passou and "Parabéns, Gustavo!" or "Quase lá, Gustavo!"
    love.graphics.printf(titulo, 40, 52, 560, "center")

    love.graphics.setFont(f_huge)
    love.graphics.setColor(ink)
    love.graphics.printf(
      string.format("%d / %d", acertos, TOTAL),
      40, 112, 560, "center"
    )

    love.graphics.setFont(f_body)
    love.graphics.setColor(0.12, 0.12, 0.18)
    local msg
    if passou then
      msg = string.format(
        "Você acertou %d%% das perguntas!\n\n" ..
        "Você passou no teste de leitura!\n\n" ..
        "Parabéns — o videogame é seu!",
        pct
      )
    else
      msg = string.format(
        "Você acertou %d%% das perguntas.\n\n" ..
        "Precisava de 80%% para passar.\n\n" ..
        "Continue praticando!\n" ..
        "Tente de novo na semana que vem.",
        pct
      )
    end
    love.graphics.printf(msg, 55, 235, 530, "center")
  end)

  -- ── Tela de baixo ─────────────────────────────────────────────────────
  love.graphics.setColor(bg_bot)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  love.graphics.setColor(1, 1, 1, 0.92)
  love.graphics.setFont(f_big)
  local bot_msg = passou
    and "Uhuuu!\nVocê conseguiu!"
    or  "Foi por pouco!\nNa próxima você passa!"
  love.graphics.printf(bot_msg, 640, 175, 640, "center")

  -- dica de saída
  love.graphics.setFont(f_sm)
  love.graphics.setColor(1, 1, 1, 0.60)
  love.graphics.printf("Pressione Start para sair", 640, 448, 640, "center")
end

-- ═══════════════════════════════════════════════════════════════════════════
--  LOVE.DRAW
-- ═══════════════════════════════════════════════════════════════════════════
function love.draw()
  love.graphics.setBackgroundColor(0.14, 0.14, 0.18)

  if estado == "intro" then
    draw_intro()
  elseif estado == "questao" or estado == "feedback" then
    draw_tela_cima()
    draw_tela_baixo()
  elseif estado == "resultado" then
    draw_resultado()
  end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  TOUCH
-- ═══════════════════════════════════════════════════════════════════════════
local function handle_press(x, y)
  if estado == "intro" then
    -- qualquer toque na tela de baixo inicia o jogo
    if x >= 640 then
      estado = "questao"
    end
    return
  end

  if estado == "questao" then
    for i, btn in ipairs(BTNS) do
      if x >= btn.x and x < btn.x + btn.w and
         y >= btn.y and y < btn.y + btn.h then
        play(snd_click)
        escolha    = i
        local q    = questao()
        if i == q.correta then
          acertos = acertos + 1
          play(snd_correto)
        else
          play(snd_errado)
        end
        estado     = "feedback"
        t_feedback = 0
        return
      end
    end
  end
end

function love.touchpressed(_, x, y)
  handle_press(x, y)
end

-- fallback para mouse no PC durante desenvolvimento
function love.mousepressed(x, y, btn)
  if btn == 1 then handle_press(x, y) end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  TECLADO
-- ═══════════════════════════════════════════════════════════════════════════
function love.keypressed(k)
  if k == "escape" or k == "start" or k == "select" then
    love.event.quit()
  end

  if estado == "intro" and (k == "return" or k == "space" or k == "a") then
    estado = "questao"
    return
  end

  if estado == "questao" then
    -- atalhos numéricos para dev (PC)
    local map = {["1"]=1, ["2"]=2, ["3"]=3, ["4"]=4}
    local i = map[k]
    if i then
      escolha    = i
      local q    = questao()
      if i == q.correta then acertos = acertos + 1 end
      estado     = "feedback"
      t_feedback = 0
    end
  end
end
