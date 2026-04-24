-- Zelda PH · Gerenciador de Saves Sancionados
-- Console: Anbernic RG DS  |  Engine: Love2D 11.5
-- Tela superior (DSI-2, x   0.. 639) — info do save selecionado
-- Tela inferior (DSI-1, x 640..1279) — lista de saves + botões (touch)

local SAVES_DIR = "/storage/roms/ports/Sanctioned Saves"
local TARGET    = "/storage/roms/nds/Zelda_PH_PTBR_Dpad_Final.dsv"
local BACKUP    = TARGET .. ".bak"

-- ─── Paleta ────────────────────────────────────────────────────────────────
local C = {
  navy     = {0.03, 0.09, 0.20},
  ocean    = {0.04, 0.15, 0.26},
  teal     = {0.18, 0.74, 0.82},
  teal_d   = {0.09, 0.28, 0.40},
  gold     = {0.96, 0.80, 0.24},
  gold_d   = {0.46, 0.36, 0.10},
  text     = {0.92, 0.96, 1.00},
  dim      = {0.38, 0.52, 0.64},
  sel_bg   = {0.10, 0.32, 0.48},
  green    = {0.22, 0.68, 0.36},
  green_d  = {0.08, 0.32, 0.18},
  amber    = {0.82, 0.58, 0.14},
  amber_d  = {0.38, 0.26, 0.06},
  grey     = {0.16, 0.20, 0.28},
  ok       = {0.16, 0.80, 0.42},
  err      = {0.88, 0.24, 0.20},
}

-- ─── Layout ────────────────────────────────────────────────────────────────
local OX      = 640
local ITEM_H  = 46
local VISIBLE = 6
local LIST_Y  = 48
local BTNS_Y  = LIST_Y + VISIBLE * ITEM_H + 24   -- 348

local BTN = {
  apply   = {x = OX + 12,  y = BTNS_Y, w = 330, h = 70},
  restore = {x = OX + 350, y = BTNS_Y, w = 278, h = 70},
}

-- ─── Estado ────────────────────────────────────────────────────────────────
local STARTUP_DELAY = 0.3
local startup_timer = 0
local INPUT_DELAY   = 0.30
local input_timer   = INPUT_DELAY

local saves         = {}
local cursor        = 1
local scroll_top    = 1
local backup_exists = false
local state         = "loading"   -- loading | menu | applying | done | error
local result_msg    = ""
local result_ok     = true
local done_timer    = 0
local AUTO_CLOSE    = 3.0
local spinner_t     = 0

local worker, ch
local f_title, f_body, f_label, f_small

-- ─── Helpers ───────────────────────────────────────────────────────────────
local function col(c, a)
  love.graphics.setColor(c[1], c[2], c[3], a or 1)
end

local function rrect(x, y, w, h, r, mode)
  love.graphics.rectangle(mode or "fill", x, y, w, h, r or 0, r or 0)
end

local function hit(btn, x, y)
  return x >= btn.x and x < btn.x + btn.w
     and y >= btn.y and y < btn.y + btn.h
end

local function file_exists(p)
  local f = io.open(p, "r")
  if f then f:close(); return true end
  return false
end

local function display_name(filename)
  return (filename:gsub("%.[Dd][Ss][Vv]$", ""))
end

local function scan_saves()
  local list = {}
  local f = io.popen("ls -1 " .. string.format("%q", SAVES_DIR) .. " 2>/dev/null")
  if f then
    for line in f:lines() do
      if line:lower():match("%.dsv$") then
        table.insert(list, line)
      end
    end
    f:close()
  end
  table.sort(list)
  return list
end

local function parse_name(filename)
  if not filename then return nil, "—" end
  local name = display_name(filename)
  local num, desc = name:match("^(%d+)%s*%-%s*(.+)$")
  return num, desc or name
end

local function draw_triforce(cx, cy, sz)
  local h = sz * math.sqrt(3) / 2
  local function tri(x, y)
    love.graphics.polygon("fill",
      x,        y - h * 0.667,
      x - sz/2, y + h * 0.333,
      x + sz/2, y + h * 0.333)
  end
  col(C.gold)
  tri(cx,        cy - h * 0.333)
  tri(cx - sz/2, cy + h * 0.667)
  tri(cx + sz/2, cy + h * 0.667)
end

local function draw_spinner(x, y, t, r)
  local n = 8
  for i = 1, n do
    local a = (i / n) * math.pi * 2 + t * 3.2
    love.graphics.setColor(C.teal[1], C.teal[2], C.teal[3], (i / n) ^ 1.5)
    love.graphics.circle("fill", x + math.cos(a) * r, y + math.sin(a) * r, r * 0.30)
  end
