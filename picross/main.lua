-- ================================================================
-- PICROSS — puzzles .non / .nin (formato Nonny)
-- Anbernic RG DS — 1280×480 (dual screen)
-- Tela superior  (x   0–639) : preview progressivo da imagem
-- Tela inferior  (x 640–1279): grade + dicas + interação touch
-- ================================================================

-- ────────────────────────────────────────────────────────────────
-- PARSERS
-- ────────────────────────────────────────────────────────────────

local function parse_clue_line(line)
  local clues = {}
  for n in line:gmatch("%d+") do clues[#clues+1] = tonumber(n) end
  return #clues > 0 and clues or {0}
end

local function parse_non(content)
  local p = { row_clues = {}, col_clues = {}, title = "Nonograma" }
  local section = nil
  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    line = line:match("^%s*(.-)%s*$")
    if    line == "rows"     then section = "rows"
    elseif line == "columns" then section = "columns"
    elseif line:match("^width%s")  then p.W = tonumber(line:match("%d+"))
    elseif line:match("^height%s") then p.H = tonumber(line:match("%d+"))
    elseif line:match("^title%s")  then
      p.title = line:match('^title%s+"(.-)"') or line:match("^title%s+(.*)")
    elseif section == "rows" then
      p.row_clues[#p.row_clues+1] = parse_clue_line(line)
    elseif section == "columns" then
      p.col_clues[#p.col_clues+1] = parse_clue_line(line)
    end
  end
  return p
end

local function parse_nin(content, filename)
  local p = { row_clues = {}, col_clues = {}, title = filename or "Nonograma" }
  local lines = {}
  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    local l = line:match("^%s*(.-)%s*$")
    if l ~= "" then lines[#lines+1] = l end
  end
  local w, h = lines[1]:match("^(%d+)%s+(%d+)")
  p.W, p.H = tonumber(w), tonumber(h)
  for i = 1, p.H do
    p.row_clues[i] = parse_clue_line(lines[1 + i] or "0")
  end
  for j = 1, p.W do
    p.col_clues[j] = parse_clue_line(lines[1 + p.H + j] or "0")
  end
  return p
end

-- ────────────────────────────────────────────────────────────────
-- PALETA DE CORES
-- ────────────────────────────────────────────────────────────────

local PALETTE = {
  {0.29, 0.56, 0.93},
  {0.25, 0.78, 0.47},
  {0.93, 0.45, 0.26},
  {0.85, 0.35, 0.65},
  {0.65, 0.45, 0.95},
  {0.95, 0.82, 0.22},
  {0.30, 0.85, 0.85},
  {0.90, 0.38, 0.38},
}

-- ────────────────────────────────────────────────────────────────
-- ESTADO
-- ────────────────────────────────────────────────────────────────

local PUZZLES = {}
local puzzle_idx
local puzzle
local grid        -- grid[r][c]: 0=vazia  1=preenchida  2=marcada X
local state       -- "playing" | "won"
local win_timer
local fonts = {}
local drag = {}   -- drag[id] = {mode, visited}
local cell_stamp = {}
local DEBOUNCE = 0.20

-- Layout (recalculado a cada new_game)
local W, H        -- dimensões do puzzle atual
local CELL        -- tamanho de célula na grade
local CW, CH      -- largura/altura da área de dicas
local GX, GY      -- origem da grade (coordenadas absolutas da janela)
local ICELL       -- tamanho de célula na imagem (tela superior)
local IX, IY      -- origem da imagem
local color       -- cor do puzzle atual

-- ────────────────────────────────────────────────────────────────
-- WIN CHECK — satisfação das dicas (funciona sem solution)
-- ────────────────────────────────────────────────────────────────

local function runs_match(cells, clues)
  local runs, run = {}, 0
  for _, v in ipairs(cells) do
    if v == 1 then run = run + 1
    elseif run > 0 then runs[#runs+1] = run; run = 0 end
  end
  if run > 0 then runs[#runs+1] = run end
  if #runs == 0 and #clues == 1 and clues[1] == 0 then return true end
  if #runs ~= #clues then return false end
  for i, v in ipairs(clues) do if runs[i] ~= v then return false end end
  return true
end

local function check_win()
  for r = 1, H do
    local cells = {}
    for c = 1, W do cells[c] = grid[r][c] == 1 and 1 or 0 end
    if not runs_match(cells, puzzle.row_clues[r]) then return false end
  end
  for c = 1, W do
    local cells = {}
    for r = 1, H do cells[r] = grid[r][c] == 1 and 1 or 0 end
    if not runs_match(cells, puzzle.col_clues[c]) then return false end
  end
  return true
end

-- ────────────────────────────────────────────────────────────────
-- HELPERS
-- ────────────────────────────────────────────────────────────────

local function recalc_layout()
  W, H = puzzle.W, puzzle.H

  -- Largura/altura necessária para as dicas
  local max_rc, max_cc = 0, 0
  for r = 1, H do max_rc = math.max(max_rc, #puzzle.row_clues[r]) end
  for c = 1, W do max_cc = math.max(max_cc, #puzzle.col_clues[c]) end
  CW = math.max(max_rc * 15 + 4, 20)
  CH = math.max(max_cc * 15 + 4, 20)

  -- Tamanho de célula para caber na tela inferior (640×480, rodapé 28px)
  local avail_w = 640 - CW
  local avail_h = 480 - CH - 28
  CELL = math.max(math.floor(math.min(avail_w / W, avail_h / H)), 8)

  -- Centraliza grade+dicas na tela inferior
  local total_w = CW + W * CELL
  local total_h = CH + H * CELL
  local ox = math.floor((640 - total_w) / 2)
  local oy = math.floor(((480 - 28) - total_h) / 2)
  GX = 640 + ox + CW
  GY = oy + CH

  -- Imagem na tela superior (margem 22px)
  ICELL = math.max(math.floor(math.min(596 / W, 436 / H)), 4)
  IX = math.floor((640 - W * ICELL) / 2)
  IY = math.floor((480 - H * ICELL) / 2)
end

local function new_game(idx)
  puzzle_idx = idx
  puzzle     = PUZZLES[idx]
  recalc_layout()
  color      = PALETTE[(idx - 1) % #PALETTE + 1]
  grid       = {}
  for r = 1, H do
    grid[r] = {}
    for c = 1, W do grid[r][c] = 0 end
  end
  state      = "playing"
  win_timer  = 0
  drag       = {}
  cell_stamp = {}
end

local function cell_at(x, y)
  local c = math.floor((x - GX) / CELL) + 1
  local r = math.floor((y - GY) / CELL) + 1
  if r >= 1 and r <= H and c >= 1 and c <= W then return r, c end
end

local function set_cell(r, c, val)
  if not (r and c) then return end
  if grid[r][c] == val then return end
  grid[r][c] = val
  if val ~= 2 and check_win() then
    state     = "won"
    win_timer = 0
  end
end

-- ────────────────────────────────────────────────────────────────
-- CARREGAMENTO DE PUZZLES
-- ────────────────────────────────────────────────────────────────

local MAX_DIM = 30  -- filtra puzzles maiores que 30×30 (células ficariam < 10px)

local function load_dir(dir)
  local items = love.filesystem.getDirectoryItems(dir)
  table.sort(items)
  for _, name in ipairs(items) do
    local path = dir .. "/" .. name
    local info = love.filesystem.getInfo(path)
    if info and info.type == "directory" then
      load_dir(path)
    else
      local content = love.filesystem.read(path)
      if content then
        local p
        if name:match("%.non$") then
          p = parse_non(content)
        elseif name:match("%.nin$") then
          p = parse_nin(content, name:gsub("%.nin$", ""))
        end
        if p and p.W and p.H
          and p.W <= MAX_DIM and p.H <= MAX_DIM
          and #p.row_clues == p.H
          and #p.col_clues == p.W then
          PUZZLES[#PUZZLES+1] = p
        end
      end
    end
  end
end

-- ────────────────────────────────────────────────────────────────
-- LOVE.LOAD
-- ────────────────────────────────────────────────────────────────

function love.load()
  fonts.small  = love.graphics.newFont(10)
  fonts.medium = love.graphics.newFont(14)
  fonts.large  = love.graphics.newFont(28)
  fonts.clue   = love.graphics.newFont(11)
  fonts.title  = love.graphics.newFont(16)

  love.graphics.setDefaultFilter("nearest", "nearest")

  load_dir("puzzles")

  if #PUZZLES == 0 then error("Nenhum puzzle encontrado em puzzles/") end

  new_game(1)
end

-- ────────────────────────────────────────────────────────────────
-- LOVE.UPDATE
-- ────────────────────────────────────────────────────────────────

function love.update(dt)
  if state == "won" then win_timer = win_timer + dt end
end

-- ────────────────────────────────────────────────────────────────
-- DRAW — tela superior (preview)
-- ────────────────────────────────────────────────────────────────

local function draw_top()
  love.graphics.setColor(0.06, 0.06, 0.10)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  for r = 1, H do
    for c = 1, W do
      local x = IX + (c - 1) * ICELL
      local y = IY + (r - 1) * ICELL
      if grid[r][c] == 1 then
        love.graphics.setColor(color[1], color[2], color[3])
      else
        love.graphics.setColor(0.12, 0.12, 0.18)
      end
      love.graphics.rectangle("fill", x + 1, y + 1, ICELL - 1, ICELL - 1)
    end
  end

  -- Título
  love.graphics.setFont(fonts.title)
  love.graphics.setColor(0.70, 0.70, 0.80)
  love.graphics.printf(puzzle.title, 0, 8, 640, "center")

  -- Índice
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.30, 0.30, 0.42)
  love.graphics.printf(
    string.format("%d×%d    %d / %d", W, H, puzzle_idx, #PUZZLES),
    0, 465, 640, "center")

  -- Overlay de vitória
  if state == "won" and win_timer > 0.4 then
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.printf("Resolvido!", 0, 185, 640, "center")
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.70, 0.70, 0.70)
    love.graphics.printf("Start → próximo puzzle", 0, 232, 640, "center")
  end
end

-- ────────────────────────────────────────────────────────────────
-- DRAW — tela inferior (grade)
-- ────────────────────────────────────────────────────────────────

local function row_done(r)
  local cells = {}
  for c = 1, W do cells[c] = grid[r][c] == 1 and 1 or 0 end
  return runs_match(cells, puzzle.row_clues[r])
end

local function col_done(c)
  local cells = {}
  for r = 1, H do cells[r] = grid[r][c] == 1 and 1 or 0 end
  return runs_match(cells, puzzle.col_clues[c])
end

local function draw_bottom()
  love.graphics.setColor(0.10, 0.10, 0.16)
  love.graphics.rectangle("fill", 640, 0, 640, 480)

  love.graphics.setFont(fonts.clue)

  -- Dicas de colunas
  for c = 1, W do
    local cx    = GX + (c - 1) * CELL + CELL / 2
    local clues = puzzle.col_clues[c]
    local done  = col_done(c)
    local n     = #clues
    for i, v in ipairs(clues) do
      if v ~= 0 then
        local cy = GY - (n - i + 1) * 15 - 2
        love.graphics.setColor(done and {0.25, 0.88, 0.38} or {0.75, 0.75, 0.75})
        love.graphics.printf(tostring(v), cx - 10, cy, 20, "center")
      end
    end
  end

  -- Dicas de linhas
  for r = 1, H do
    local ry    = GY + (r - 1) * CELL + (CELL - 12) / 2
    local clues = puzzle.row_clues[r]
    local done  = row_done(r)
    local n     = #clues
    for i, v in ipairs(clues) do
      if v ~= 0 then
        local rx = GX - (n - i + 1) * 15 - 2
        love.graphics.setColor(done and {0.25, 0.88, 0.38} or {0.75, 0.75, 0.75})
        love.graphics.print(tostring(v), rx, ry)
      end
    end
  end

  -- Células
  for r = 1, H do
    for c = 1, W do
      local x   = GX + (c - 1) * CELL
      local y   = GY + (r - 1) * CELL
      local val = grid[r][c]

      if val == 1 then
        love.graphics.setColor(color[1], color[2], color[3])
      else
        love.graphics.setColor(0.18, 0.18, 0.26)
      end
      love.graphics.rectangle("fill", x + 1, y + 1, CELL - 2, CELL - 2)

      if val == 2 then
        love.graphics.setColor(0.68, 0.28, 0.28)
        love.graphics.setLineWidth(2)
        local p = math.max(3, math.floor(CELL * 0.22))
        love.graphics.line(x+p, y+p, x+CELL-p, y+CELL-p)
        love.graphics.line(x+CELL-p, y+p, x+p, y+CELL-p)
        love.graphics.setLineWidth(1)
      end

      love.graphics.setColor(0.28, 0.28, 0.38)
      love.graphics.setLineWidth(1)
      love.graphics.rectangle("line", x, y, CELL, CELL)
    end
  end

  -- Linhas grossas a cada 5 células
  if CELL >= 12 then
    love.graphics.setColor(0.50, 0.50, 0.62)
    love.graphics.setLineWidth(2)
    for i = 0, W, 5 do
      love.graphics.line(GX + i*CELL, GY, GX + i*CELL, GY + H*CELL)
    end
    for i = 0, H, 5 do
      love.graphics.line(GX, GY + i*CELL, GX + W*CELL, GY + i*CELL)
    end
    love.graphics.setLineWidth(1)
  end

  -- Rodapé
  love.graphics.setFont(fonts.small)
  love.graphics.setColor(0.32, 0.32, 0.44)
  love.graphics.print("Toque: vazio→fill→X  Start: próximo  Select: sair", 644, 466)

  -- Overlay de vitória
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
-- Toque simples: cicla vazia(0)→preenchida(1)→X(2)→vazia(0)
-- Arrastar: aplica o mesmo estado definido no primeiro toque

function love.touchpressed(id, x, y)
  if state ~= "playing" then return end
  local r, c = cell_at(x, y)
  if not r then return end

  local key = r * 10000 + c
  local now = love.timer.getTime()
  if cell_stamp[key] and (now - cell_stamp[key]) < DEBOUNCE then return end
  cell_stamp[key] = now

  local new_val = (grid[r][c] + 1) % 3
  set_cell(r, c, new_val)
  drag[id] = { mode = new_val, visited = { [key] = true } }
end

function love.touchmoved(id, x, y)
  local d = drag[id]
  if not d or state ~= "playing" then return end
  local r, c = cell_at(x, y)
  if not r then return end
  local key = r * 10000 + c
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
