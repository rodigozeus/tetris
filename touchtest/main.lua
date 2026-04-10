-- Touch Test: dois botões, um em cada tela, mudam de cor ao toque

local SCREEN_W = 640
local SCREEN_H = 480  -- altura de cada tela

local btn_top = {
  x = SCREEN_W / 2,
  y = SCREEN_H / 2,       -- centro da tela de cima
  w = 200,
  h = 80,
  label = "Tela de Cima",
  color_off = {0.2, 0.4, 0.8},
  color_on  = {0.9, 0.7, 0.1},
  active = false,
}

local btn_bot = {
  x = SCREEN_W / 2,
  y = SCREEN_H + SCREEN_H / 2,  -- centro da tela de baixo
  w = 200,
  h = 80,
  label = "Tela de Baixo",
  color_off = {0.2, 0.7, 0.3},
  color_on  = {0.9, 0.2, 0.5},
  active = false,
}

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
  love.graphics.setFont(love.graphics.newFont(20))
  love.graphics.printf(btn.label, btn.x - btn.w/2, btn.y - 12, btn.w, "center")
end

function love.load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function love.draw()
  -- separador entre as telas
  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.rectangle("fill", 0, SCREEN_H - 2, SCREEN_W, 4)

  draw_button(btn_top)
  draw_button(btn_bot)

  -- debug: coordenadas do último toque
  love.graphics.setColor(0.6, 0.6, 0.6)
  love.graphics.setFont(love.graphics.newFont(14))
  love.graphics.print("Touch Test — toque nos botoes", 10, 10)
  love.graphics.print("Touch Test — toque nos botoes", 10, SCREEN_H + 10)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  if hit(btn_top, x, y) then
    btn_top.active = not btn_top.active
  end
  if hit(btn_bot, x, y) then
    btn_bot.active = not btn_bot.active
  end
end

-- sair com Start ou Escape (teclado no PC)
function love.gamepadpressed(_, button)
  if button == "start" then love.event.quit() end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
  -- simular toque no PC com teclas
  if key == "up"   then btn_top.active = not btn_top.active end
  if key == "down" then btn_bot.active = not btn_bot.active end
end
