-- KeyMapper: detecta e salva o mapeamento de botões do gamepad
-- Love2D 11.5 / Anbernic RG DS (640x480)

local AXIS_THRESHOLD = 0.5

-- Cada step: key (nome no arquivo), label (texto na tela), type ("button"|"axis"|"any")
-- "any" aceita tanto gamepadpressed quanto gamepadaxis (para L2/R2 que variam por hardware)
local steps = {
  {key = "button_a",      label = "Botão  A",                          type = "button"},
  {key = "button_b",      label = "Botão  B",                          type = "button"},
  {key = "button_x",      label = "Botão  X",                          type = "button"},
  {key = "button_y",      label = "Botão  Y",                          type = "button"},
  {key = "button_start",  label = "Start",                             type = "button"},
  {key = "button_select", label = "Select / Back",                     type = "button"},
  {key = "button_l1",     label = "L1  (ombro esquerdo)",              type = "button"},
  {key = "button_l2",     label = "L2  (gatilho esquerdo)",            type = "any"},
  {key = "button_r1",     label = "R1  (ombro direito)",               type = "button"},
  {key = "button_r2",     label = "R2  (gatilho direito)",             type = "any"},
  {key = "lstick_click",  label = "L-Click  (aperte analógico esq.)",  type = "button"},
  {key = "lstick_x",      label = "L-X  (mova analógico esq. ←→)",    type = "axis"},
  {key = "lstick_y",      label = "L-Y  (mova analógico esq. ↑↓)",    type = "axis"},
  {key = "rstick_click",  label = "R-Click  (aperte analógico dir.)",  type = "button"},
  {key = "rstick_x",      label = "R-X  (mova analógico dir. ←→)",    type = "axis"},
  {key = "rstick_y",      label = "R-Y  (mova analógico dir. ↑↓)",    type = "axis"},
}

local mapping      = {}   -- key → valor detectado
local current      = 1
local state        = "mapping"   -- "mapping" | "done"
local joyName      = "desconhecido"
local font_big, font_med, font_small

-- ── save ──────────────────────────────────────────────────────────────────────

