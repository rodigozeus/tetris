function love.draw()
  love.graphics.printf("versão 2", 0, 220, 640, "center")
end

function love.keypressed()
  love.event.quit()
end

function love.gamepadpressed()
  love.event.quit()
end
