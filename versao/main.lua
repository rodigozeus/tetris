local font

function love.load()
  font = love.graphics.newFont(60)
  love.graphics.setFont(font)
end

function love.draw()
  love.graphics.printf("versão 1", 0, 200, 640, "center")
end

function love.keypressed()
  love.event.quit()
end

function love.gamepadpressed()
  love.event.quit()
end
