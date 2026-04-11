-- Atualizador de Jogos
-- Tela de progresso (640×480) — funciona no RG DS e RG 35XX SP

local W, H = 640, 480

local REPO_URL = "https://github.com/rodigozeus/tetris/archive/refs/heads/master.zip"
local TMP_ZIP  = "/tmp/tetris_update.zip"
local TMP_DIR  = "/tmp/tetris_update_dir"
local PORTS    = "/storage/roms/ports"

-- Paleta
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
local AUTO_CLOSE    = 5
local startup_timer = 0
local STARTUP_DELAY = 0.3

local font_title, font_label, font_small
local worker_thread, channel

-- ── worker thread ──────────────────────────────────────────────────────────────
local WORKER = string.format([[
  local REPO_URL = %q
  local TMP_ZIP  = %q
  local TMP_DIR  = %q
  local PORTS    = %q
  local ch = love.thread.getChannel("progress")

  local function run(cmd)
    os.execute(cmd .. " > /dev/null 2>&1")
  end

  local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
  end

  local function dir_exists(path)
    local ok = os.execute("test -d '" .. path .. "'")
    return ok == 0 or ok == true
  end

  ch:push("downloading")
  run("wget --no-verbose '" .. REPO_URL .. "' -O '" .. TMP_ZIP .. "'")

  if not file_exists(TMP_ZIP) then
    ch:push("error:Falha ao baixar. Verifique a conexão.")
    return
  end

  ch:push("extracting")
  run("rm -rf '" .. TMP_DIR .. "'")
  run("mkdir -p '" .. TMP_DIR .. "'")
  run("unzip '" .. TMP_ZIP .. "' -d '" .. TMP_DIR .. "'")

  if not dir_exists(TMP_DIR .. "/tetris-master") then
    ch:push("error:Falha ao extrair o arquivo.")
    return
  end

  ch:push("installing")
  run("cp -rv '" .. TMP_DIR .. "/tetris-master/.' '" .. PORTS .. "/'")

  ch:push("cleanup")
  run("rm -rf '" .. TMP_ZIP .. "' '" .. TMP_DIR .. "'")

  ch:push("done")
]], REPO_URL, TMP_ZIP, TMP_DIR, PORTS)

-- ── helpers ────────────────────────────────────────────────────────────────────
local function step_index(key)
  for i, s in ipairs(STEPS) do
    if s.key == key then return i end
  end
end

-- ── love callbacks ─────────────────────────────────────────────────────────────
function love.load()
  font_title = love.graphics.newFont(30)
  font_label = love.graphics.newFont(18)
  font_small = love.graphics.newFont(13)

  channel       = love.thread.getChannel("progress")
  worker_thread = love.thread.newThread(WORKER)
  worker_thread:start()
end

function love.update(dt)
  startup_timer = startup_timer + dt
  if startup_timer < STARTUP_DELAY then return end

  fade_alpha = math.min(1, fade_alpha + dt * 2.5)
  spinner_t  = spinner_t + dt

  local msg = channel:pop()
  if msg then
    if msg == "done" then
      current_step = #STEPS + 1
      status = "done"
    elseif msg:sub(1, 5) == "error" then
      status    = "error"
      error_msg = msg:sub(7)
    else
      local idx = step_index(msg)
      if idx then current_step = idx end
    end
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
    if done_timer >= AUTO_CLOSE then
      love.event.quit()
    end
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

function love.draw()
  if startup_timer < STARTUP_DELAY then
    love.graphics.clear(0, 0, 0)
    return
  end

  -- fundo
  love.graphics.setColor(C.bg[1], C.bg[2], C.bg[3])
  love.graphics.rectangle("fill", 0, 0, W, H)

  -- linha superior
  col(C.accent, 0.5)
  love.graphics.setLineWidth(1.5)
  love.graphics.line(60, 56, W - 60, 56)

  -- título
  love.graphics.setFont(font_title)
  col(C.title)
  love.graphics.printf("ATUALIZAR JOGOS", 0, 18, W, "center")

  -- subtítulo
  love.graphics.setFont(font_small)
  col(C.subtitle)
  love.graphics.printf("github.com/rodigozeus/tetris", 0, 64, W, "center")

  -- separador decorativo
  col(C.accent, 0.12)
  love.graphics.rectangle("fill", 60, 78, W - 120, 1)

  -- steps
  local ix = 200
  local lx = 228
  local sy = 138
  local sg = 50

  for i, step in ipairs(STEPS) do
    local y  = sy + (i - 1) * sg
    local iy = y + 10

    local is_error   = (status == "error"  and i == current_step)
    local is_current = (status == "running" and i == current_step)
    local is_done    = (i < current_step) or (status == "done")

    if is_error then
      draw_cross(ix, iy)
      love.graphics.setFont(font_label)
      col(C.error_c)
    elseif is_done then
      draw_check(ix, iy)
      love.graphics.setFont(font_label)
      col(C.done)
    elseif is_current then
      draw_spinner(ix, iy, spinner_t)
      love.graphics.setFont(font_label)
      col(C.current)
    else
      draw_dot_outline(ix, iy)
      love.graphics.setFont(font_label)
      col(C.pending)
    end

    love.graphics.print(step.label, lx, y)
  end

  -- linha inferior
  col(C.accent, 0.25)
  love.graphics.setLineWidth(1)
  love.graphics.line(60, 440, W - 60, 440)

  -- rodapé
  love.graphics.setFont(font_small)
  if status == "done" then
    col(C.done)
    love.graphics.printf(
      "Concluído! Fechando em " .. math.ceil(AUTO_CLOSE - done_timer) .. "s...",
      0, 450, W, "center"
    )
  elseif status == "error" then
    col(C.error_c)
    love.graphics.printf(error_msg, 0, 444, W, "center")
    col(C.subtitle)
    love.graphics.printf("Pressione qualquer botão para sair", 0, 460, W, "center")
  else
    col(C.subtitle, 0.5)
    love.graphics.printf("Aguarde...", 0, 450, W, "center")
  end

  -- crédito
  col(C.subtitle, 0.25)
  love.graphics.printf("Anbernic  ·  Rocknix", 0, 468, W, "center")
end

function love.gamepadpressed()
  if status == "done" or status == "error" then
    love.event.quit()
  end
end

function love.keypressed()
  if status == "done" or status == "error" then
    love.event.quit()
  end
end
