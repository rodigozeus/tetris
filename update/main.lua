-- Atualizador de Jogos
-- Tela esquerda (DSI-2, x 0..639):   painel de progresso
-- Tela direita  (DSI-1, x 640..1279): terminal de instalação
-- No RG 35XX SP (tela única) apenas a tela esquerda é visível.

local W, H  = 640, 480
local OX    = 640   -- offset X da tela direita (terminal)

local REPO_URL = "https://github.com/rodigozeus/tetris/archive/refs/heads/master.zip"
local TMP_ZIP  = "/tmp/tetris_update.zip"
local TMP_DIR  = "/tmp/tetris_update_dir"
local PORTS    = "/storage/roms/ports"

local C = {
  bg       = {0.07, 0.09, 0.14},
  title    = {0.45, 0.82, 1.00},
  subtitle = {0.32, 0.37, 0.48},
  pending  = {0.28, 0.30, 0.40},
  current  = {1.00, 0.88, 0.28},
  done     = {0.28, 0.88, 0.52},
  error_c  = {1.00, 0.28, 0.28},
  accent   = {0.45, 0.82, 1.00},
}

local TC = {
  bg      = {0.00, 0.00, 0.00},
  header  = {0.08, 0.08, 0.08},
  htext   = {0.45, 0.82, 1.00},
  cmd     = {0.28, 1.00, 0.45},
  section = {1.00, 0.88, 0.28},
  text    = {0.90, 0.90, 0.90},
  sep     = {0.15, 0.15, 0.15},
}

local STEPS = {
  { label = "Conectando ao servidor", key = "connecting"  },
  { label = "Baixando atualização",   key = "downloading" },
  { label = "Extraindo arquivos",     key = "extracting"  },
  { label = "Instalando jogos",       key = "installing"  },
  { label = "Finalizando",            key = "cleanup"     },
}

local current_step  = 1
local status        = "running"
local error_msg     = ""
local spinner_t     = 0
local fade_alpha    = 0
local done_timer    = 0
local cursor_blink  = 0
local AUTO_CLOSE    = 5
local startup_timer = 0
local STARTUP_DELAY = 2.0
local worker_started = false

local font_title, font_label, font_small, font_term
local worker_thread, channel, log_channel

local terminal_lines = {}
local MAX_LOG        = 300
local TERM_LINE_H    = 14
local TERM_HEADER_H  = 26
local TERM_PAD_X     = 8
local TERM_PAD_Y     = 6

-- ── worker thread ──────────────────────────────────────────────────────────────
local WORKER = string.format([[
  local REPO_URL = %q
  local TMP_ZIP  = %q
  local TMP_DIR  = %q
  local PORTS    = %q
  local ch     = love.thread.getChannel("progress")
  local log_ch = love.thread.getChannel("log")

  local function log(line) log_ch:push(tostring(line)) end

  local function exec(cmd)
    log("$ " .. cmd)
    local h = io.popen(cmd .. " 2>&1")
    if h then
      for line in h:lines() do
        if line:match("%%S") then log("  " .. line) end
      end
      h:close()
    end
  end

  local function silent(cmd)
    log("$ " .. cmd)
    os.execute(cmd)
  end

  local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
  end

  local function dir_exists(path)
    local ok = os.execute("test -d '" .. path .. "'")
    return ok == 0 or ok == true
  end

  log(">> Iniciando atualização")
  log("")

  ch:push("downloading")
  log(">> Baixando pacote")
  exec("wget --no-verbose '" .. REPO_URL .. "' -O '" .. TMP_ZIP .. "'")
  if not file_exists(TMP_ZIP) then
    ch:push("error:Falha ao baixar. Verifique a conexão.")
    return
  end
  log("")

  ch:push("extracting")
  log(">> Extraindo arquivos")
  silent("rm -rf '" .. TMP_DIR .. "'")
  silent("mkdir -p '" .. TMP_DIR .. "'")
  exec("unzip '" .. TMP_ZIP .. "' -d '" .. TMP_DIR .. "'")
  if not dir_exists(TMP_DIR .. "/tetris-master") then
    ch:push("error:Falha ao extrair o arquivo.")
    return
  end
  log("")

  ch:push("installing")
  log(">> Instalando arquivos em " .. PORTS)
  exec("cp -rv '" .. TMP_DIR .. "/tetris-master/.' '" .. PORTS .. "/'")
  log("")

  ch:push("cleanup")
  log(">> Limpando arquivos temporários")
  silent("rm -rf '" .. TMP_ZIP .. "' '" .. TMP_DIR .. "'")
  log("")

  log(">> Concluído!")
  ch:push("done")
]], REPO_URL, TMP_ZIP, TMP_DIR, PORTS)

