-- Touch Test: diagnóstico de resolução e toque

local font_sm
local last_touches = {}  -- lista de toques recentes

function love.load()
  font_sm = love.graphics.newFont(16)
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function love.draw()
  local W = love.graphics.getWidth()
  local H = love.graphics.getHeight()

  love.graphics.setFont(font_sm)

  -- Dimensões reais da janela
  love.graphics.setColor(1, 1, 0)
  love.graphics.print("Janela: " .. W .. " x " .. H, 10, 10)

  -- Linha no meio horizontal
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.line(0, H/2, W, H/2)
  love.graphics.print("y=" .. H/2, 10, H/2 + 4)

  -- Linha em 1/4 e 3/4
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.line(0, H/4, W, H/4)
  love.graphics.print("y=" .. H/4, 10, H/4 + 4)
  love.graphics.line(0, H*3/4, W, H*3/4)
  love.graphics.print("y=" .. math.floor(H*3/4), 10, H*3/4 + 4)

  -- Toques registrados
  love.graphics.setColor(1, 0.4, 0.4)
  love.graphics.print("Toques:", 10, 40)
  for i, t in ipairs(last_touches) do
    love.graphics.print(string.format("  #%d  x=%.0f  y=%.0f", i, t.x, t.y), 10, 40 + i * 20)
    -- marcar posição com um X
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", t.x, t.y, 6)
    love.graphics.setColor(1, 0.4, 0.4)
  end
end

function love.touchpressed(id, x, y)
  table.insert(last_touches, {x=x, y=y})
  if #last_touches > 8 then table.remove(last_touches, 1) end
end

function love.gamepadpressed(_, button)
  if button == "start" then love.event.quit() end
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end
end