local function saveMapping()
  local lines = {
    "# Mapeamento de botoes gerado pelo KeyMapper",
    "# Dispositivo: " .. joyName,
    "",
    "# Use estes valores em love.gamepadpressed(_, button) ou love.gamepadaxis(_, axis, value)",
    "# Valores prefixados com 'axis:' sao capturados via gamepadaxis",
    "",
  }
  for _, s in ipairs(steps) do
    lines[#lines+1] = s.key .. " = " .. (mapping[s.key] or "NAO_MAPEADO")
  end
  lines[#lines+1] = ""
  lines[#lines+1] = "# D-pad (confirmado correto):"
  lines[#lines+1] = "dpad_up    = dpup"
  lines[#lines+1] = "dpad_down  = dpdown"
  lines[#lines+1] = "dpad_left  = dpleft"
  lines[#lines+1] = "dpad_right = dpright"
  love.filesystem.write("mapeamento.txt", table.concat(lines, "\n"))
end

-- ── load ──────────────────────────────────────────────────────────────────────

function love.load()
  font_big   = love.graphics.newFont(36)
  font_med   = love.graphics.newFont(24)
  font_small = love.graphics.newFont(18)
  local joysticks = love.joystick.getJoysticks()
  if joysticks[1] then joyName = joysticks[1]:getName() end
end

function love.update(dt) end  -- event-driven

-- ── input helpers ─────────────────────────────────────────────────────────────

local function isDpad(b)
  return b == "dpup" or b == "dpdown" or b == "dpleft" or b == "dpright"
end

local function advance(value)
  mapping[steps[current].key] = value
  if current < #steps then
    current = current + 1
  else
    saveMapping()
    state = "done"
  end
end

-- ── gamepad ───────────────────────────────────────────────────────────────────

function love.gamepadpressed(_, button)
  if state == "done" then
    if button == "start" or button == "a" then love.event.quit() end
    return
  end

  -- navegação com d-pad
  if button == "dpup" then
    -- volta um step e limpa os dois (atual e anterior)
    if current > 1 then
      mapping[steps[current].key] = nil
      current = current - 1
      mapping[steps[current].key] = nil
    end
    return
  end
  if button == "dpdown" then
    advance("NAO_MAPEADO")
    return
  end
  if isDpad(button) then return end  -- ignora dpleft/dpright

  local step = steps[current]
  if step.type == "button" or step.type == "any" then
    advance(button)
  end
end

function love.gamepadaxis(_, axis, value)
  if state == "done" then return end
  if math.abs(value) < AXIS_THRESHOLD then return end

  local step = steps[current]
  if step.type == "axis" or step.type == "any" then
    advance("axis:" .. axis)
  end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
end

-- ── draw ──────────────────────────────────────────────────────────────────────

function love.draw()
  -- fundo
  love.graphics.setColor(0.05, 0.05, 0.12)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  -- ── tela de conclusão ──
  if state == "done" then
    love.graphics.setColor(0.15, 0.25, 0.15)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    love.graphics.setColor(0.3, 1, 0.5)
    love.graphics.setFont(font_big)
    love.graphics.printf("MAPEAMENTO SALVO!", 0, 30, 640, "center")

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(font_small)
    love.graphics.printf(love.filesystem.getSaveDirectory() .. "/mapeamento.txt", 0, 82, 640, "center")

    -- lista resultado
    local y = 115
    for _, s in ipairs(steps) do
      local val   = mapping[s.key] or "—"
      local skipped = (val == "NAO_MAPEADO")
      love.graphics.setColor(skipped and {0.6,0.3,0.3} or {0.5,0.9,0.5})
      love.graphics.setFont(font_small)
      love.graphics.printf(string.format("%-18s = %s", s.key, val), 60, y, 520, "left")
      y = y + 19
      if y > 445 then break end
    end

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.printf("Start / A  →  Sair", 0, 458, 640, "center")
    return
  end

  -- ── cabeçalho ──
  love.graphics.setColor(0.1, 0.1, 0.22)
  love.graphics.rectangle("fill", 0, 0, 640, 55)
  love.graphics.setColor(0.6, 0.8, 1)
  love.graphics.setFont(font_med)
  love.graphics.print("KeyMapper  –  " .. joyName, 12, 14)

  -- barra de progresso
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle("fill", 0, 55, 640, 7)
  love.graphics.setColor(0.3, 0.8, 0.4)
  love.graphics.rectangle("fill", 0, 55, 640 * ((current - 1) / #steps), 7)

  -- instrução do step atual
  local step = steps[current]
  love.graphics.setColor(1, 1, 0.4)
  love.graphics.setFont(font_big)
  love.graphics.printf("Pressione:", 0, 100, 640, "center")

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font_big)
  love.graphics.printf(step.label, 0, 148, 640, "center")

  -- hint de tipo
  local hints = {button = "(botão digital)", axis = "(eixo analógico — mova bastante)", any = "(botão ou gatilho analógico)"}
  love.graphics.setColor(0.5, 0.85, 1)
  love.graphics.setFont(font_small)
  love.graphics.printf(hints[step.type] or "", 0, 200, 640, "center")

  -- contador
  love.graphics.setColor(0.45, 0.45, 0.45)
  love.graphics.printf(current .. " / " .. #steps, 0, 225, 640, "center")

  -- histórico dos já mapeados
  local y = 258
  for i = 1, current - 1 do
    local s   = steps[i]
    local val = mapping[s.key] or "—"
    love.graphics.setColor(val == "NAO_MAPEADO" and {0.55,0.3,0.3} or {0.35,0.65,0.35})
    love.graphics.setFont(font_small)
    love.graphics.printf(string.format("%-18s = %s", s.key, val), 40, y, 560, "left")
    y = y + 19
    if y > 450 then break end
  end

  -- rodapé de navegação
  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.setFont(font_small)
  love.graphics.printf("↑ Voltar   ↓ Pular   Esc Sair", 0, 460, 640, "center")
end
