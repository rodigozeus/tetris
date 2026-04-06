-- Quiz - Love2D

local questions = {
  { q = "Qual é a capital do Brasil?",
    opts = {"São Paulo", "Rio de Janeiro", "Brasília", "Salvador"},
    ans = 3 },
  { q = "Quanto é 7 x 8?",
    opts = {"54", "56", "62", "64"},
    ans = 2 },
  { q = "Qual o maior planeta do sistema solar?",
    opts = {"Saturno", "Jupiter", "Netuno", "Urano"},
    ans = 2 },
  { q = "Em que ano o Brasil foi descoberto?",
    opts = {"1492", "1498", "1500", "1502"},
    ans = 3 },
}

local W, H = 640, 480

-- cores (r,g,b)
local C = {
  bg      = {0.05, 0.05, 0.15},
  white   = {1,    1,    1   },
  yellow  = {1,    0.9,  0.2 },
  green   = {0.2,  0.9,  0.4 },
  red     = {0.9,  0.3,  0.3 },
  gray    = {0.5,  0.5,  0.5 },
  dark    = {0.15, 0.15, 0.3 },
  sel_bg  = {0.2,  0.2,  0.5 },
}

local state, qi, sel, score, correct, timer
local font_big, font_med, font_small

function love.load()
  font_big   = love.graphics.newFont(48)
  font_med   = love.graphics.newFont(28)
  font_small = love.graphics.newFont(20)

  state   = "intro"
  qi      = 1
  sel     = 1
  score   = 0
  correct = false
  timer   = 0
end

function love.update(dt)
  timer = timer + dt
end

-- ─── INPUT ───────────────────────────────────────────────────────────────────

local function on_up()
  if state == "question" then
    sel = sel - 1
    if sel < 1 then sel = #questions[qi].opts end
  end
end

local function on_down()
  if state == "question" then
    sel = sel + 1
    if sel > #questions[qi].opts then sel = 1 end
  end
end

local function on_confirm()
  if state == "intro" then
    qi, sel, score = 1, 1, 0
    state = "question"
    timer = 0

  elseif state == "question" then
    correct = (sel == questions[qi].ans)
    if correct then score = score + 1 end
    state = "feedback"
    timer = 0

  elseif state == "finish" then
    state = "intro"
    timer = 0
  end
end

function love.keypressed(key)
  if     key == "up"     then on_up()
  elseif key == "down"   then on_down()
  elseif key == "escape" then love.event.quit()
  elseif key == "return" or key == "space" or key == "z" then on_confirm()
  end
end

function love.gamepadpressed(_, button)
  if     button == "dpup"   then on_up()
  elseif button == "dpdown" then on_down()
  elseif button == "start"  then love.event.quit()
  elseif button == "a" or button == "b" then on_confirm()
  end
end

-- ─── HELPERS ─────────────────────────────────────────────────────────────────

local function setcolor(c) love.graphics.setColor(c) end

local function centerprint(font, text, y, c)
  setcolor(c)
  love.graphics.setFont(font)
  local tw = font:getWidth(text)
  love.graphics.print(text, (W - tw) / 2, y)
end

local function blink(font, text, y, c)
  if math.floor(timer * 2) % 2 == 0 then
    centerprint(font, text, y, c)
  end
end

-- ─── TELAS ───────────────────────────────────────────────────────────────────

local function draw_intro()
  centerprint(font_big, "Q U I Z", 140, C.yellow)
  centerprint(font_small, "Use o direcional para escolher", 260, C.gray)
  centerprint(font_small, "e o botao A para confirmar", 290, C.gray)
  blink(font_med, "Pressione A para comecar", 380, C.white)
end

local function draw_question()
  local q = questions[qi]

  -- cabecalho
  setcolor(C.gray)
  love.graphics.setFont(font_small)
  love.graphics.print("Pergunta "..qi.."/"..#questions, 30, 20)
  local pts = "Pontos: "..score
  love.graphics.print(pts, W - font_small:getWidth(pts) - 30, 20)

  setcolor(C.gray)
  love.graphics.line(30, 55, W - 30, 55)

  -- pergunta
  centerprint(font_med, q.q, 75, C.white)

  -- opcoes
  for i = 1, #q.opts do
    local y = 170 + (i - 1) * 65
    if i == sel then
      setcolor(C.sel_bg)
      love.graphics.rectangle("fill", 60, y - 8, W - 120, 50, 8)
      setcolor(C.yellow)
    else
      setcolor(C.white)
    end
    love.graphics.setFont(font_med)
    love.graphics.print(i..".  "..q.opts[i], 80, y)
  end

  -- rodape
  centerprint(font_small, "A para confirmar", 450, C.gray)
end

local function draw_feedback()
  if correct then
    centerprint(font_big, "CORRETO!", 140, C.green)
  else
    centerprint(font_big, "ERROU!", 140, C.red)
    centerprint(font_med, "Resposta: "..questions[qi].opts[questions[qi].ans], 230, C.white)
  end

  centerprint(font_small, "Pontos: "..score, 320, C.yellow)

  -- barra de progresso
  local duration = 2.5
  local progress = math.min(timer / duration, 1)
  local bw = W - 120
  setcolor(C.dark)
  love.graphics.rectangle("fill", 60, 420, bw, 20, 4)
  setcolor(correct and C.green or C.red)
  love.graphics.rectangle("fill", 60, 420, bw * (1 - progress), 20, 4)

  if timer >= duration then
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

local function draw_finish()
  centerprint(font_big, "FIM!", 100, C.yellow)
  centerprint(font_med, "Voce acertou "..score.." de "..#questions, 200, C.white)

  local msg
  if score == #questions then
    msg = "Perfeito! Parabens!"
  elseif score >= math.ceil(#questions / 2) then
    msg = "Bom trabalho!"
  else
    msg = "Tente novamente!"
  end
  centerprint(font_med, msg, 270, score == #questions and C.green or C.yellow)

  blink(font_small, "Pressione A para jogar de novo", 400, C.gray)
end

-- ─── DRAW ────────────────────────────────────────────────────────────────────

function love.draw()
  setcolor(C.bg)
  love.graphics.rectangle("fill", 0, 0, W, H)

  if     state == "intro"    then draw_intro()
  elseif state == "question" then draw_question()
  elseif state == "feedback" then draw_feedback()
  elseif state == "finish"   then draw_finish()
  end
end