end

-- ─── Ações ─────────────────────────────────────────────────────────────────
local function move_cursor(delta)
  cursor = math.max(1, math.min(#saves, cursor + delta))
  if cursor < scroll_top then
    scroll_top = cursor
  elseif cursor >= scroll_top + VISIBLE then
    scroll_top = cursor - VISIBLE + 1
  end
end

local function do_apply()
  if #saves == 0 or state ~= "menu" then return end
  local src = SAVES_DIR .. "/" .. saves[cursor]
  local code = string.format([[
    local ch  = love.thread.getChannel("save_op")
    local src = %q
    local dst = %q
    local bak = %q
    os.execute("cp '" .. dst .. "' '" .. bak .. "' 2>/dev/null")
    local ok  = os.execute("cp '" .. src .. "' '" .. dst .. "'")
    ch:push((ok == 0 or ok == true) and "ok" or "error:Falha ao copiar o save.")
  ]], src, TARGET, BACKUP)
  worker      = love.thread.newThread(code)
  worker:start()
  state       = "applying"
  input_timer = 0
end

local function do_restore()
  if not backup_exists or state ~= "menu" then return end
  local code = string.format([[
    local ch  = love.thread.getChannel("save_op")
    local bak = %q
    local dst = %q
    local ok  = os.execute("cp '" .. bak .. "' '" .. dst .. "'")
    ch:push((ok == 0 or ok == true) and "ok:restaurado" or "error:Falha ao restaurar o backup.")
  ]], BACKUP, TARGET)
  worker      = love.thread.newThread(code)
  worker:start()
  state       = "applying"
  input_timer = 0
end

-- ─── love.load ─────────────────────────────────────────────────────────────
function love.load()
  f_title = love.graphics.newFont(28)
  f_body  = love.graphics.newFont(20)
  f_label = love.graphics.newFont(17)
  f_small = love.graphics.newFont(14)
  ch      = love.thread.getChannel("save_op")
end

-- ─── love.update ───────────────────────────────────────────────────────────
function love.update(dt)
  startup_timer = startup_timer + dt
  if startup_timer < STARTUP_DELAY then return end

  spinner_t   = spinner_t + dt
  input_timer = input_timer + dt

  if state == "loading" then
    saves         = scan_saves()
    backup_exists = file_exists(BACKUP)
    if #saves == 0 then
      result_msg = "Nenhum save encontrado em:\n" .. SAVES_DIR
      state      = "error"
    else
      state = "menu"
    end
    return
  end

  if state == "applying" then
    local msg = ch:pop()
    if msg then
      result_ok  = msg:sub(1, 2) == "ok"
      result_msg = result_ok
        and (msg == "ok:restaurado" and "Backup restaurado com sucesso!"
                                    or  "Save aplicado! Bom jogo.")
        or  msg:sub(7)
      backup_exists = file_exists(BACKUP)
      done_timer    = 0
      state         = "done"
    elseif not worker:isRunning() then
      result_ok  = false
      result_msg = worker:getError() or "Erro desconhecido."
      done_timer = 0
      state      = "done"
    end
    return
  end

  if state == "done" then
    done_timer = done_timer + dt
    if done_timer >= AUTO_CLOSE then
      state = "menu"
    end
  end
end

-- ─── Tela superior ─────────────────────────────────────────────────────────
local function draw_top()
  col(C.navy)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  -- Header
  col(C.teal_d)
  love.graphics.rectangle("fill", 0, 0, 640, 58)
  col(C.teal, 0.35)
  love.graphics.setLineWidth(1)
  love.graphics.line(0, 58, 640, 58)

  draw_triforce(34, 29, 16)

  love.graphics.setFont(f_title)
  col(C.text)
  love.graphics.print("ZELDA PH", 62, 10)
  love.graphics.setFont(f_small)
  col(C.dim)
  love.graphics.print("Gerenciador de Saves", 64, 38)

  if state == "loading" then
    draw_spinner(320, 240, spinner_t, 18)
    return
  end

  if state == "error" then
    love.graphics.setFont(f_body)
    col(C.err)
    love.graphics.printf(result_msg, 40, 180, 560, "center")
    love.graphics.setFont(f_small)
    col(C.dim)
    love.graphics.printf("Pressione qualquer botão para sair", 0, 448, 640, "center")
    return
  end

  -- Card do save selecionado
  col(C.teal_d)
  rrect(18, 74, 604, 190, 14)
  col(C.teal, 0.18)
  rrect(18, 74, 604, 190, 14, "line")

  local num, desc = parse_name(saves[cursor])

  if num then
    col(C.gold)
    rrect(36, 94, 60, 60, 9)
    love.graphics.setFont(f_title)
    col(C.navy)
    love.graphics.printf(num, 36, 109, 60, "center")

    love.graphics.setFont(f_body)
    col(C.text)
    love.graphics.printf(desc, 108, 128, 498, "left")
  else
    love.graphics.setFont(f_body)
    col(C.text)
    love.graphics.printf(desc, 36, 148, 568, "center")
  end

  love.graphics.setFont(f_small)
  col(C.dim)
  love.graphics.printf(string.format("%d / %d", cursor, #saves), 36, 234, 568, "right")

  -- Painel de status do backup
  col(C.teal_d, 0.55)
  rrect(18, 280, 604, 82, 12)

  love.graphics.setFont(f_small)
  if backup_exists then
    col(C.amber)
    love.graphics.print("Backup disponivel", 36, 296)
    col(C.dim)
    love.graphics.printf(
      "Um save anterior foi guardado. Use 'Restaurar' para desfazer.",
      36, 318, 568, "left"
    )
  else
    col(C.dim)
    love.graphics.printf(
      "Sem backup. O save atual sera guardado automaticamente antes de aplicar.",
      36, 306, 568, "left"
    )
  end

  -- Flash de resultado
  if state == "done" then
    local alpha = 1 - (done_timer / AUTO_CLOSE)
    local fc    = result_ok and C.ok or C.err
    love.graphics.setColor(fc[1], fc[2], fc[3], alpha * 0.90)
    love.graphics.rectangle("fill", 0, 382, 640, 98)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(f_body)
    love.graphics.printf(result_msg, 24, 414, 592, "center")
  end

  -- Spinner de applying
  if state == "applying" then
    col(C.navy, 0.86)
    love.graphics.rectangle("fill", 0, 382, 640, 98)
    draw_spinner(320, 422, spinner_t, 14)
    love.graphics.setFont(f_small)
    col(C.dim)
    love.graphics.printf("Aplicando...", 0, 448, 640, "center")
  end

  -- Hint de navegação
  love.graphics.setFont(f_small)
  col(C.dim, 0.40)
  love.graphics.printf("D-pad ↑↓ navegar   A aplicar", 0, 463, 640, "center")
end

-- ─── Tela inferior ─────────────────────────────────────────────────────────
local function draw_bottom()
  col(C.ocean)
  love.graphics.rectangle("fill", OX, 0, 640, 480)

  -- Header
  col(C.teal_d)
  love.graphics.rectangle("fill", OX, 0, 640, LIST_Y)
  love.graphics.setFont(f_label)
  col(C.teal)
  love.graphics.print("SAVES SANCIONADOS", OX + 16, 14)
  love.graphics.setFont(f_small)
  col(C.dim)
  love.graphics.printf(#saves .. " saves", OX, 14, 628, "right")

  col(C.teal, 0.25)
  love.graphics.setLineWidth(1)
  love.graphics.line(OX, LIST_Y, OX + 640, LIST_Y)

  -- Lista
  for i = 0, VISIBLE - 1 do
    local idx    = scroll_top + i
    if idx > #saves then break end

    local y      = LIST_Y + i * ITEM_H
    local is_sel = (idx == cursor)
    local num, desc = parse_name(saves[idx])

    if is_sel then
      col(C.sel_bg)
      love.graphics.rectangle("fill", OX + 4, y + 3, 632, ITEM_H - 6, 8, 8)
      col(C.teal)
      love.graphics.rectangle("fill", OX + 4, y + 3, 4, ITEM_H - 6, 2, 2)
    end

    if num then
      col(is_sel and C.gold or C.gold_d)
      rrect(OX + 14, y + 9, 28, 28, 5)
      love.graphics.setFont(f_small)
      col(is_sel and C.navy or C.ocean)
      love.graphics.printf(num, OX + 14, y + 15, 28, "center")

      love.graphics.setFont(f_label)
      col(is_sel and C.text or C.dim)
      love.graphics.print(desc, OX + 50, y + 15)
    else
      love.graphics.setFont(f_label)
      col(is_sel and C.text or C.dim)
      love.graphics.print(desc, OX + 14, y + 15)
    end

    if idx < #saves then
      col(C.teal, 0.08)
      love.graphics.line(OX + 14, y + ITEM_H, OX + 626, y + ITEM_H)
    end
  end

  -- Barra de scroll
  if #saves > VISIBLE then
    local bar_y = LIST_Y + VISIBLE * ITEM_H + 8
    col(C.teal, 0.12)
    love.graphics.rectangle("fill", OX + 24, bar_y, 592, 5, 2, 2)
    local tw = math.max(40, 592 * VISIBLE / #saves)
    local tx = OX + 24 + (592 - tw) * (scroll_top - 1) / math.max(1, #saves - VISIBLE)
    col(C.teal, 0.55)
    love.graphics.rectangle("fill", tx, bar_y, tw, 5, 2, 2)
  end

  -- Separador antes dos botões
  col(C.teal, 0.18)
  love.graphics.line(OX + 8, BTNS_Y - 12, OX + 632, BTNS_Y - 12)

  -- Botão Aplicar
  local can_apply = (#saves > 0) and (state == "menu")
  col({0, 0, 0}, 0.18)
  rrect(BTN.apply.x + 2, BTN.apply.y + 3, BTN.apply.w, BTN.apply.h, 12)
  col(can_apply and C.green or C.grey)
  rrect(BTN.apply.x, BTN.apply.y, BTN.apply.w, BTN.apply.h, 12)
  love.graphics.setFont(f_label)
  love.graphics.setColor(1, 1, 1, can_apply and 1 or 0.35)
  love.graphics.printf("Aplicar Save", BTN.apply.x, BTN.apply.y + 26, BTN.apply.w, "center")

  -- Botão Restaurar
  local can_rest = backup_exists and (state == "menu")
  col({0, 0, 0}, 0.18)
  rrect(BTN.restore.x + 2, BTN.restore.y + 3, BTN.restore.w, BTN.restore.h, 12)
  col(can_rest and C.amber or C.grey)
  rrect(BTN.restore.x, BTN.restore.y, BTN.restore.w, BTN.restore.h, 12)
  love.graphics.setFont(f_label)
  love.graphics.setColor(1, 1, 1, can_rest and 1 or 0.35)
  love.graphics.printf("Restaurar\nBackup", BTN.restore.x, BTN.restore.y + 16, BTN.restore.w, "center")

  -- Hint de saída
  love.graphics.setFont(f_small)
  col(C.dim, 0.45)
  love.graphics.printf("START ou SELECT para sair", OX, BTNS_Y + 82, 640, "center")

  -- Overlay de applying
  if state == "applying" then
    col(C.ocean, 0.88)
    love.graphics.rectangle("fill", OX, LIST_Y, 640, 480 - LIST_Y)
    draw_spinner(OX + 320, 290, spinner_t, 16)
    love.graphics.setFont(f_body)
    col(C.dim)
    love.graphics.printf("Aguarde...", OX, 318, 640, "center")
  end
end

-- ─── love.draw ─────────────────────────────────────────────────────────────
function love.draw()
  if startup_timer < STARTUP_DELAY then
    love.graphics.clear(0, 0, 0)
    return
  end

  draw_top()
  if state ~= "loading" then
    draw_bottom()
  end
end

-- ─── Input ─────────────────────────────────────────────────────────────────
local function handle_press(x, y)
  if input_timer < INPUT_DELAY then return end
  if state == "loading" or state == "applying" then return end

  if state == "error" then love.event.quit(); return end
  if state == "done"  then done_timer = AUTO_CLOSE; return end

  -- Toque na lista (tela inferior)
  if x >= OX and x < OX + 640 then
    local ly = y - LIST_Y
    if ly >= 0 and ly < VISIBLE * ITEM_H then
      local tapped = scroll_top + math.floor(ly / ITEM_H)
      if tapped >= 1 and tapped <= #saves then
        cursor      = tapped
        input_timer = 0
      end
      return
    end
    if hit(BTN.apply, x, y)                     then do_apply();  return end
    if hit(BTN.restore, x, y) and backup_exists then do_restore(); return end
  end
end

function love.touchpressed(_, x, y) handle_press(x, y) end
function love.mousepressed(x, y, b) if b == 1 then handle_press(x, y) end end

function love.gamepadpressed(_, button)
  if state == "error"   then love.event.quit(); return end
  if state == "done"    then done_timer = AUTO_CLOSE; return end
  if state ~= "menu"    then return end

  if     button == "dpup"   then move_cursor(-1)
  elseif button == "dpdown" then move_cursor(1)
  elseif button == "b"      then do_apply()    -- físico A
  elseif button == "start" or button == "back" then love.event.quit()
  end
end

function love.keypressed(k)
  if k == "escape" then love.event.quit(); return end
  if state ~= "menu" then return end
  if     k == "up"     then move_cursor(-1)
  elseif k == "down"   then move_cursor(1)
  elseif k == "return" then do_apply()
  end
end