-- ── helpers ────────────────────────────────────────────────────────────────────
local function step_index(key)
  for i, s in ipairs(STEPS) do
    if s.key == key then return i end
  end
end

local function push_log(raw)
  local kind
  if     raw:sub(1,2) == "$ "  then kind = "cmd"
  elseif raw:sub(1,2) == ">>"  then kind = "section"
  else                               kind = "out"
  end
  table.insert(terminal_lines, { text = raw, kind = kind })
  if #terminal_lines > MAX_LOG then table.remove(terminal_lines, 1) end
end

-- ── love callbacks ─────────────────────────────────────────────────────────────
function love.load()
  font_title = love.graphics.newFont(30)
  font_label = love.graphics.newFont(18)
  font_small = love.graphics.newFont(13)
  font_term  = love.graphics.newFont(11)

  channel       = love.thread.getChannel("progress")
  log_channel   = love.thread.getChannel("log")
  worker_thread = love.thread.newThread(WORKER)
end

function love.update(dt)
  startup_timer = startup_timer + dt
  if startup_timer < STARTUP_DELAY then return end

  if not worker_started then
    worker_started = true
    worker_thread:start()
  end

  fade_alpha   = math.min(1, fade_alpha + dt * 2.5)
  spinner_t    = spinner_t + dt
  cursor_blink = cursor_blink + dt

  local msg = channel:pop()
  if msg then
    if msg == "done" then
      current_step = #STEPS + 1
      status = "done"
    elseif msg:sub(1,5) == "error" then
      status    = "error"
      error_msg = msg:sub(7)
    else
      local idx = step_index(msg)
      if idx then current_step = idx end
    end
  end

  while true do
    local line = log_channel:pop()
    if not line then break end
    push_log(line)
  end

  if status ~= "done" and not worker_thread:isRunning() then
    local err = worker_thread:getError()
    if err and status ~= "error" then
      status    = "error"
      error_msg = "Erro interno no processo."
    end
  end

  if status == "done" then
    done_timer = done_timer + dt
    if done_timer >= AUTO_CLOSE then love.event.quit() end
  end
end

-- ── desenho ────────────────────────────────────────────────────────────────────
local function col(c, a)
  love.graphics.setColor(c[1], c[2], c[3], (a or 1) * fade_alpha)
end

local function draw_spinner(x, y, t)
  local n = 10
  for i = 1, n do
    local angle = (i / n) * math.pi * 2 + t * 3.5
    local alpha = (i / n) ^ 1.5
    love.graphics.setColor(C.current[1], C.current[2], C.current[3], alpha * fade_alpha)
    love.graphics.circle("fill", x + math.cos(angle) * 9, y + math.sin(angle) * 9, 2.8)
  end
end

local function draw_check(x, y)
  col(C.done)
  love.graphics.setLineWidth(2.5)
  love.graphics.setLineJoin("miter")
  love.graphics.line(x - 8, y, x - 2, y + 7, x + 9, y - 8)
end

