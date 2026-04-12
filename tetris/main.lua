-- Tetris - Love2D
-- Controles: direcional mover/descer, A/B/cima girar, Start pausar
-- Dispositivos: Anbernic RG DS (A/B invertidos no driver) e RG 35XX SP (padrão)

local CS      = 22    -- tamanho da célula
local COLS    = 10
local ROWS    = 20
local OX      = 110   -- origem X do board
local OY      = 20    -- origem Y do board
local SX      = 345   -- painel de score (X)
local CS_PREV = 16    -- célula na prévia da próxima peça

local COLORS = {
  {0.0, 0.9, 0.9},   -- I  ciano
  {0.9, 0.9, 0.0},   -- O  amarelo
  {0.7, 0.0, 0.9},   -- T  roxo
  {0.0, 0.85, 0.2},  -- S  verde
  {0.9, 0.15, 0.1},  -- Z  vermelho
  {0.1, 0.3, 0.95},  -- J  azul
  {0.95, 0.5, 0.0},  -- L  laranja
}

local SHAPES = {
  {{0,0,0,0},{1,1,1,1},{0,0,0,0},{0,0,0,0}},  -- I
  {{1,1},{1,1}},                                -- O
  {{0,1,0},{1,1,1},{0,0,0}},                   -- T
  {{0,1,1},{1,1,0},{0,0,0}},                   -- S
  {{1,1,0},{0,1,1},{0,0,0}},                   -- Z
  {{1,0,0},{1,1,1},{0,0,0}},                   -- J
  {{0,0,1},{1,1,1},{0,0,0}},                   -- L
}

local function calc_fall_speed(lv)
  return math.max(0.001, (0.8 - (lv-1) * 0.007) ^ (lv-1))
end

local SCORE_TABLE  = {0, 100, 300, 500, 800}
local TSPIN_TABLE  = {400, 800, 1200, 1600}  -- T-Spin 0/1/2/3 linhas × level
local DAS_DELAY   = 0.14
local DAS_REPEAT  = 0.05
local LOCK_DELAY  = 0.5

-- ─── SELETOR DE CARACTERES (naming) ──────────────────────────────────────────

