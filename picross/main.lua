-- ================================================================
-- PICROSS
-- Anbernic RG DS — 1280×480 (dual screen)
-- Tela superior  (x   0–639) : revelação progressiva da imagem
-- Tela inferior  (x 640–1279): grade, dicas, interação touch
-- ================================================================

-- ────────────────────────────────────────────────────────────────
-- DADOS DOS PUZZLES
-- ────────────────────────────────────────────────────────────────

local function calc_clues(sol, n)
  local rows, cols = {}, {}
  for r = 1, n do
    local t, run = {}, 0
    for c = 1, n do
      if sol[r][c] == 1 then run = run + 1
      elseif run > 0 then t[#t+1] = run; run = 0 end
    end
    if run > 0 then t[#t+1] = run end
    rows[r] = #t > 0 and t or {0}
  end
  for c = 1, n do
    local t, run = {}, 0
    for r = 1, n do
      if sol[r][c] == 1 then run = run + 1
      elseif run > 0 then t[#t+1] = run; run = 0 end
    end
    if run > 0 then t[#t+1] = run end
    cols[c] = #t > 0 and t or {0}
  end
  return rows, cols
end

local PUZZLES = {}

-- ────────────────────────────────────────────────────────────────
-- LAYOUT (calculado em love.load)
-- ────────────────────────────────────────────────────────────────

local N    = 10
local CELL = 36   -- tamanho de célula na grade (tela inferior)
local CW   = 70   -- largura da área de dicas de linha
local CH   = 70   -- altura da área de dicas de coluna
local GX, GY      -- origem da grade (coordenadas absolutas da janela)

local ICELL = 46  -- tamanho de célula na imagem (tela superior)
local IX, IY      -- origem da imagem

-- ────────────────────────────────────────────────────────────────
-- ESTADO
-- ────────────────────────────────────────────────────────────────

local puzzle_idx
local puzzle
local grid       -- grid[r][c]: 0=vazia  1=preenchida  2=marcada X
local state      -- "playing" | "won"
local win_timer
local fonts = {}
local drag = {}   -- drag[id] = {mode, visited}
local cur_mode = 1  -- 1=preencher  2=marcar X

-- Botões de modo (posicionados à esquerda da grade, calculados em love.load)
local BTN_FILL = { w = 90, h = 52, label = "Preencher", val = 1 }
local BTN_X    = { w = 90, h = 52, label = "Marcar X",  val = 2 }

local function hit_btn(btn, tx, ty)
  return tx >= btn.x and tx <= btn.x + btn.w
     and ty >= btn.y and ty <= btn.y + btn.h
end

-- ────────────────────────────────────────────────────────────────
-- HELPERS
-- ────────────────────────────────────────────────────────────────

local function new_game(idx)
  puzzle_idx = idx
  puzzle     = PUZZLES[idx]
  grid       = {}
  for r = 1, N do
    grid[r] = {}
    for c = 1, N do grid[r][c] = 0 end
  end
  state     = "playing"
  win_timer = 0
  drag      = {}
end

local function cell_at(x, y)
  local c = math.floor((x - GX) / CELL) + 1
  local r = math.floor((y - GY) / CELL) + 1
  if r >= 1 and r <= N and c >= 1 and c <= N then return r, c end
end

local function row_done(r)
  for c = 1, N do
    if (grid[r][c] == 1) ~= (puzzle.sol[r][c] == 1) then return false end
  end
  return true
end

local function col_done(c)
  for r = 1, N do
    if (grid[r][c] == 1) ~= (puzzle.sol[r][c] == 1) then return false end
  end
  return true
end

local function check_win()
  for r = 1, N do
    if not row_done(r) then return false end
  end
  return true
end

local function set_cell(r, c, val)
  if not (r and c) then return end
  if grid[r][c] == val then return end
  grid[r][c] = val
  if val == 1 and check_win() then
    state     = "won"
    win_timer = 0
  end
end

-- ────────────────────────────────────────────────────────────────
-- LOVE.LOAD
-- ────────────────────────────────────────────────────────────────

function love.load()
  local pw = CW + N * CELL
  local ph = CH + N * CELL
  GX = 640 + math.floor((640 - pw) / 2) + CW
  GY = math.floor((480 - ph) / 2) + CH

  IX = math.floor((640 - N * ICELL) / 2)
  IY = math.floor((480 - N * ICELL) / 2)

  -- Botões de modo: centralizados na faixa à esquerda da grade (x=640..GX-CW)
  local bx = 640 + math.floor(((GX - CW - 640) - BTN_FILL.w) / 2)
  local total_bh = BTN_FILL.h + 14 + BTN_X.h
  local by = math.floor((480 - total_bh) / 2)
  BTN_FILL.x = bx;  BTN_FILL.y = by
  BTN_X.x    = bx;  BTN_X.y    = by + BTN_FILL.h + 14

  fonts.small  = love.graphics.newFont(11)
  fonts.medium = love.graphics.newFont(15)
  fonts.large  = love.graphics.newFont(30)
  fonts.clue   = love.graphics.newFont(13)
  fonts.title  = love.graphics.newFont(18)

  love.graphics.setDefaultFilter("nearest", "nearest")

  -- Carrega puzzles da pasta puzzles/ em ordem alfabética
  local files = love.filesystem.getDirectoryItems("puzzles")
  table.sort(files)
  for _, f in ipairs(files) do
    if f:match("%.lua$") then
      local p = love.filesystem.load("puzzles/" .. f)()
      p.row_clues, p.col_clues = calc_clues(p.sol, #p.sol)
      PUZZLES[#PUZZLES + 1] = p
    end
  end

  new_game(1)
end

-- ────────────────────────────────────────────────────────────────
-- LOVE.UPDATE
-- ────────────────────────────────────────────────────────────────

function love.update(dt)
  if state == "won" then
    win_timer = win_timer + dt
  end
end

-- ────────────────────────────────────────────────────────────────
-- DRAW — tela superior (imagem)
-- ────────────────────────────────────────────────────────────────

local function draw_top()
  love.graphics.setColor(0.06, 0.06, 0.10)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  local total, revealed = 0, 0
  for r = 1, N do
    for c = 1, N do
      local x = IX + (c - 1) * ICELL
      local y = IY + (r - 1) * ICELL

      if puzzle.sol[r][c] == 1 then
        total = total + 1
        if grid[r][c] == 1 then
          revealed = revealed + 1
          local col = puzzle.color
          love.graphics.setColor(col[1], col[2], col[3])
        else
          love.graphics.setColor(0.10, 0.10, 0.15)
        end
      else
        love.graphics.setColor(0.10, 0.10, 0.15)
      end
      love.graphics.rectangle("fill", x + 1, y + 1, ICELL - 2, ICELL - 2)

      love.graphics.setColor(0.13, 0.13, 0.20)
      love.graphics.setLineWidth(1)
      love.graphics.rectangle("line", x, y, ICELL, ICELL)
    end
  end

  -- Progresso
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.30, 0.30, 0.42)
  love.graphics.print(string.format("%d / %d", revealed, total), 8, 462)

  -- Overlay de vitoria
  if state == "won" and win_timer > 0.4 then
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Resolvido!", 0, 185, 640, "center")
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.70, 0.70, 0.70)
    love.graphics.printf("A -> proximo puzzle", 0, 235, 640, "center")
  end
end

-- ────────────────────────────────────────────────────────────────
-- DRAW — tela inferior (grade)
-- ────────────────────────────────────────────────────────────────

local function draw_bottom()
  love.graphics.setColor(0.10, 0.10, 0.16)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  -- Dicas de colunas
  love.graphics.setFont(fonts.clue)
  for c = 1, N do
    local cx    = GX + (c - 1) * CELL + CELL / 2
    local clues = puzzle.col_clues[c]
    local done  = col_done(c)
    local n     = #clues
    for i, v in ipairs(clues) do
      if v ~= 0 then
        local cy = GY - (n - i + 1) * 17 - 2
        if done then
          love.graphics.setColor(0.25, 0.88, 0.38)
        else
          love.graphics.setColor(0.78, 0.78, 0.78)
        end
        love.graphics.printf(tostring(v), cx - 12, cy, 24, "center")
      end
    end
  end

  -- Dicas de linhas
  for r = 1, N do
    local ry    = GY + (r - 1) * CELL + (CELL - 14) / 2
    local clues = puzzle.row_clues[r]
    local done  = row_done(r)
    local n     = #clues
    for i, v in ipairs(clues) do
      if v ~= 0 then
        local rx = GX - (n - i + 1) * 17 - 4
        if done then
          love.graphics.setColor(0.25, 0.88, 0.38)
        else
          love.graphics.setColor(0.78, 0.78, 0.78)
        end
        love.graphics.print(tostring(v), rx, ry)
      end
    end
  end

  -- Celulas
  for r = 1, N do
    for c = 1, N do
      local x   = GX + (c - 1) * CELL
      local y   = GY + (r - 1) * CELL
      local val = grid[r][c]

      if val == 1 then
        local col = puzzle.color
        love.graphics.setColor(col[1], col[2], col[3])
      else
        love.graphics.setColor(0.18, 0.18, 0.26)
      end
      love.graphics.rectangle("fill", x + 1, y + 1, CELL - 2, CELL - 2)

      if val == 2 then
        love.graphics.setColor(0.68, 0.28, 0.28)
        love.graphics.setLineWidth(2)
        local p = 7
        love.graphics.line(x+p, y+p, x+CELL-p, y+CELL-p)
        love.graphics.line(x+CELL-p, y+p, x+p, y+CELL-p)
        love.graphics.setLineWidth(1)
      end

      love.graphics.setColor(0.28, 0.28, 0.38)
      love.graphics.setLineWidth(1)
      love.graphics.rectangle("line", x, y, CELL, CELL)
    end
  end

  -- Linhas grossas a cada 5 celulas
  love.graphics.setColor(0.50, 0.50, 0.62)
  love.graphics.setLineWidth(2)
  for i = 0, N, 5 do
    love.graphics.line(GX + i*CELL, GY,          GX + i*CELL, GY + N*CELL)
    love.graphics.line(GX,          GY + i*CELL, GX + N*CELL, GY + i*CELL)
  end
  love.graphics.setLineWidth(1)

  -- Botões de modo
  for _, btn in ipairs({ BTN_FILL, BTN_X }) do
    local active = (cur_mode == btn.val)
    if active then
      love.graphics.setColor(0.30, 0.52, 0.80)
    else
      love.graphics.setColor(0.18, 0.18, 0.28)
    end
    love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 6, 6)
    love.graphics.setColor(active and 1 or 0.55, active and 1 or 0.55, active and 1 or 0.60)
    love.graphics.setFont(fonts.small)
    love.graphics.printf(btn.label, btn.x, btn.y + btn.h / 2 - 6, btn.w, "center")
  end

  -- Dica de controles
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.32, 0.32, 0.44)
  love.graphics.print("Arraste: aplica modo  Start: proximo  Select: sair", 648, 464)

  -- Overlay de vitoria (fundo)
  if state == "won" and win_timer > 0.4 then
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 640, 0, 640, 480)
  end
end

function love.draw()
  draw_top()
  draw_bottom()
end

-- ────────────────────────────────────────────────────────────────
-- INPUT — TOUCH
-- ────────────────────────────────────────────────────────────────
-- Age no touchpressed (resposta imediata, sem depender do release).
-- Toque simples: cicla vazia(0) → preenchida(1) → X(2) → vazia(0)
-- Arrastar: aplica o mesmo estado em todas as células percorridas.

function love.touchpressed(id, x, y)
  -- Botões de modo (sempre respondem)
  if hit_btn(BTN_FILL, x, y) then cur_mode = 1; return end
  if hit_btn(BTN_X,    x, y) then cur_mode = 2; return end

  if state ~= "playing" then return end
  local r, c = cell_at(x, y)
  if not r then return end

  -- Se a célula já tem o modo atual, limpa; senão aplica
  local new_val = (grid[r][c] == cur_mode) and 0 or cur_mode
  set_cell(r, c, new_val)
  drag[id] = { mode = new_val, visited = { [r * 100 + c] = true } }
end

function love.touchmoved(id, x, y)
  local d = drag[id]
  if not d or state ~= "playing" then return end
  local r, c = cell_at(x, y)
  if not r then return end
  local key = r * 100 + c
  if not d.visited[key] then
    d.visited[key] = true
    set_cell(r, c, d.mode)
  end
end

function love.touchreleased(id)
  drag[id] = nil
end

-- ────────────────────────────────────────────────────────────────
-- INPUT — GAMEPAD
-- ────────────────────────────────────────────────────────────────

function love.gamepadpressed(_, btn)
  if btn == "back" then love.event.quit() end
  if btn == "start" or (state == "won" and btn == "b") then
    new_game((puzzle_idx % #PUZZLES) + 1)
  end
end

-- ────────────────────────────────────────────────────────────────
-- INPUT — TECLADO / MOUSE (testes no PC)
-- ────────────────────────────────────────────────────────────────

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "return" or key == "n" then
    new_game((puzzle_idx % #PUZZLES) + 1)
  end
end

function love.mousepressed(x, y, btn)
  if btn == 1 then love.touchpressed("m", x, y) end
end

function love.mousemoved(x, y)
  if love.mouse.isDown(1) then love.touchmoved("m", x, y) end
end

function love.mousereleased(x, y, btn)
  if btn == 1 then love.touchreleased("m") end
end