local function draw_cross(x, y)
  col(C.error_c)
  love.graphics.setLineWidth(2.5)
  love.graphics.setLineJoin("miter")
  love.graphics.line(x - 6, y - 6, x + 6, y + 6)
  love.graphics.line(x + 6, y - 6, x - 6, y + 6)
end

local function draw_dot_outline(x, y)
  col(C.pending)
  love.graphics.setLineWidth(1.5)
  love.graphics.circle("line", x, y, 7)
end

local function draw_progress_panel()
  local ix = 200
  local lx = 228
  local sy = 138
  local sg = 50

  love.graphics.setColor(C.bg[1], C.bg[2], C.bg[3])
  love.graphics.rectangle("fill", 0, 0, W, H)

  col(C.accent, 0.5)
  love.graphics.setLineWidth(1.5)
  love.graphics.line(60, 56, W - 60, 56)

  love.graphics.setFont(font_title)
  col(C.title)
  love.graphics.printf("ATUALIZAR JOGOS", 0, 18, W, "center")

  love.graphics.setFont(font_small)
  col(C.subtitle)
  love.graphics.printf("github.com/rodigozeus/tetris", 0, 64, W, "center")

  col(C.accent, 0.12)
  love.graphics.rectangle("fill", 60, 78, W - 120, 1)

  for i, step in ipairs(STEPS) do
    local y  = sy + (i - 1) * sg
    local iy = y + 10
    local is_error   = (status == "error"  and i == current_step)
    local is_current = (status == "running" and i == current_step)
    local is_done    = (i < current_step) or (status == "done")

    if is_error then
      draw_cross(ix, iy); love.graphics.setFont(font_label); col(C.error_c)
    elseif is_done then
      draw_check(ix, iy); love.graphics.setFont(font_label); col(C.done)
    elseif is_current then
      draw_spinner(ix, iy, spinner_t); love.graphics.setFont(font_label); col(C.current)
    else
      draw_dot_outline(ix, iy); love.graphics.setFont(font_label); col(C.pending)
    end
    love.graphics.print(step.label, lx, y)
  end

  col(C.accent, 0.25)
  love.graphics.setLineWidth(1)
  love.graphics.line(60, 440, W - 60, 440)

  love.graphics.setFont(font_small)
  if status == "done" then
    col(C.done)
    love.graphics.printf(
      "Concluído! Fechando em " .. math.ceil(AUTO_CLOSE - done_timer) .. "s...",
      0, 450, W, "center")
  elseif status == "error" then
    col(C.error_c)
    love.graphics.printf(error_msg, 0, 444, W, "center")
    col(C.subtitle)
    love.graphics.printf("Pressione qualquer botão para sair", 0, 460, W, "center")
  else
    col(C.subtitle, 0.5)
    love.graphics.printf("Aguarde...", 0, 450, W, "center")
  end

  col(C.subtitle, 0.25)
  love.graphics.printf("Anbernic  ·  Rocknix", 0, 468, W, "center")
end