local CHARS_PER_ROW = 9
local CHARS = {}
for c in ("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "):gmatch(".") do
  CHARS[#CHARS+1] = c
end
local CHARS_ROWS = math.ceil(#CHARS / CHARS_PER_ROW)
local CS_CHAR = 28

-- ─── PERSISTÊNCIA ────────────────────────────────────────────────────────────

-- ─── DETECÇÃO DE DEVICE  (A/B normalization) ─────────────────────────────────
-- Ambos os devices reportam o joystick como "retrogame_joypad".
-- Diferenciamos pelo modelo de hardware em /proc/device-tree/model:
--   RG DS      → contém "RG-DS"    (A/B invertidos no driver)
--   RG 35XX SP → contém "RG35XX"   (mapeamento padrão)
-- map_btn troca "a"↔"b" no RG DS para que o código veja sempre
-- "a" = físico A, "b" = físico B.
local function _is_rg_ds()
  local f = io.open("/proc/device-tree/model", "r")
  if not f then return false end
  local model = f:read("*a"):lower()
  f:close()
  return model:find("rg ds") ~= nil
end
local IS_RG_DS = _is_rg_ds()
local function map_btn(b)
  if IS_RG_DS then
    if b == "a" then return "b" end
    if b == "b" then return "a" end
  end
  return b
end

local SAVE_FILE = "tetris_data.txt"

local MAX_SCORES = 10

local DEFAULT_ROTATE   = "a"
local DEFAULT_HARDDROP = "x"

local BTN_LABEL = {
  a="A", b="B", x="X", y="Y",
  leftshoulder="L1", rightshoulder="R1",
  dpup="Cima", dpdown="Baixo", dpleft="Esq", dpright="Dir",
}
local ASSIGNABLE = { a=true, b=true, x=true, y=true,
                     leftshoulder=true, rightshoulder=true }

local users = {
  {name="", rotate_btn=DEFAULT_ROTATE, harddrop_btn=DEFAULT_HARDDROP, ghost_piece=true},
  {name="", rotate_btn=DEFAULT_ROTATE, harddrop_btn=DEFAULT_HARDDROP, ghost_piece=true},
  {name="", rotate_btn=DEFAULT_ROTATE, harddrop_btn=DEFAULT_HARDDROP, ghost_piece=true},
}
local scores = {}  -- {name, score} sorted descending

local function save_data()
  local lines = {}
  for _, u in ipairs(users) do
    local name = (u.name ~= "") and u.name or "_empty_"
    local ghost = (u.ghost_piece ~= false) and "1" or "0"
    lines[#lines+1] = "u:" .. name .. ":" .. u.rotate_btn .. ":" .. u.harddrop_btn .. ":" .. ghost
  end
  for _, s in ipairs(scores) do
    lines[#lines+1] = "s:" .. s.name .. ":" .. tostring(s.score)
  end
  love.filesystem.write(SAVE_FILE, table.concat(lines, "\n"))
end

local function load_data()
  if not love.filesystem.getInfo(SAVE_FILE) then return end
  local content = love.filesystem.read(SAVE_FILE)
  if not content then return end
  local ui = 1
  for line in (content.."\n"):gmatch("([^\n]*)\n") do
    if line:sub(1,2) == "u:" then
      local parts = {}
      for p in (line:sub(3) .. ":"):gmatch("([^:]*):") do parts[#parts+1] = p end
      if ui <= 3 then
        users[ui].name        = (parts[1] == "_empty_" or not parts[1]) and "" or parts[1]
        users[ui].rotate_btn  = parts[2] or DEFAULT_ROTATE
        users[ui].harddrop_btn= parts[3] or DEFAULT_HARDDROP
        users[ui].ghost_piece = (parts[4] ~= "0")
        ui = ui + 1
      end
    elseif line:sub(1,2) == "s:" then
      local rest  = line:sub(3)
      local colon = rest:find(":[^:]*$")
      if colon then
        local name  = rest:sub(1, colon-1)
        local val   = tonumber(rest:sub(colon+1)) or 0
        scores[#scores+1] = {name=name, score=val}
      end
    end
  end
end

local function user_best(user_idx)
  local name = users[user_idx].name
  for _, s in ipairs(scores) do
    if s.name == name then return s.score end
  end
  return 0
end

-- ─── ESTADO ──────────────────────────────────────────────────────────────────

-- gstate: "menu" | "naming" | "level_select" | "playing" | "paused" | "settings" | "over"
local gstate
local board, piece, next_idx, bag
local score, level, total_lines
local fall_timer, fall_speed, lock_timer
local held, das
local back_to_back, last_was_rotation
local current_user
local menu_cursor
local pause_cursor
local over_cursor
local naming_slot
local naming_buf
local naming_row
local naming_col
local new_record_flag
local level_select_val
local start_level
local settings_cursor
local settings_listening

local MAX_START_LEVEL = 15

local fnt_big, fnt_med, fnt_sm
local snd_move, snd_rotate, snd_land, snd_clear, snd_tetris, snd_gameover, snd_fall
local play_snd

-- ─── LÓGICA ──────────────────────────────────────────────────────────────────

local function add_score(pts)
  local name = current_user and users[current_user].name or ""
  if name == "RODRIGO" then
    pts = math.floor(pts * 1.2 + 0.5)
  elseif name == "SIMONE" then
    pts = math.floor(pts * 1.1 + 0.5)
  end
  score = score + pts
end

local function refill_bag()
  bag = {}
  for i = 1, #SHAPES do bag[i] = i end
  for i = #bag, 2, -1 do
    local j = love.math.random(i)
    bag[i], bag[j] = bag[j], bag[i]
  end
end

local function next_from_bag()
  if #bag == 0 then refill_bag() end
  return table.remove(bag)
end


local function rotate_cw(g)
  local R, C = #g, #g[1]
  local t = {}
  for c = 1, C do
    t[c] = {}
    for r = 1, R do t[c][r] = g[R-r+1][c] end
  end
  return t
end

local function fits(grid, col, row)
  for r = 1, #grid do
    for c = 1, #grid[r] do
      if grid[r][c] == 1 then
        local bc = col + c - 1
        local br = row + r - 1
        if bc < 1 or bc > COLS or br > ROWS then return false end
        if br >= 1 and board[br][bc] ~= 0    then return false end
      end
    end
  end
  return true
end

local function lock()
  local top_out = false
  for r = 1, #piece.grid do
    for c = 1, #piece.grid[r] do
      if piece.grid[r][c] == 1 then
        local br = piece.row + r - 1
        local bc = piece.col + c - 1
        if br < 1 then
          top_out = true
        else
          board[br][bc] = piece.color
        end
      end
    end
  end
  return top_out
end

local function clear_lines()
  local n = 0
  local r = ROWS
  while r >= 1 do
    local full = true
    for c = 1, COLS do
      if board[r][c] == 0 then full = false; break end
    end
    if full then
      table.remove(board, r)
      local row = {}
      for c = 1, COLS do row[c] = 0 end
      table.insert(board, 1, row)
      n = n + 1
    else
      r = r - 1
    end
  end
  return n
end

local function check_record()
  new_record_flag = false
  if not current_user or score <= 0 then return end
  local name = users[current_user].name
  local best = user_best(current_user)
  if score > best then new_record_flag = true end
  scores[#scores+1] = {name=name, score=score}
  table.sort(scores, function(a,b) return a.score > b.score end)
  while #scores > MAX_SCORES do table.remove(scores) end
  save_data()
end

local function spawn()
  local idx = next_idx or next_from_bag()
  next_idx = next_from_bag()
  local grid = SHAPES[idx]
  piece = {
    grid  = grid,
    color = idx,
    col   = math.floor((COLS - #grid[1]) / 2) + 1,
    row   = 0,
  }
  lock_timer = nil
  if not fits(piece.grid, piece.col, piece.row) then
    check_record()
    gstate = "over"
    over_cursor = 1
  end
end

local function is_tspin()
  if piece.color ~= 3 then return false end       -- só peça T
  if not last_was_rotation then return false end
  -- Conta quantos dos 4 cantos do bounding 3×3 estão bloqueados
  local corners = 0
  for _, dr in ipairs({0, 2}) do
    for _, dc in ipairs({0, 2}) do
      local br = piece.row + dr
      local bc = piece.col + dc
      if bc < 1 or bc > COLS or br < 1 or br > ROWS or board[br][bc] ~= 0 then
        corners = corners + 1
      end
    end
  end
  return corners >= 3
end

local function resolve_piece_lock()
  local top_out = lock()
  if top_out then
    check_record()
    gstate = "over"
    over_cursor = 1
    play_snd(snd_gameover)
    return
  end

  local tspin = is_tspin()
  local n     = clear_lines()
  total_lines = total_lines + n

  local pts
  if tspin then
    pts = (TSPIN_TABLE[n+1] or 0) * level
  else
    pts = SCORE_TABLE[n+1] * level
  end

  local is_hard = (n == 4) or (tspin and n > 0)
  if back_to_back and is_hard then pts = math.floor(pts * 1.5) end
  if n > 0 then back_to_back = is_hard end

  add_score(pts)
  level      = math.floor(total_lines / 10) + 1
  fall_speed = calc_fall_speed(level)
  last_was_rotation = false
  spawn()
  fall_timer = 0
  if gstate == "over" then
    play_snd(snd_gameover)
  elseif n == 4 or (tspin and n > 0) then
    play_snd(snd_tetris)
  elseif n > 0 then
    play_snd(snd_clear)
  else
    play_snd(snd_land)
  end
end

local function land()
  resolve_piece_lock()
end

local function init_game()
  board = {}
  for r = 1, ROWS do
    board[r] = {}
    for c = 1, COLS do board[r][c] = 0 end
  end
  local sl          = start_level or 1
  score             = 0
  level             = sl
  total_lines       = (sl - 1) * 10
  fall_timer        = 0
  fall_speed        = calc_fall_speed(sl)
  lock_timer        = nil
  held              = {}
  das               = {}
  bag               = {}
  next_idx          = nil
  new_record_flag   = false
  back_to_back      = false
  last_was_rotation = false
  spawn()
  if gstate ~= "over" then gstate = "playing" end
end

local function go_to_menu()
  gstate      = "menu"
  menu_cursor = menu_cursor or 1
end

-- ─── INPUT ───────────────────────────────────────────────────────────────────

local function move(dc)
  if fits(piece.grid, piece.col+dc, piece.row) then
    piece.col         = piece.col + dc
    last_was_rotation = false
    if not fits(piece.grid, piece.col, piece.row+1) then lock_timer = 0 end
    play_snd(snd_move)
  end
end

local function rotate()
  local r = rotate_cw(piece.grid)
  local kicks = {
    {0, 0}, {-1, 0}, {1, 0}, {-2, 0}, {2, 0},
    {0, -1}, {-1, -1}, {1, -1}, {0, 1},
  }
  for _, kick in ipairs(kicks) do
    local dc, dr = kick[1], kick[2]
    if fits(r, piece.col + dc, piece.row + dr) then
      piece.grid        = r
      piece.col         = piece.col + dc
      piece.row         = piece.row + dr
      last_was_rotation = true
      if not fits(piece.grid, piece.col, piece.row+1) then lock_timer = 0 end
      play_snd(snd_rotate)
      return
    end
  end
end

local function hard_drop()
  local dropped = 0
  while fits(piece.grid, piece.col, piece.row+1) do
    piece.row = piece.row + 1
    dropped   = dropped + 1
  end
  add_score(dropped * 2)
  lock_timer        = nil
  resolve_piece_lock()
end

local function clamp_naming_col()
  -- garante que o cursor não aponte para fora do array CHARS
  local max_in_row = #CHARS - (naming_row-1)*CHARS_PER_ROW
  if max_in_row < CHARS_PER_ROW then
    naming_col = math.min(naming_col, max_in_row)
  end
end

local function press_menu(btn)
  if btn == "dpup"   then menu_cursor = menu_cursor > 1 and menu_cursor-1 or 4 end
  if btn == "dpdown" then menu_cursor = menu_cursor < 4 and menu_cursor+1 or 1 end
  if btn == "a" or btn == "start" then
    if menu_cursor == 4 then
      love.event.quit()
    elseif users[menu_cursor].name == "" then
      naming_slot = menu_cursor
      naming_buf  = ""
      naming_row  = 1
      naming_col  = 1
      gstate = "naming"
    else
      current_user     = menu_cursor
      level_select_val = 1
      gstate           = "level_select"
    end
  end
end

local function press_naming(btn)
  if btn == "dpup" then
    naming_row = naming_row > 1 and naming_row-1 or CHARS_ROWS
    clamp_naming_col()
  end
  if btn == "dpdown" then
    naming_row = naming_row < CHARS_ROWS and naming_row+1 or 1
    clamp_naming_col()
  end
  if btn == "dpleft" then
    naming_col = naming_col > 1 and naming_col-1 or CHARS_PER_ROW
    clamp_naming_col()
  end
  if btn == "dpright" then
    naming_col = naming_col < CHARS_PER_ROW and naming_col+1 or 1
    clamp_naming_col()
  end
  if btn == "a" then
    local idx = (naming_row-1)*CHARS_PER_ROW + naming_col
    if idx <= #CHARS and #naming_buf < 10 then
      naming_buf = naming_buf .. CHARS[idx]
    end
  end
  if btn == "b" then
    if #naming_buf > 0 then
      naming_buf = naming_buf:sub(1, -2)
    else
      gstate = "menu"
    end
  end
  if btn == "start" and #naming_buf > 0 then
    local name = naming_buf:match("^%s*(.-)%s*$")
    if #name > 0 then
      users[naming_slot].name = name
      save_data()
      current_user     = naming_slot
      level_select_val = 1
      gstate           = "level_select"
    end
  end
end

local function press_level_select(btn)
  if btn == "dpup" or btn == "dpright" then
    level_select_val = math.min(level_select_val + 1, MAX_START_LEVEL)
  end
  if btn == "dpdown" or btn == "dpleft" then
    level_select_val = math.max(level_select_val - 1, 1)
  end
  if btn == "a" or btn == "start" then
    start_level = level_select_val
    init_game()
  end
  if btn == "b" then
    go_to_menu()
  end
end

local function press_paused(btn)
  if btn == "dpup"   then pause_cursor = pause_cursor > 1 and pause_cursor-1 or 4 end
  if btn == "dpdown" then pause_cursor = pause_cursor < 4 and pause_cursor+1 or 1 end
  if btn == "start"  then gstate = "playing" end
  if btn == "a" then
    if pause_cursor == 1 then
      gstate = "playing"
    elseif pause_cursor == 2 then
      init_game()
      gstate = "playing"
    elseif pause_cursor == 3 then
      settings_cursor    = 1
      settings_listening = nil
      gstate = "settings"
    elseif pause_cursor == 4 then
      go_to_menu()
    end
  end
end

local function press_settings(btn)
  if btn == "start" then gstate = "playing" return end
  if settings_listening then
    if ASSIGNABLE[btn] then
      local u = users[current_user]
      local other_field = (settings_listening == "rotate_btn") and "harddrop_btn" or "rotate_btn"
      if btn ~= u[other_field] then
        u[settings_listening] = btn
        save_data()
        settings_listening = nil
      end
    elseif btn == "b" then
      settings_listening = nil
    end
    return
  end
  if btn == "dpup"   then settings_cursor = settings_cursor > 1 and settings_cursor-1 or 3 end
  if btn == "dpdown" then settings_cursor = settings_cursor < 3 and settings_cursor+1 or 1 end
  if btn == "a" then
    if settings_cursor == 1 then
      settings_listening = "rotate_btn"
    elseif settings_cursor == 2 then
      settings_listening = "harddrop_btn"
    else
      users[current_user].ghost_piece = not users[current_user].ghost_piece
      save_data()
    end
  end
  if btn == "b" then gstate = "paused" end
end

local function press_over(btn)
  if btn == "dpup"   then over_cursor = over_cursor > 1 and over_cursor-1 or 2 end
  if btn == "dpdown" then over_cursor = over_cursor < 2 and over_cursor+1 or 1 end
  if btn == "a" or btn == "start" then
    if over_cursor == 1 then init_game(); gstate = "playing"
    else                     go_to_menu()
    end
  end
end

local function press_playing(btn)
  if btn == "dpleft"  then move(-1); held.left  = true; das.left  = -DAS_DELAY end
  if btn == "dpright" then move(1);  held.right = true; das.right = -DAS_DELAY end
  if btn == "dpdown" then
    held.down = true
    if fits(piece.grid, piece.col, piece.row+1) then
      piece.row  = piece.row + 1
      add_score(1)
      fall_timer = 0
      play_snd(snd_fall)
    end
  end
  local u = current_user and users[current_user]
  local wants_rotate = (btn == "dpup") or (u and btn == u.rotate_btn)
  local wants_hard_drop = (btn == "harddrop") or (u and btn == u.harddrop_btn)
  if wants_rotate then
    rotate()
  elseif wants_hard_drop then
    hard_drop()
  end
  if btn == "start" then gstate = "paused"; pause_cursor = 1; held = {} end
end

local STATE_PRESS_HANDLERS = {
  menu         = press_menu,
  naming       = press_naming,
  level_select = press_level_select,
  paused       = press_paused,
  settings     = press_settings,
  over         = press_over,
  playing      = press_playing,
}

local function press(btn)
  local handler = STATE_PRESS_HANDLERS[gstate]
  if handler then handler(btn) end
end

local function release(btn)
  if held then
    if btn == "dpleft"  then held.left  = false end
    if btn == "dpright" then held.right = false end
    if btn == "dpdown"  then held.down  = false end
  end
end

local KEY_MAP = {
  left="dpleft", right="dpright", up="dpup", down="dpdown",
  z="a", x="b",
  space="harddrop",
  ["return"]="start",
}

function love.keypressed(k)
  if k == "escape" then
    if gstate == "naming" or gstate == "level_select" then
      gstate = "menu"
    elseif gstate == "settings" then
      if settings_listening then settings_listening = nil
      else gstate = "paused" end
    elseif gstate == "playing" then
      gstate = "paused"; pause_cursor = 1; held = {}
    elseif gstate == "paused" then
      gstate = "playing"
    else
      love.event.quit()
    end
    return
  end
  if k == "backspace" and gstate == "naming" then
    if #naming_buf > 0 then naming_buf = naming_buf:sub(1, -2) end
    return
  end
  if KEY_MAP[k] then press(KEY_MAP[k]) end
end

function love.textinput(t)
  if gstate == "naming" and #naming_buf < 10 and t:match("[%a%d ]") then
    naming_buf = naming_buf .. t:upper()
  end
end

function love.keyreleased(k)   if KEY_MAP[k] then release(KEY_MAP[k]) end end
function love.gamepadpressed(_,  b) press(map_btn(b))   end
function love.gamepadreleased(_, b) release(map_btn(b)) end

-- ─── UPDATE ──────────────────────────────────────────────────────────────────

function love.update(dt)
  if gstate ~= "playing" then return end
  for _, dir in ipairs({"left", "right"}) do
    if held[dir] then
      das[dir] = das[dir] + dt
      while das[dir] >= 0 do
        move(dir == "left" and -1 or 1)
        das[dir] = das[dir] - DAS_REPEAT
      end
    end
  end
  local speed = held.down and math.max(0.03, fall_speed * 0.1) or fall_speed
  if fits(piece.grid, piece.col, piece.row+1) then
    lock_timer = nil
    fall_timer = fall_timer + dt
    if fall_timer >= speed then
      fall_timer        = 0
      piece.row         = piece.row + 1
      last_was_rotation = false
      if held.down then add_score(1) end
      play_snd(snd_fall)
    end
  else
    fall_timer = 0
    lock_timer = (lock_timer or 0) + dt
    if lock_timer >= LOCK_DELAY then
      lock_timer = nil
      land()
    end
  end
end

-- ─── DRAW ────────────────────────────────────────────────────────────────────

local function cprint(font, text, y, r, g, b)
  love.graphics.setFont(font)
  love.graphics.setColor(r, g, b)
  love.graphics.print(text, (640 - font:getWidth(text)) / 2, y)
end

local function draw_cell(col, row, ci)
  local x = OX + (col-1)*CS
  local y = OY + (row-1)*CS
  local c = COLORS[ci]
  love.graphics.setColor(c[1], c[2], c[3])
  love.graphics.rectangle("fill", x+1, y+1, CS-2, CS-2, 2)
  love.graphics.setColor(c[1]+0.3, c[2]+0.3, c[3]+0.3, 0.5)
  love.graphics.rectangle("fill", x+2, y+2, CS-4, 5, 1)
end

local function draw_board()
  love.graphics.setColor(0.07, 0.07, 0.12)
  love.graphics.rectangle("fill", OX, OY, COLS*CS, ROWS*CS)
  love.graphics.setColor(0.13, 0.13, 0.2)
  for r = 0, ROWS do love.graphics.line(OX, OY+r*CS, OX+COLS*CS, OY+r*CS) end
  for c = 0, COLS do love.graphics.line(OX+c*CS, OY, OX+c*CS, OY+ROWS*CS) end
  for r = 1, ROWS do
    for c = 1, COLS do
      if board[r][c] ~= 0 then draw_cell(c, r, board[r][c]) end
    end
  end
  if piece then
    -- ghost piece
    local show_ghost = not current_user or (users[current_user].ghost_piece ~= false)
    local ghost_row = piece.row
    while fits(piece.grid, piece.col, ghost_row+1) do ghost_row = ghost_row + 1 end
    if show_ghost and ghost_row ~= piece.row then
      local c = COLORS[piece.color]
      for r = 1, #piece.grid do
        for cc = 1, #piece.grid[r] do
          if piece.grid[r][cc] == 1 then
            local br = ghost_row + r - 1
            local bc = piece.col + cc - 1
            if br >= 1 then
              local x = OX + (bc-1)*CS
              local y = OY + (br-1)*CS
              love.graphics.setColor(c[1]*0.35, c[2]*0.35, c[3]*0.35)
              love.graphics.rectangle("fill", x+1, y+1, CS-2, CS-2, 2)
              love.graphics.setColor(c[1]*0.6, c[2]*0.6, c[3]*0.6)
              love.graphics.rectangle("line", x+1, y+1, CS-2, CS-2, 2)
            end
          end
        end
      end
    end
    -- peça atual
    for r = 1, #piece.grid do
      for c = 1, #piece.grid[r] do
        if piece.grid[r][c] == 1 then
          local br = piece.row + r - 1
          local bc = piece.col + c - 1
          if br >= 1 then draw_cell(bc, br, piece.color) end
        end
      end
    end
  end
  love.graphics.setColor(0.35, 0.35, 0.5)
  love.graphics.rectangle("line", OX, OY, COLS*CS, ROWS*CS)
end

local function draw_next_piece()
  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.55, 0.55, 0.7)
  love.graphics.print("PROXIMA", SX, 148)

  local bx = SX
  local by = 170
  local bw = 4 * CS_PREV
  local bh = 4 * CS_PREV
  love.graphics.setColor(0.07, 0.07, 0.12)
  love.graphics.rectangle("fill", bx, by, bw, bh)
  love.graphics.setColor(0.2, 0.2, 0.35)
  love.graphics.rectangle("line", bx, by, bw, bh)

  if next_idx then
    local grid = SHAPES[next_idx]
    local nc   = COLORS[next_idx]
    for r = 1, #grid do
      for c = 1, #grid[r] do
        if grid[r][c] == 1 then
          local px = bx + (c-1)*CS_PREV + 1
          local py = by + (r-1)*CS_PREV + 1
          love.graphics.setColor(nc[1], nc[2], nc[3])
          love.graphics.rectangle("fill", px, py, CS_PREV-2, CS_PREV-2, 2)
          love.graphics.setColor(nc[1]+0.3, nc[2]+0.3, nc[3]+0.3, 0.5)
          love.graphics.rectangle("fill", px+1, py+1, CS_PREV-4, 4, 1)
        end
      end
    end
  end
end

local function draw_hud()
  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.6, 0.6, 0.88)
  local uname = current_user and users[current_user].name or "?"
  love.graphics.print(uname, SX, 22)

  love.graphics.setColor(0.55, 0.55, 0.7)
  love.graphics.print("SCORE", SX, 55)
  love.graphics.setFont(fnt_med)
  love.graphics.setColor(1, 0.9, 0.2)
  love.graphics.print(tostring(score), SX, 73)
  if back_to_back then
    love.graphics.setFont(fnt_sm)
    love.graphics.setColor(1, 0.55, 0.1)
    love.graphics.print("B2B", SX + 60, 80)
  end

  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.55, 0.55, 0.7)
  love.graphics.print("RECORD", SX, 110)
  love.graphics.setColor(0.8, 0.55, 1)
  love.graphics.print(tostring(current_user and user_best(current_user) or 0), SX, 128)

  draw_next_piece()

  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.55, 0.55, 0.7)
  love.graphics.print("LEVEL", SX, 248)
  love.graphics.setFont(fnt_med)
  love.graphics.setColor(1, 0.9, 0.2)
  love.graphics.print(tostring(level), SX, 266)

  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.55, 0.55, 0.7)
  love.graphics.print("LINHAS", SX, 308)
  love.graphics.setFont(fnt_med)
  love.graphics.setColor(1, 0.9, 0.2)
  love.graphics.print(tostring(total_lines), SX, 326)

end

-- ── Tela: MENU ───────────────────────────────────────────────────────────────

local function draw_menu()
  love.graphics.setColor(0.04, 0.04, 0.08)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  -- Quadro de records
  local rx, ry, rw = 70, 14, 500
  local entry_h    = 23
  local rh         = 38 + math.max(1, #scores) * entry_h
  love.graphics.setColor(0.08, 0.08, 0.18)
  love.graphics.rectangle("fill", rx, ry, rw, rh, 6)
  love.graphics.setColor(0.28, 0.28, 0.5)
  love.graphics.rectangle("line", rx, ry, rw, rh, 6)

  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.65, 0.65, 0.9)
  love.graphics.print("RECORDS", rx+12, ry+8)

  if #scores == 0 then
    love.graphics.setColor(0.35, 0.35, 0.55)
    love.graphics.print("Nenhum recorde ainda", rx+20, ry+34)
  else
    for i, s in ipairs(scores) do
      local ly = ry + 34 + (i-1)*entry_h
      love.graphics.setFont(fnt_sm)
      love.graphics.setColor(0.45, 0.45, 0.7)
      love.graphics.print(i .. ".", rx+12, ly)
      love.graphics.setColor(0.6, 0.6, 0.85)
      love.graphics.print(s.name, rx+38, ly)
      love.graphics.setColor(1, 0.85, 0.15)
      love.graphics.print(tostring(s.score), rx+rw-75, ly)
    end
  end

  -- Separador
  local sep_y = ry + rh + 10
  love.graphics.setColor(0.18, 0.18, 0.32)
  love.graphics.line(70, sep_y, 570, sep_y)

  -- Slots de jogador
  local slot_y0 = sep_y + 14
  local slot_h  = 46
  for i, u in ipairs(users) do
    local name = u.name ~= "" and u.name or "[ vazio ]"
    local ly   = slot_y0 + (i-1)*slot_h
    local sel  = (i == menu_cursor)
    if sel then
      love.graphics.setColor(0.15, 0.15, 0.3)
      love.graphics.rectangle("fill", 130, ly-4, 380, 38, 5)
      love.graphics.setColor(0.38, 0.38, 0.68)
      love.graphics.rectangle("line", 130, ly-4, 380, 38, 5)
    end
    love.graphics.setFont(fnt_med)
    if sel then love.graphics.setColor(1, 1, 0.35)
    else        love.graphics.setColor(0.65, 0.65, 0.85) end
    love.graphics.print(i .. ". " .. name, 148, ly)
  end

  -- Botão Sair
  do
    local ly  = slot_y0 + 3*slot_h
    local sel = (menu_cursor == 4)
    if sel then
      love.graphics.setColor(0.2, 0.07, 0.07)
      love.graphics.rectangle("fill", 130, ly-4, 380, 38, 5)
      love.graphics.setColor(0.68, 0.25, 0.25)
      love.graphics.rectangle("line", 130, ly-4, 380, 38, 5)
    end
    love.graphics.setFont(fnt_med)
    if sel then love.graphics.setColor(1, 0.4, 0.4)
    else        love.graphics.setColor(0.55, 0.35, 0.35) end
    love.graphics.print("Sair", 148, ly)
  end

end

-- ── Tela: NAMING ─────────────────────────────────────────────────────────────

local function draw_naming()
  love.graphics.setColor(0, 0, 0, 0.88)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  cprint(fnt_med, "Nome do Jogador " .. naming_slot, 38, 0.9, 0.9, 1)

  -- Campo do nome
  local fw, fh = 300, 38
  local fx = (640-fw)/2
  local fy = 84
  love.graphics.setColor(0.08, 0.08, 0.18)
  love.graphics.rectangle("fill", fx, fy, fw, fh, 4)
  love.graphics.setColor(0.45, 0.45, 0.78)
  love.graphics.rectangle("line", fx, fy, fw, fh, 4)
  love.graphics.setFont(fnt_med)
  love.graphics.setColor(1, 1, 1)
  local cursor_char = (love.timer.getTime() % 1 < 0.5) and "|" or " "
  love.graphics.print(naming_buf .. cursor_char, fx+10, fy+7)

  -- Grid de caracteres
  local gw  = CHARS_PER_ROW * CS_CHAR
  local gx  = (640-gw)/2
  local gy  = 145

  love.graphics.setFont(fnt_sm)
  for i, ch in ipairs(CHARS) do
    local ci  = i - 1
    local cr  = math.floor(ci / CHARS_PER_ROW) + 1
    local cc  = (ci % CHARS_PER_ROW) + 1
    local cx  = gx + (cc-1)*CS_CHAR
    local cy2 = gy + (cr-1)*CS_CHAR
    local sel = (cr == naming_row and cc == naming_col)
    if sel then
      love.graphics.setColor(0.32, 0.32, 0.62)
      love.graphics.rectangle("fill", cx+1, cy2+1, CS_CHAR-2, CS_CHAR-2, 3)
      love.graphics.setColor(0.58, 0.58, 1)
      love.graphics.rectangle("line", cx+1, cy2+1, CS_CHAR-2, CS_CHAR-2, 3)
      love.graphics.setColor(1, 1, 0.3)
    else
      love.graphics.setColor(0.52, 0.52, 0.72)
    end
    local tw = fnt_sm:getWidth(ch)
    love.graphics.print(ch, cx+(CS_CHAR-tw)/2, cy2+(CS_CHAR-18)/2)
  end

end

-- ── Tela: PAUSE ──────────────────────────────────────────────────────────────

local function draw_pause()
  love.graphics.setColor(0, 0, 0, 0.78)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  cprint(fnt_big, "PAUSADO", 108, 0.9, 0.9, 1)

  local opts = {"Continuar", "Reiniciar", "Configurações", "Voltar ao Menu"}
  for i, opt in ipairs(opts) do
    local sel = (i == pause_cursor)
    local oy  = 215 + (i-1)*55
    if sel then
      cprint(fnt_med, opt, oy, 1, 1, 0.35)
    else
      cprint(fnt_med, opt, oy, 0.6, 0.6, 0.82)
    end
  end

end

-- ── Tela: GAME OVER ──────────────────────────────────────────────────────────

local function draw_gameover()
  love.graphics.setColor(0, 0, 0, 0.78)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  cprint(fnt_big, "GAME OVER", 90, 0.95, 0.2, 0.2)
  cprint(fnt_med, "Score: " .. tostring(score), 162, 1, 0.9, 0.2)

  local base_y = 215
  if new_record_flag then
    cprint(fnt_med, "NOVO RECORD!", 198, 0.3, 1, 0.3)
    base_y = 260
  end

  local opts = {"Reiniciar", "Voltar ao Menu"}
  for i, opt in ipairs(opts) do
    local sel = (i == over_cursor)
    local oy  = base_y + (i-1)*55
    if sel then
      cprint(fnt_med, opt, oy, 1, 1, 0.35)
    else
      cprint(fnt_med, opt, oy, 0.6, 0.6, 0.82)
    end
  end
end

-- ── Tela: SETTINGS ───────────────────────────────────────────────────────────

local function draw_settings()
  love.graphics.setColor(0, 0, 0, 0.88)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  local u = users[current_user]
  cprint(fnt_big, "CONFIGURACOES", 48, 0.9, 0.9, 1)

  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.5, 0.5, 0.75)
  cprint(fnt_sm, "Jogador: " .. (u.name ~= "" and u.name or "?"), 108, 0.5, 0.5, 0.75)

  local rows = {
    {label="GIRAR",      field="rotate_btn",   kind="btn"},
    {label="HARD DROP",  field="harddrop_btn", kind="btn"},
    {label="GHOST PIECE",field="ghost_piece",  kind="toggle"},
  }

  for i, row in ipairs(rows) do
    local sel      = (i == settings_cursor)
    local listen   = sel and settings_listening ~= nil
    local ry       = 148 + (i-1)*72
    local bx, bw, bh = 140, 360, 50

    if sel then
      love.graphics.setColor(0.12, 0.12, 0.28)
      love.graphics.rectangle("fill", bx, ry-6, bw, bh, 6)
      love.graphics.setColor(0.38, 0.38, 0.7)
      love.graphics.rectangle("line", bx, ry-6, bw, bh, 6)
    end

    love.graphics.setFont(fnt_med)
    love.graphics.setColor(sel and 1 or 0.6, sel and 1 or 0.6, sel and 0.35 or 0.82)
    love.graphics.print(row.label, bx+16, ry+6)

    local val_text
    if row.kind == "toggle" then
      local on = (u[row.field] ~= false)
      val_text = on and "[ ON ]" or "[ OFF ]"
      love.graphics.setColor(on and 0.3 or 0.65, on and 1 or 0.4, on and 0.3 or 0.4)
    elseif listen then
      val_text = (love.timer.getTime() % 0.8 < 0.4) and "[ ? ]" or "[   ]"
      love.graphics.setColor(1, 0.7, 0.1)
    else
      val_text = "[" .. (BTN_LABEL[u[row.field]] or u[row.field]) .. "]"
      love.graphics.setColor(sel and 1 or 0.7, sel and 0.85 or 0.7, 0.15)
    end
    local tw = fnt_med:getWidth(val_text)
    love.graphics.print(val_text, bx + bw - tw - 16, ry+6)
  end

end

-- ── Tela: LEVEL SELECT ───────────────────────────────────────────────────────

local function draw_level_select()
  love.graphics.setColor(0.04, 0.04, 0.08)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  cprint(fnt_big, "NIVEL INICIAL", 48, 0.9, 0.9, 1)

  local bw, bh = 320, 80
  local bx = (640 - bw) / 2
  local by = 155
  love.graphics.setColor(0.08, 0.08, 0.18)
  love.graphics.rectangle("fill", bx, by, bw, bh, 8)
  love.graphics.setColor(0.38, 0.38, 0.68)
  love.graphics.rectangle("line", bx, by, bw, bh, 8)

  love.graphics.setFont(fnt_big)
  love.graphics.setColor(1, 0.9, 0.2)
  local lbl = tostring(level_select_val)
  local lw  = fnt_big:getWidth(lbl)
  love.graphics.print(lbl, bx + (bw - lw) / 2, by + 14)

  love.graphics.setFont(fnt_med)
  love.graphics.setColor(0.55, 0.55, 0.88)
  local arrow_y = by + 22
  love.graphics.print("<", bx + 18, arrow_y)
  love.graphics.print(">", bx + bw - 18 - fnt_med:getWidth(">"), arrow_y)

  -- barra de velocidade
  local bar_y = 262
  love.graphics.setFont(fnt_sm)
  love.graphics.setColor(0.55, 0.55, 0.7)
  cprint(fnt_sm, "Velocidade", bar_y, 0.55, 0.55, 0.7)
  local tw = 260
  local tx = (640 - tw) / 2
  love.graphics.setColor(0.1, 0.1, 0.2)
  love.graphics.rectangle("fill", tx, bar_y + 24, tw, 14, 4)
  local frac = (level_select_val - 1) / (MAX_START_LEVEL - 1)
  love.graphics.setColor(0.2 + frac * 0.8, 0.9 - frac * 0.7, 0.2)
  love.graphics.rectangle("fill", tx, bar_y + 24, tw * frac, 14, 4)

end

-- ─── SONS ────────────────────────────────────────────────────────────────────

local function make_tone(freq, dur, shape, vol)
  local rate    = 44100
  local samples = math.max(1, math.floor(rate * dur))
  local sd      = love.sound.newSoundData(samples, rate, 16, 1)
  for i = 0, samples - 1 do
    local t   = i / rate
    local env = 1 - (i / samples)
    local raw
    if shape == "sq" then
      raw = (math.sin(2 * math.pi * freq * t) >= 0) and 1 or -1
    elseif shape == "noise" then
      raw = love.math.random() * 2 - 1
    else
      raw = math.sin(2 * math.pi * freq * t)
    end
    sd:setSample(i, raw * env * (vol or 0.4))
  end
  return love.audio.newSource(sd)
end

local function make_arpeggio(freqs, dur_each, vol)
  local rate    = 44100
  local slen    = math.floor(rate * dur_each)
  local total   = slen * #freqs
  local sd      = love.sound.newSoundData(total, rate, 16, 1)
  for ni, freq in ipairs(freqs) do
    local base = (ni - 1) * slen
    for i = 0, slen - 1 do
      local t   = i / rate
      local env = 1 - (i / slen)
      local v   = math.sin(2 * math.pi * freq * t) * env * (vol or 0.5)
      sd:setSample(base + i, v)
    end
  end
  return love.audio.newSource(sd)
end

play_snd = function(src)
  if src then src:stop(); src:play() end
end

-- ─── LOVE CALLBACKS ──────────────────────────────────────────────────────────

function love.load()
  fnt_big = love.graphics.newFont(42)
  fnt_med = love.graphics.newFont(24)
  fnt_sm  = love.graphics.newFont(18)

  pcall(function()
    snd_move     = make_tone(220,  0.04, "sq",    0.3)
    snd_rotate   = make_tone(330,  0.05, "sq",    0.3)
    snd_land     = make_tone(110,  0.10, "sq",    0.4)
    snd_clear    = make_arpeggio({523, 659, 784},             0.08, 0.45)
    snd_tetris   = make_arpeggio({523, 659, 784, 1047, 1319}, 0.09, 0.5)
    snd_gameover = make_arpeggio({440, 330, 220, 110},        0.12, 0.5)
    snd_fall     = make_tone(180,  0.02, "sq",    0.12)
  end)

  load_data()
  go_to_menu()
end

function love.draw()
  if gstate == "menu" then
    draw_menu()
    return
  end
  if gstate == "naming" then
    draw_menu()
    draw_naming()
    return
  end
  if gstate == "level_select" then
    draw_level_select()
    return
  end
  -- playing / paused / over
  love.graphics.setColor(0.04, 0.04, 0.08)
  love.graphics.rectangle("fill", 0, 0, 640, 480)
  draw_board()
  draw_hud()
  if gstate == "paused"   then draw_pause()    end
  if gstate == "settings" then draw_settings() end
  if gstate == "over"     then draw_gameover() end
end
