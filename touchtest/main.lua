-- Touch Test: dois botões, um em cada tela, mudam de cor ao toque
-- Layout: DSI-2 (tela de cima) = x 0..639 | DSI-1 (tela de baixo) = x 640..1279

local btn_top = {
  x = 320, y = 240,          -- centro da tela de cima
  w = 200, h = 80,
  label = "Tela de Cima",
  color_off = {0.2, 0.4, 0.8},
  color_on  = {0.9, 0.7, 0.1},
  active = false,
}

local btn_bot = {
  x = 960, y = 240,          -- centro da tela de baixo (640 + 320)
  w = 200, h = 80,
  label = "Tela de Baixo",
  color_off = {0.2, 0.7, 0.3},
  color_on  = {0.9, 0.2, 0.5},
  active = false,
}

local font_btn, font_sm
local last_touch = ""

local function hit(btn, tx, ty)
  return tx >= btn.x - btn.w/2 and tx <= btn.x + btn.w/2
     and ty >= btn.y - btn.h/2 and ty <= btn.y + btn.h/2
end

local function draw_button(btn)
  local c = btn.active and btn.color_on or btn.color_off
  love.graphics.setColor(c)
  love.graphics.rectangle("fill",
    btn.x - btn.w/2, btn.y - btn.h/2,
    btn.w, btn.h, 12, 12)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font_btn)
  love.graphics.printf(btn.label, btn.x - btn.w/2, btn.y - 12, btn.w, "center")
end

function love.load()
  font_btn = love.graphics.newFont(20)
  font_sm  = love.graphics.newFont(14)
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function love.draw()
  -- separador vertical entre as telas
  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.rectangle("fill", 638, 0, 4, 480)

  draw_button(btn_top)
  draw_button(btn_bot)

  -- debug
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.setFont(font_sm)
  love.graphics.print("Tela de Cima  (DSI-2)", 10, 10)
  love.graphics.print("Tela de Baixo (DSI-1)", 650, 10)
  if last_touch ~= "" then
    love.graphics.setColor(1, 0.6, 0.2)
    love.graphics.print(last_touch, 10, 460)
  end
end

function love.touchpressed(id, x, y)
  last_touch = string.format("touch x=%.0f y=%.0f", x, y)
  if hit(btn_top, x, y) then btn_top.active = not btn_top.active end
  if hit(btn_bot, x, y) then btn_bot.active = not btn_bot.active end
end

function love.gamepadpressed(_, button)
  if button == "start" then love.event.quit() end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
end