local function draw_terminal()
  local tx            = OX
  local available_h   = H - TERM_HEADER_H - TERM_PAD_Y * 2
  local max_visible   = math.floor(available_h / TERM_LINE_H)

  love.graphics.setColor(TC.bg[1], TC.bg[2], TC.bg[3])
  love.graphics.rectangle("fill", tx, 0, W, H)

  love.graphics.setColor(TC.header[1], TC.header[2], TC.header[3])
  love.graphics.rectangle("fill", tx, 0, W, TERM_HEADER_H)

  love.graphics.setFont(font_small)
  love.graphics.setColor(TC.htext[1], TC.htext[2], TC.htext[3])
  love.graphics.print("TERMINAL", tx + TERM_PAD_X, 6)

  local status_label
  if status == "done" then
    love.graphics.setColor(TC.cmd[1], TC.cmd[2], TC.cmd[3])
    status_label = "[ concluído ]"
  elseif status == "error" then
    love.graphics.setColor(1, 0.28, 0.28)
    status_label = "[ erro ]"
  else
    if math.floor(cursor_blink * 2) % 2 == 0 then
      love.graphics.setColor(TC.cmd[1], TC.cmd[2], TC.cmd[3])
    else
      love.graphics.setColor(0.3, 0.3, 0.3)
    end
    status_label = "[ executando ]"
  end
  love.graphics.printf(status_label, tx, 6, W - TERM_PAD_X, "right")

  love.graphics.setColor(TC.sep[1], TC.sep[2], TC.sep[3])
  love.graphics.setLineWidth(1)
  love.graphics.line(tx, TERM_HEADER_H, tx + W, TERM_HEADER_H)

  love.graphics.setScissor(tx, TERM_HEADER_H, W, H - TERM_HEADER_H)
  love.graphics.setFont(font_term)

  local start_i = math.max(1, #terminal_lines - max_visible + 1)
  for i = start_i, #terminal_lines do
    local entry = terminal_lines[i]
    local row   = i - start_i
    local lx    = tx + TERM_PAD_X
    local ly    = TERM_HEADER_H + TERM_PAD_Y + row * TERM_LINE_H

    if     entry.kind == "cmd"     then love.graphics.setColor(TC.cmd[1],     TC.cmd[2],     TC.cmd[3])
    elseif entry.kind == "section" then love.graphics.setColor(TC.section[1], TC.section[2], TC.section[3])
    else                                love.graphics.setColor(TC.text[1],    TC.text[2],    TC.text[3])
    end
    love.graphics.print(entry.text, lx, ly)
  end

  if status == "running" then
    local last_row = math.min(#terminal_lines, max_visible)
    local cy = TERM_HEADER_H + TERM_PAD_Y + last_row * TERM_LINE_H + 1
    if math.floor(cursor_blink * 2) % 2 == 0 then
      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("fill", tx + TERM_PAD_X, cy, 7, 2)
    end
  end

  love.graphics.setScissor()

  love.graphics.setColor(TC.sep[1], TC.sep[2], TC.sep[3])
  love.graphics.setLineWidth(1)
  love.graphics.line(tx, 0, tx, H)
end

local function draw_startup()
  love.graphics.setColor(C.bg[1], C.bg[2], C.bg[3])
  love.graphics.rectangle("fill", 0, 0, W, H)

  love.graphics.setColor(C.accent[1], C.accent[2], C.accent[3], 0.5)
  love.graphics.setLineWidth(1.5)
  love.graphics.line(60, 56, W - 60, 56)

  love.graphics.setFont(font_title)
  love.graphics.setColor(C.title[1], C.title[2], C.title[3])
  love.graphics.printf("ATUALIZAR JOGOS", 0, 18, W, "center")

  love.graphics.setFont(font_small)
  love.graphics.setColor(C.subtitle[1], C.subtitle[2], C.subtitle[3])
  love.graphics.printf("github.com/rodigozeus/tetris", 0, 64, W, "center")

  local dots = string.rep(".", math.floor(startup_timer * 3) % 4)
  love.graphics.setFont(font_label)
  love.graphics.setColor(C.current[1], C.current[2], C.current[3])
  love.graphics.printf("Aguardando sistema" .. dots, 0, H / 2 - 12, W, "center")

  love.graphics.setFont(font_small)
  love.graphics.setColor(C.subtitle[1], C.subtitle[2], C.subtitle[3], 0.25)
  love.graphics.printf("Anbernic  ·  Rocknix", 0, 468, W, "center")
end

function love.draw()
  if startup_timer < STARTUP_DELAY then
    draw_startup()
    return
  end
  draw_progress_panel()
  draw_terminal()
end

function love.gamepadpressed()
  if status == "done" or status == "error" then love.event.quit() end
end

function love.keypressed()
  if status == "done" or status == "error" then love.event.quit() end
end
