-- Snake para Love2D 11.5 / Anbernic RG DS e RG 35XX SP (640x480)

local CELL      = 20          -- tamanho de cada célula em pixels
local COLS      = 32          -- 640 / 20
local ROWS      = 22          -- área de jogo (deixa 40px no topo para HUD)
local HUD_H     = 40          -- altura do cabeçalho
local TICK      = 0.20        -- segundos por movimento
local SPEED_INC = 0.005       -- redução do tick a cada comida

local state, snake, dir, nextDir, food, score, best, timer, speed, deathTimer, turbo
local snd_eat, snd_die, snd_pause

-- ── áudio procedural ─────────────────────────────────────────────────────────

local function makeSound(fn, duration)
  local RATE    = 44100
  local samples = math.floor(duration * RATE)
  local sd      = love.sound.newSoundData(samples, RATE, 16, 1)
  for i = 0, samples - 1 do
    local t = i / RATE
    local s = fn(t, duration)
    sd:setSample(i, math.max(-1, math.min(1, s)))
  end
  return love.audio.newSource(sd, "static")
end

local function playSound(src)
  src:stop()
  src:seek(0)
  src:play()
end

-- ─── DETECÇÃO DE DEVICE  (A/B normalization) ─────────────────────────────────
local function _is_rg_ds()
  local f = io.open("/proc/device-tree/model", "r")
  if not f then return false end
  local model = f:read("*a"):lower()
  f:close()
  return model:find("rg%-ds") ~= nil
end
local IS_RG_DS = _is_rg_ds()
local function map_btn(b)
  if IS_RG_DS then
    if b == "a" then return "b" end
    if b == "b" then return "a" end
  end
  return b
end

local SAVE_FILE = "best.txt"

local function loadBest()
  if love.filesystem.getInfo(SAVE_FILE) then
    local data = love.filesystem.read(SAVE_FILE)
    return tonumber(data) or 0
  end
  return 0
end

local function saveBest(value)
  love.filesystem.write(SAVE_FILE, tostring(value))
end

-- ── helpers ──────────────────────────────────────────────────────────────────

local function newFood()
  local occupied = {}
  for _, s in ipairs(snake) do
    occupied[s.x .. "," .. s.y] = true
  end
  local candidates = {}
  for x = 1, COLS do
    for y = 1, ROWS do
      if not occupied[x .. "," .. y] then
        candidates[#candidates + 1] = {x = x, y = y}
      end
    end
  end
  if #candidates == 0 then return nil end
  return candidates[love.math.random(#candidates)]
end

local function cellRect(x, y)
  return (x - 1) * CELL, HUD_H + (y - 1) * CELL, CELL, CELL
end

-- ── init / reset ─────────────────────────────────────────────────────────────

local function reset()
  local mx, my = math.floor(COLS / 2), math.floor(ROWS / 2)
  snake   = {{x = mx, y = my}, {x = mx - 1, y = my}, {x = mx - 2, y = my}}
  dir     = {x = 1, y = 0}
  nextDir = {x = 1, y = 0}
  score   = 0
  speed   = TICK
  timer      = 0
  deathTimer = 0
  turbo      = false
  food       = newFood()
  state      = "playing"
end

function love.load()
  love.math.setRandomSeed(os.time())
  best  = loadBest()

  -- chirp ascendente: 330 → 660 Hz, 0.08 s
  snd_eat = makeSound(function(t, dur)
    local freq = 330 + 330 * (t / dur)
    local env  = 1 - t / dur
    return math.sin(2 * math.pi * freq * t) * env * 0.55
  end, 0.08)

  -- queda com ruído: 200 → 40 Hz, 0.45 s
  snd_die = makeSound(function(t, dur)
    local freq = 200 - 160 * (t / dur)
    local env  = 1 - t / dur
    local buzz = math.sin(2 * math.pi * freq * t)
             + 0.3 * math.sin(2 * math.pi * freq * 2.7 * t)
    return buzz * env * 0.5
  end, 0.45)

  -- bip curto neutro para pause/unpause
  snd_pause = makeSound(function(t, dur)
    local env = 1 - t / dur
    return math.sin(2 * math.pi * 480 * t) * env * 0.35
  end, 0.06)

  reset()
end

-- ── update ────────────────────────────────────────────────────────────────────

local function checkCollision(head)
  if head.x < 1 or head.x > COLS or head.y < 1 or head.y > ROWS then
    return true
  end
  for i = 1, #snake - 1 do
    if snake[i].x == head.x and snake[i].y == head.y then
      return true
    end
  end
  return false
end

function love.update(dt)
  -- estado de graça: cobra congelada, jogador pode mudar direção
  if state == "dying" then
    deathTimer = deathTimer + dt
    if deathTimer >= 0.5 then
      local testDir = nextDir
      if testDir.x == -dir.x and testDir.y == -dir.y then
        testDir = dir
      end
      local head = {x = snake[1].x + testDir.x, y = snake[1].y + testDir.y}
      if checkCollision(head) then
        state = "gameover"
        playSound(snd_die)
        if score > best then best = score; saveBest(best) end
      else
        state   = "playing"
        dir     = testDir
        timer   = speed   -- força mover na próxima tick
      end
    end
    return
  end

  if state ~= "playing" then return end

  local tick = turbo and (speed / 2) or speed
  timer = timer + dt
  if timer < tick then return end
  timer = 0

  -- aplica direção pendente (sem inverter 180°)
  if not (nextDir.x == -dir.x and nextDir.y == -dir.y) then
    dir = nextDir
  end

  -- nova cabeça
  local head = {x = snake[1].x + dir.x, y = snake[1].y + dir.y}

  -- colisão com parede ou corpo → entra em graça de 0.5s
  if checkCollision(head) then
    state      = "dying"
    deathTimer = 0
    return
  end

  table.insert(snake, 1, head)

  -- comeu a comida?
  if food and head.x == food.x and head.y == food.y then
    score  = score + 10
    speed  = math.max(0.04, speed - SPEED_INC)
    food   = newFood()
    playSound(snd_eat)
    -- não remove a cauda → cobra cresce
  else
    table.remove(snake)
  end
end

-- ── draw ──────────────────────────────────────────────────────────────────────

function love.draw()
  -- fundo geral
  love.graphics.setColor(0.05, 0.05, 0.05)
  love.graphics.rectangle("fill", 0, 0, 640, 480)

  -- HUD
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.rectangle("fill", 0, 0, 640, HUD_H)
  love.graphics.setColor(0.4, 0.8, 0.4)
  love.graphics.setFont(love.graphics.newFont(22))
  love.graphics.print("SNAKE", 10, 8)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Score: " .. score, 200, 8)
  love.graphics.print("Best: "  .. best,  420, 8)

  -- grade (sutil)
  love.graphics.setColor(0.1, 0.1, 0.1)
  for x = 0, COLS do
    love.graphics.line(x * CELL, HUD_H, x * CELL, HUD_H + ROWS * CELL)
  end
  for y = 0, ROWS do
    love.graphics.line(0, HUD_H + y * CELL, COLS * CELL, HUD_H + y * CELL)
  end

  -- cobra (pisca durante graça de colisão)
  local dyingFlash = state ~= "dying" or (math.floor(deathTimer * 10) % 2 == 0)
  if dyingFlash then
    for i, seg in ipairs(snake) do
      local rx, ry, rw, rh = cellRect(seg.x, seg.y)
      if i == 1 then
        if state == "dying" then
          love.graphics.setColor(1.0, 0.4, 0.1)  -- laranja na graça
        else
          love.graphics.setColor(0.3, 1.0, 0.3)
        end
      else
        local t = 1 - (i / #snake) * 0.5
        if state == "dying" then
          love.graphics.setColor(t * 0.8, t * 0.3, 0.0)
        else
          love.graphics.setColor(0.1, t * 0.8, 0.1)
        end
      end
      love.graphics.rectangle("fill", rx + 1, ry + 1, rw - 2, rh - 2)
    end
  end

  -- comida
  if food then
    local rx, ry, rw, rh = cellRect(food.x, food.y)
    love.graphics.setColor(1.0, 0.25, 0.25)
    love.graphics.circle("fill", rx + rw / 2, ry + rh / 2, rw / 2 - 2)
  end

  -- overlays
  if state == "gameover" then
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("GAME OVER", 0, 160, 640, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Score: " .. score, 0, 230, 640, "center")
    love.graphics.printf("A / Enter  →  Novo jogo",  0, 280, 640, "center")
    love.graphics.printf("Start / Esc  →  Sair",    0, 315, 640, "center")

  elseif state == "paused" then
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, 640, 480)
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("PAUSE", 0, 180, 640, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Start / P  →  Continuar", 0, 260, 640, "center")
  end
end

-- ── helper de direção ────────────────────────────────────────────────────────

local function tryDir(d)
  nextDir = d
  if state == "dying" then
    -- ignora reversão de 180°
    if d.x == -dir.x and d.y == -dir.y then return end
    local head = {x = snake[1].x + d.x, y = snake[1].y + d.y}
    if not checkCollision(head) then
      state = "playing"
      dir   = d
      timer = speed   -- força mover na próxima tick
    end
  end
end

-- ── input (gamepad) ───────────────────────────────────────────────────────────

function love.gamepadpressed(_, button)
  button = map_btn(button)  -- normaliza A/B entre RG DS e RG 35XX SP
  if button == "dpup"    then tryDir({x = 0, y = -1})
  elseif button == "dpdown"  then tryDir({x = 0, y =  1})
  elseif button == "dpleft"  then tryDir({x = -1, y = 0})
  elseif button == "dpright" then tryDir({x =  1, y = 0})
  elseif button == "a" or button == "b" then
    if state == "playing" or state == "dying" then
      turbo = true
    elseif button == "a" and state == "gameover" then
      reset()
    end
  elseif button == "start" then
    if state == "playing"  then state = "paused";  playSound(snd_pause)
    elseif state == "paused"   then state = "playing"; playSound(snd_pause)
    elseif state == "gameover" then love.event.quit()
    end
  elseif button == "back" then
    love.event.quit()
  end
end

function love.gamepadreleased(_, button)
  button = map_btn(button)
  if button == "a" or button == "b" then
    turbo = false
  end
end

-- ── input (teclado – testes no PC) ───────────────────────────────────────────

function love.keypressed(key)
  if key == "up"    or key == "w" then tryDir({x = 0, y = -1})
  elseif key == "down"  or key == "s" then tryDir({x = 0, y =  1})
  elseif key == "left"  or key == "a" then tryDir({x = -1, y = 0})
  elseif key == "right" or key == "d" then tryDir({x =  1, y = 0})
  elseif key == "z" or key == "x" then
    if state == "playing" or state == "dying" then turbo = true end
  elseif key == "return" or key == "space" then
    if state == "playing"  then state = "paused";  playSound(snd_pause)
    elseif state == "paused"   then state = "playing"; playSound(snd_pause)
    elseif state == "gameover" then reset()
    end
  elseif key == "p" then
    if state == "playing" then state = "paused";  playSound(snd_pause)
    elseif state == "paused" then state = "playing"; playSound(snd_pause)
    end
  elseif key == "escape" then
    love.event.quit()
  end
end

function love.keyreleased(key)
  if key == "z" or key == "x" then
    turbo = false
  end
end
