-- Lê Comigo! — Jogo educativo cooperativo de leitura de sílabas
-- Botão A (físico) = confirmar/acertar  →  Love2D "a"  (mapeamento padrão)
-- Supervisor:  R1  →  "rightshoulder"   |   L1  →  "leftshoulder"
-- Teclado (PC): Espaço → A  |  Seta Dir → R1  |  Seta Esq → L1
--
-- Dispositivos suportados:
--   Anbernic RG DS     – driver inverte A/B; map_btn normaliza automaticamente
--   Anbernic RG 35XX SP – mapeamento padrão; sem tela de toque

-- ─────────────────────────────────────────────
--  SÍLABAS
-- ─────────────────────────────────────────────
local SILABAS = {
  "BA","BE","BI","BO","BU",
  "CA","CO","CU",
  "DA","DE","DI","DO","DU",
  "FA","FE","FI","FO","FU",
  "GA","GO","GU",
  "JA","JE","JO","JU",
  "LA","LE","LI","LO","LU",
  "MA","ME","MI","MO","MU",
  "NA","NE","NI","NO","NU",
  "PA","PE","PI","PO","PU",
  "QUE","QUI",
  "RA","RE","RI","RO","RU",
  "SA","SE","SI","SO","SU",
  "TA","TE","TI","TO","TU",
  "VA","VE","VI","VO","VU",
  "ZA","ZE","ZI","ZO","ZU",
}

local SILABAS_GRUPOS = {
  {name="B",  sils={"BA","BE","BI","BO","BU"}},
  {name="C",  sils={"CA","CO","CU"}},
  {name="D",  sils={"DA","DE","DI","DO","DU"}},
  {name="F",  sils={"FA","FE","FI","FO","FU"}},
  {name="G",  sils={"GA","GO","GU"}},
  {name="J",  sils={"JA","JE","JO","JU"}},
  {name="L",  sils={"LA","LE","LI","LO","LU"}},
  {name="M",  sils={"MA","ME","MI","MO","MU"}},
  {name="N",  sils={"NA","NE","NI","NO","NU"}},
  {name="P",  sils={"PA","PE","PI","PO","PU"}},
  {name="QU", sils={"QUE","QUI"}},
  {name="R",  sils={"RA","RE","RI","RO","RU"}},
  {name="S",  sils={"SA","SE","SI","SO","SU"}},
  {name="T",  sils={"TA","TE","TI","TO","TU"}},
  {name="V",  sils={"VA","VE","VI","VO","VU"}},
  {name="Z",  sils={"ZA","ZE","ZI","ZO","ZU"}},
}

-- ─────────────────────────────────────────────
--  ESTADOS
-- ─────────────────────────────────────────────
local S_READING    = "reading"     -- azul   — criança lê
local S_VALIDATING = "validating"  -- amarelo — supervisor avalia
local S_CORRECT    = "correct"     -- verde
local S_WRONG      = "wrong"       -- laranja
local S_STREAK     = "streak"      -- dourado — celebração de sequência
local S_PAUSE      = "pause"       -- menu de pausa
local S_CONFIG     = "config"      -- tela de configurações
local S_SILABAS    = "silabas"     -- submenu escolher sílabas

local STREAK_AT = 5   -- celebra a cada múltiplo deste valor

-- ─────────────────────────────────────────────
--  CORES
-- ─────────────────────────────────────────────
local C = {
  reading    = {0.52, 0.74, 0.95},
  validating = {0.97, 0.89, 0.45},
  correct    = {0.42, 0.82, 0.52},
  wrong      = {0.97, 0.60, 0.28},
  streak     = {0.97, 0.82, 0.18},
  dark       = {0.12, 0.12, 0.18},
  white      = {1, 1, 1},
}

local THEMES = {
  reading = {
    bg_a = {0.18, 0.45, 0.86},
    bg_b = {0.55, 0.83, 0.99},
    panel = {0.95, 0.98, 1.00, 0.92},
    panel_edge = {1.00, 1.00, 1.00, 0.85},
    ink = {0.08, 0.18, 0.34},
    accent = {0.05, 0.48, 0.95},
  },
  validating = {
    bg_a = {0.93, 0.64, 0.18},
    bg_b = {0.99, 0.89, 0.38},
    panel = {1.00, 0.98, 0.90, 0.93},
    panel_edge = {1.00, 0.97, 0.73, 0.85},
    ink = {0.32, 0.20, 0.03},
    accent = {0.95, 0.52, 0.04},
  },
  correct = {
    bg_a = {0.07, 0.62, 0.37},
    bg_b = {0.56, 0.93, 0.65},
    panel = {0.93, 1.00, 0.94, 0.93},
    panel_edge = {0.78, 0.95, 0.81, 0.85},
    ink = {0.04, 0.25, 0.11},
    accent = {0.03, 0.58, 0.21},
  },
  wrong = {
    bg_a = {0.88, 0.34, 0.12},
    bg_b = {0.99, 0.67, 0.30},
    panel = {1.00, 0.95, 0.92, 0.93},
    panel_edge = {1.00, 0.82, 0.72, 0.85},
    ink = {0.34, 0.12, 0.02},
    accent = {0.93, 0.34, 0.08},
  },
  streak = {
    bg_a = {0.98, 0.56, 0.06},
    bg_b = {1.00, 0.86, 0.20},
    panel = {1.00, 0.97, 0.87, 0.93},
    panel_edge = {1.00, 0.92, 0.60, 0.88},
    ink = {0.33, 0.18, 0.01},
    accent = {1.00, 0.57, 0.05},
  },
}

-- ─────────────────────────────────────────────
--  VARIÁVEIS DE JOGO
-- ─────────────────────────────────────────────
local state
local syllable, syllable_idx
local score, combo, best_combo
local timer
local flash_alpha
local syllable_intro_t  -- animação de entrada da sílaba atual
local pending_streak   -- flag: próxima transição dispara celebração
local particles        -- confetes da celebração

-- High score persistente
local high_score           -- carregado do arquivo
local new_record           -- bool: score atual superou o high_score
local record_banner_timer  -- segundos restantes do banner "NOVO RECORDE!"
local RECORD_BANNER_DUR = 2.5
local SAVE_FILE = "highscore.txt"
local CONFIG_FILE = "config.txt"

-- Pausa / Configurações
local state_before_pause
local pause_sel = 1
local PAUSE_ITEMS = {"Retornar", "Configurações", "Sair"}
local config_sel = 1
local CONFIG_ITEMS = {"Escolher Sílabas", "Resetar Recorde", "Voltar"}
local silabas_sel = 1
local silabas_scroll = 0
local reset_confirm = false    -- modal de confirmação de reset
local reset_confirm_sel = 2    -- 1=Sim  2=Não  (padrão: Não)
local reset_confirm_timer = 0
local SILABAS_VISIBLE = 9

-- Grupos ativos de sílabas
local grupos_ativos = {}
local SILABAS_ATIVAS = {}

-- Fontes
local font_syl    -- sílaba principal (enorme)
local font_msg    -- mensagens de feedback
local font_sub    -- subtítulos
local font_hint   -- dicas de controle
local font_feedback -- mensagens grandes de feedback
local font_points   -- pontos/recompensa destacados

-- Sons
local snd_press_a, snd_correct, snd_wrong, snd_combo, snd_streak, snd_record

-- ─────────────────────────────────────────────
--  ÁUDIO SINTÉTICO
-- ─────────────────────────────────────────────
local function make_tone(freq, dur, vol)
  local rate    = 44100
  local n       = math.floor(rate * dur)
  local sd      = love.sound.newSoundData(n, rate, 16, 1)
  for i = 0, n - 1 do
    local t    = i / rate
    local env  = math.min(1, t / 0.008) * math.min(1, (dur - t) / 0.04)
    sd:setSample(i, math.sin(2 * math.pi * freq * t) * env * vol)
  end
  return love.audio.newSource(sd)
end

local function make_arpeggio(freqs, note_dur, vol)
  local rate   = 44100
  local total  = math.floor(rate * note_dur * #freqs)
  local sd     = love.sound.newSoundData(total, rate, 16, 1)
  for fi, freq in ipairs(freqs) do
    local offset = math.floor(rate * note_dur * (fi - 1))
    local n      = math.floor(rate * note_dur)
    for i = 0, n - 1 do
      local t   = i / rate
      local env = math.min(1, t / 0.008) * math.min(1, (note_dur - t) / 0.04)
      local s   = sd:getSample(offset + i) + math.sin(2 * math.pi * freq * t) * env * vol
      sd:setSample(offset + i, math.max(-1, math.min(1, s)))
    end
  end
  return love.audio.newSource(sd)
end

local function make_sequence(notes, vol)
  local rate = 44100
  local total_samples = 0
  for _, note in ipairs(notes) do
    total_samples = total_samples + math.floor(rate * note.dur)
  end

  local sd = love.sound.newSoundData(total_samples, rate, 16, 1)
  local cursor = 0

  for _, note in ipairs(notes) do
    local n = math.floor(rate * note.dur)
    for i = 0, n - 1 do
      local t = i / rate
      local env = math.min(1, t / 0.01) * math.min(1, (note.dur - t) / 0.05)
      local sample = 0

      if note.freq and note.freq > 0 then
        sample = math.sin(2 * math.pi * note.freq * t)
        if note.freq2 then
          sample = sample * 0.7 + math.sin(2 * math.pi * note.freq2 * t) * 0.3
        end
      end

      sd:setSample(cursor + i, sample * env * vol)
    end
    cursor = cursor + n
  end

  return love.audio.newSource(sd)
end

-- ─────────────────────────────────────────────
--  UTILITÁRIOS
-- ─────────────────────────────────────────────
local function play(snd)
  if snd then snd:stop(); snd:play() end
end

local function hue_rgb(h)
  h = h % 1
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local q = 1 - f
  if     i % 6 == 0 then return 1, f, 0
  elseif i % 6 == 1 then return q, 1, 0
  elseif i % 6 == 2 then return 0, 1, f
  elseif i % 6 == 3 then return 0, q, 1
  elseif i % 6 == 4 then return f, 0, 1
  else                    return 1, 0, q
  end
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function rebuild_silabas_ativas()
  SILABAS_ATIVAS = {}
  for i, g in ipairs(SILABAS_GRUPOS) do
    if grupos_ativos[i] then
      for _, s in ipairs(g.sils) do
        table.insert(SILABAS_ATIVAS, s)
      end
    end
  end
  -- Fallback: se tudo desativado, usa tudo
  if #SILABAS_ATIVAS == 0 then
    for _, s in ipairs(SILABAS) do
      table.insert(SILABAS_ATIVAS, s)
    end
  end
end

local function save_config()
  local parts = {}
  for i = 1, #SILABAS_GRUPOS do
    table.insert(parts, grupos_ativos[i] and "1" or "0")
  end
  love.filesystem.write(CONFIG_FILE, table.concat(parts, ","))
end

local function load_config()
  for i = 1, #SILABAS_GRUPOS do grupos_ativos[i] = true end
  local data = love.filesystem.read(CONFIG_FILE)
  if data then
    local i = 1
    for bit in data:gmatch("[^,]+") do
      if i <= #SILABAS_GRUPOS then
        grupos_ativos[i] = (bit == "1")
        i = i + 1
      end
    end
  end
end

local function new_syllable()
  local prev = syllable_idx
  local n = #SILABAS_ATIVAS
  repeat
    syllable_idx = love.math.random(n)
  until syllable_idx ~= prev or n == 1
  syllable = SILABAS_ATIVAS[syllable_idx]
  syllable_intro_t = 0
end

local function set_state(s)
  state = s
  timer = 0
  flash_alpha = 1
end

local function start_reading()
  new_syllable()
  set_state(S_READING)
end

local function spawn_particles()
  particles = {}
  for _ = 1, 28 do
    table.insert(particles, {
      x    = love.math.random(60, 580),
      y    = love.math.random(80, 420),
      vx   = love.math.random(-90, 90),
      vy   = love.math.random(-150, -50),
      life = love.math.random() * 0.6 + 0.7,
      max  = 1.3,
      size = love.math.random(8, 18),
      hue  = love.math.random(),
    })
  end
end

local function load_educational_font(size)
  local candidates = {
    "assets/fonts/Andika-Regular.ttf",
    "assets/fonts/OpenDyslexic-Regular.otf",
    "assets/fonts/OpenDyslexic-Regular.ttf",
    "fonts/Andika-Regular.ttf",
    "fonts/OpenDyslexic-Regular.otf",
    "fonts/OpenDyslexic-Regular.ttf",
  }

  for _, path in ipairs(candidates) do
    if love.filesystem.getInfo(path) then
      local ok, font = pcall(love.graphics.newFont, path, size)
      if ok and font then
        return font
      end
    end
  end

  return love.graphics.newFont(size)
end

-- ─────────────────────────────────────────────
--  DETECÇÃO DE DEVICE  (A/B normalization)
-- ─────────────────────────────────────────────
-- RG DS: driver reporta A/B invertidos (físico A → Love2D "b").
-- map_btn troca "a"↔"b" no RG DS para que o restante do código
-- sempre veja "a" = físico A, "b" = físico B.
local IS_RG_DS = false
local function _detect_js(js)
  if js:getName():upper():find("RG.DS") then IS_RG_DS = true end
end
local function map_btn(b)
  if IS_RG_DS then
    if b == "a" then return "b" end
    if b == "b" then return "a" end
  end
  return b
end
function love.joystickadded(js) _detect_js(js) end

-- ─────────────────────────────────────────────
--  LOVE.LOAD
-- ─────────────────────────────────────────────
function love.load()
  love.math.setRandomSeed(os.time())
  for _, js in ipairs(love.joystick.getJoysticks()) do _detect_js(js) end

  font_syl  = load_educational_font(168)
  font_msg  = load_educational_font(44)
  font_sub  = load_educational_font(28)
  font_hint = load_educational_font(20)
  font_feedback = load_educational_font(62)
  font_points   = load_educational_font(54)

  pcall(function()
    snd_press_a = make_tone(988, 0.08, 0.35)
    snd_correct = make_arpeggio({523, 659, 784}, 0.07, 0.52)
    snd_wrong   = make_sequence({
      {freq = 440, freq2 = 392, dur = 0.07},
      {freq = 330, freq2 = 294, dur = 0.09},
      {freq = 220, freq2 = 196, dur = 0.15},
    }, 0.62)
    snd_combo   = make_arpeggio({659, 784, 988}, 0.06, 0.42)
    snd_streak  = make_sequence({
      {freq = 523, freq2 = 659, dur = 0.08},
      {freq = 659, freq2 = 784, dur = 0.08},
      {freq = 784, freq2 = 988, dur = 0.10},
      {freq = 1047, freq2 = 1319, dur = 0.14},
    }, 0.55)
    snd_record  = make_sequence({
      {freq = 523, freq2 = 659, dur = 0.06},
      {freq = 659, freq2 = 784, dur = 0.06},
      {freq = 784, freq2 = 988, dur = 0.07},
      {freq = 988, freq2 = 1319, dur = 0.08},
      {freq = 1319, freq2 = 1568, dur = 0.16},
    }, 0.60)
  end)

  score        = 0
  combo        = 0
  best_combo   = 0
  syllable_idx = 0
  syllable_intro_t = 1
  pending_streak    = false
  new_record        = false
  record_banner_timer = 0
  reset_confirm_timer = 0

  -- Carrega high score salvo
  local data = love.filesystem.read(SAVE_FILE)
  high_score = tonumber(data) or 0

  -- Carrega configuração de grupos
  load_config()
  rebuild_silabas_ativas()

  start_reading()
end

-- ─────────────────────────────────────────────
--  LOVE.UPDATE
-- ─────────────────────────────────────────────
function love.update(dt)
  -- Timers que correm sempre (inclusive na pausa)
  if record_banner_timer > 0 then
    record_banner_timer = record_banner_timer - dt
  end
  if reset_confirm_timer > 0 then
    reset_confirm_timer = reset_confirm_timer - dt
  end

  if state == S_PAUSE or state == S_CONFIG or state == S_SILABAS then return end

  timer = timer + dt
  syllable_intro_t = math.min(1, (syllable_intro_t or 0) + dt / 0.26)

  -- Decai o flash branco/colorido
  if state == S_CORRECT or state == S_WRONG then
    flash_alpha = math.max(0, 1 - timer / 0.5)
  end

  -- Atualiza confetes
  if particles then
    for _, p in ipairs(particles) do
      p.x    = p.x  + p.vx * dt
      p.y    = p.y  + p.vy * dt
      p.vy   = p.vy + 220 * dt
      p.life = p.life - dt
    end
  end

  -- Transições de estado
  if state == S_CORRECT and timer > 1.3 then
    if pending_streak then
      pending_streak = false
      spawn_particles()
      play(snd_streak)
      set_state(S_STREAK)
    else
      start_reading()
    end

  elseif state == S_STREAK and timer > 2.8 then
    particles = nil
    start_reading()

  elseif state == S_WRONG and timer > 1.1 then
    -- mesma sílaba, tenta de novo
    set_state(S_READING)
  end
end

-- ─────────────────────────────────────────────
--  LÓGICA DE INPUT — jogo
-- ─────────────────────────────────────────────
local function action_press_a()
  if state == S_READING then
    play(snd_press_a)
    set_state(S_VALIDATING)
  end
end

local function action_correct()
  if state ~= S_READING then return end
  combo  = combo + 1
  score  = score + 10 * combo
  if combo > best_combo then best_combo = combo end
  -- Verifica novo recorde
  if score > high_score and not new_record then
    new_record          = true
    record_banner_timer = RECORD_BANNER_DUR
    play(snd_record)
  end
  pending_streak = (combo % STREAK_AT == 0)
  play(snd_correct)
  if combo >= 2 then
    play(snd_combo)
  end
  set_state(S_CORRECT)
end

local function action_wrong()
  if state ~= S_READING then return end
  combo = 0
  play(snd_wrong)
  set_state(S_WRONG)
end

local function quit_game()
  if new_record then
    love.filesystem.write(SAVE_FILE, tostring(score))
  end
  love.event.quit()
end

-- ─────────────────────────────────────────────
--  LÓGICA DE INPUT — pausa / configurações
-- ─────────────────────────────────────────────
local function open_pause()
  state_before_pause = state
  state = S_PAUSE
  pause_sel = 1
end

local function close_pause()
  state = state_before_pause or S_READING
end

local function open_config()
  state = S_CONFIG
  config_sel = 1
  reset_confirm = false
end

local function close_config()
  state = S_PAUSE
end

local function open_silabas()
  state = S_SILABAS
  silabas_sel = 1
  silabas_scroll = 0
end

local function close_silabas()
  state = S_CONFIG
end

local function menu_nav(dir)
  pause_sel = (pause_sel - 1 + dir + #PAUSE_ITEMS) % #PAUSE_ITEMS + 1
end

local function menu_confirm()
  if     pause_sel == 1 then close_pause()
  elseif pause_sel == 2 then open_config()
  elseif pause_sel == 3 then quit_game()
  end
end

local function config_nav(dir)
  if reset_confirm then
    reset_confirm_sel = (reset_confirm_sel - 1 + dir + 2) % 2 + 1
    return
  end
  config_sel = (config_sel - 1 + dir + #CONFIG_ITEMS) % #CONFIG_ITEMS + 1
end

local function config_confirm()
  if reset_confirm then
    if reset_confirm_sel == 1 then
      -- Sim: executa o reset
      high_score = 0
      new_record = false
      record_banner_timer = 0
      love.filesystem.write(SAVE_FILE, "0")
      reset_confirm_timer = 2.0
    end
    reset_confirm = false
    return
  end
  if     config_sel == 1 then open_silabas()
  elseif config_sel == 2 then reset_confirm = true; reset_confirm_sel = 2
  elseif config_sel == 3 then close_config()
  end
end

local function silabas_total() return #SILABAS_GRUPOS + 1 end

local function silabas_nav(dir)
  local total = silabas_total()
  silabas_sel = (silabas_sel - 1 + dir + total) % total + 1
  if silabas_sel <= silabas_scroll then
    silabas_scroll = silabas_sel - 1
  elseif silabas_sel > silabas_scroll + SILABAS_VISIBLE then
    silabas_scroll = silabas_sel - SILABAS_VISIBLE
  end
end

local function silabas_confirm()
  local total = silabas_total()
  if silabas_sel == total then
    close_silabas()
  else
    -- Toggle grupo
    grupos_ativos[silabas_sel] = not grupos_ativos[silabas_sel]
    local any = false
    for i = 1, #SILABAS_GRUPOS do
      if grupos_ativos[i] then any = true; break end
    end
    if not any then grupos_ativos[silabas_sel] = true end
    save_config()
    rebuild_silabas_ativas()
  end
end

-- ─────────────────────────────────────────────
--  LOVE.GAMEPADPRESSED  (console)
-- ─────────────────────────────────────────────
function love.gamepadpressed(_, btn)
  btn = map_btn(btn)  -- normaliza A/B entre RG DS e RG 35XX SP

  if state == S_PAUSE then
    if btn == "dpup"   then menu_nav(-1)   end
    if btn == "dpdown" then menu_nav(1)    end
    if btn == "a"      then menu_confirm() end  -- físico A = confirmar
    if btn == "b"      then close_pause()  end  -- físico B = voltar ao jogo
    if btn == "start"  then close_pause()  end
    return
  end

  if state == S_CONFIG then
    if btn == "dpup"   then config_nav(-1)   end
    if btn == "dpdown" then config_nav(1)    end
    if btn == "dpleft" then config_nav(-1)   end  -- navega opções Sim/Não
    if btn == "dpright"then config_nav(1)    end
    if btn == "a"      then config_confirm() end  -- físico A = confirmar
    if btn == "b"      then                       -- físico B = voltar/cancelar
      if reset_confirm then reset_confirm = false
      else close_config() end
    end
    if btn == "start"  then close_config()   end
    return
  end

  if state == S_SILABAS then
    if btn == "dpup"   then silabas_nav(-1)   end
    if btn == "dpdown" then silabas_nav(1)    end
    if btn == "a"      then silabas_confirm() end  -- físico A = confirmar/marcar
    if btn == "b"      then close_silabas()   end  -- físico B = voltar p/ config
    if btn == "start"  then close_silabas()   end
    return
  end

  if btn == "a" or btn == "rightshoulder" or btn == "dpup"   or btn == "dpright" then action_correct() end  -- A físico / R1 / D↑ / D→
  if btn == "b" or btn == "leftshoulder"  or btn == "dpdown" or btn == "dpleft"  then action_wrong()   end  -- B físico / L1 / D↓ / D←
  if btn == "start"                                          then open_pause()     end
end

-- ─────────────────────────────────────────────
--  LOVE.KEYPRESSED  (teclado — testes no PC)
-- ─────────────────────────────────────────────
function love.keypressed(key)
  if state == S_PAUSE then
    if key == "up"                       then menu_nav(-1)   end
    if key == "down"                     then menu_nav(1)    end
    if key == "space" or key == "return" then menu_confirm() end
    if key == "escape" or key == "backspace" then close_pause() end
    return
  end

  if state == S_CONFIG then
    if key == "up"   or key == "down"  then
      config_nav(key == "up" and -1 or 1)
    end
    if key == "left" or key == "right" then  -- navega Sim/Não
      config_nav(key == "left" and -1 or 1)
    end
    if key == "space" or key == "return" then config_confirm() end
    if key == "escape" or key == "backspace" then
      if reset_confirm then reset_confirm = false
      else close_config() end
    end
    return
  end

  if state == S_SILABAS then
    if key == "up"                           then silabas_nav(-1)   end
    if key == "down"                         then silabas_nav(1)    end
    if key == "space" or key == "return"     then silabas_confirm() end
    if key == "escape" or key == "backspace" then close_silabas()   end
    return
  end

  if key == "space" or key == "right" or key == "up"   then action_correct() end
  if key == "left"  or key == "down"                   then action_wrong()   end
  if key == "escape"                                   then open_pause()     end
end

-- ─────────────────────────────────────────────
--  RENDERIZAÇÃO — helpers
-- ─────────────────────────────────────────────
local W, H = 640, 480
local PANEL_X, PANEL_Y = 28, 60
local PANEL_W, PANEL_H = W - 56, H - 76

local function active_theme()
  local s = (state == S_PAUSE or state == S_CONFIG or state == S_SILABAS)
            and (state_before_pause or S_READING)
            or state
  return THEMES[s] or THEMES.reading
end

local function draw_gradient_bg(theme)
  local shift = 0.5 + 0.5 * math.sin(love.timer.getTime() * 0.55)
  for y = 0, H, 4 do
    local t = y / H
    t = math.min(1, math.max(0, t * 0.88 + shift * 0.12))
    local r = lerp(theme.bg_a[1], theme.bg_b[1], t)
    local g = lerp(theme.bg_a[2], theme.bg_b[2], t)
    local b = lerp(theme.bg_a[3], theme.bg_b[3], t)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", 0, y, W, 4)
  end
end

local function draw_atmosphere(theme)
  local t = love.timer.getTime()
  love.graphics.setColor(theme.panel_edge[1], theme.panel_edge[2], theme.panel_edge[3], 0.11)
  love.graphics.circle("fill", 110 + math.sin(t * 0.7) * 20, 80 + math.cos(t * 0.9) * 12, 78)
  love.graphics.circle("fill", 540 + math.cos(t * 0.6) * 22, 90 + math.sin(t * 0.5) * 16, 94)
  love.graphics.circle("fill", 500 + math.sin(t * 0.4) * 30, 400 + math.cos(t * 0.8) * 16, 120)
end

local function center_text(font, text, y, r, g, b, a)
  love.graphics.setFont(font)
  love.graphics.setColor(r or 0, g or 0, b or 0, a or 1)
  local tw = font:getWidth(text)
  love.graphics.print(text, (W - tw) / 2, y)
end

local function draw_panel(theme)
  love.graphics.setColor(0, 0, 0, 0.16)
  love.graphics.rectangle("fill", PANEL_X + 3, PANEL_Y + 7, PANEL_W, PANEL_H, 28, 28)

  love.graphics.setColor(theme.panel)
  love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_W, PANEL_H, 26, 26)

  love.graphics.setLineWidth(2)
  love.graphics.setColor(theme.panel_edge)
  love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_W, PANEL_H, 26, 26)
end

local function draw_hud(theme)
  love.graphics.setColor(0, 0, 0, 0.18)
  love.graphics.rectangle("fill", 0, 0, W, 52)

  love.graphics.setFont(font_hint)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("PONTOS: " .. score, 14, 16)

  if combo > 0 then
    love.graphics.setColor(theme.accent)
    local cs = "COMBO  x" .. combo
    love.graphics.print(cs, W / 2 - font_hint:getWidth(cs) / 2, 16)
  end

  -- Recorde: dourado se está sendo batido agora, cinza se é o histórico
  local rec_label = "RECORDE: " .. (new_record and score or high_score)
  if new_record then
    love.graphics.setColor(1, 0.85, 0.15)
  else
    love.graphics.setColor(0.75, 0.75, 0.75)
  end
  love.graphics.print(rec_label, W - font_hint:getWidth(rec_label) - 14, 16)
end

local function draw_combo_meter(theme)
  local bx, by = PANEL_X + 34, PANEL_Y + 28
  local bw, bh = PANEL_W - 68, 16
  local progress = (combo % STREAK_AT) / STREAK_AT
  local target = STREAK_AT - (combo % STREAK_AT)
  if target == 0 then target = STREAK_AT end

  love.graphics.setColor(0, 0, 0, 0.22)
  love.graphics.rectangle("fill", bx, by, bw, bh, 10, 10)

  local fill_w = math.floor((bw - 4) * progress)
  if fill_w > 0 then
    local glow = 0.65 + 0.35 * math.abs(math.sin(love.timer.getTime() * 4.5))
    love.graphics.setColor(theme.accent[1], theme.accent[2], theme.accent[3], glow)
    love.graphics.rectangle("fill", bx + 2, by + 2, fill_w, bh - 4, 8, 8)
  end

  love.graphics.setFont(font_hint)
  love.graphics.setColor(theme.ink[1], theme.ink[2], theme.ink[3], 0.9)
  local txt = "Meta de festa: " .. target .. " acerto(s)"
  love.graphics.print(txt, PANEL_X + 36, by + 20)
end

local function draw_record_banner()
  if record_banner_timer <= 0 then return end
  local alpha  = math.min(1, record_banner_timer / 0.4)
  local pulse  = 0.75 + 0.25 * math.abs(math.sin(love.timer.getTime() * 6))

  love.graphics.setColor(0.95, 0.80, 0.05, alpha * 0.88)
  love.graphics.rectangle("fill", 0, H - 90, W, 52)

  love.graphics.setFont(font_msg)
  love.graphics.setColor(0.1, 0.05, 0, alpha * pulse)
  local txt = "NOVO RECORDE!"
  love.graphics.print(txt, (W - font_msg:getWidth(txt)) / 2, H - 82)
end

local function draw_syllable_centered(theme, scale)
  scale = scale or 1
  local intro = syllable_intro_t or 1
  local intro_scale = 0.78 + 0.22 * intro
  local alpha = 0.45 + 0.55 * intro
  scale = scale * intro_scale
  local bob = math.sin(love.timer.getTime() * 2.8) * 3
  local tw = font_syl:getWidth(syllable)
  local th = font_syl:getHeight()
  local area_x = PANEL_X + 24
  local area_y = PANEL_Y + 74
  local area_w = PANEL_W - 48
  local area_h = PANEL_H - 108
  local center_x = area_x + area_w / 2
  local center_y = area_y + area_h / 2 + 10
  local sx = center_x / scale - tw / 2
  local sy = center_y / scale - th / 2 + bob
  love.graphics.setFont(font_syl)

  love.graphics.setColor(0, 0, 0, 0.20 * alpha)
  love.graphics.push()
  love.graphics.translate(center_x, center_y)
  love.graphics.scale(scale, scale)
  love.graphics.translate(-center_x, -center_y)
  love.graphics.print(syllable, sx + 3, sy + 4)
  love.graphics.pop()

  love.graphics.setColor(theme.ink[1], theme.ink[2], theme.ink[3], alpha)
  love.graphics.push()
  love.graphics.translate(center_x, center_y)
  love.graphics.scale(scale, scale)
  love.graphics.translate(-center_x, -center_y)
  love.graphics.print(syllable, sx, sy)
  love.graphics.pop()
end

local function draw_button_icon(theme, x, y, w, h, label)
  love.graphics.setColor(0, 0, 0, 0.15)
  love.graphics.rectangle("fill", x + 2, y + 3, w, h, 12, 12)

  love.graphics.setColor(theme.accent[1], theme.accent[2], theme.accent[3], 0.88)
  love.graphics.rectangle("fill", x, y, w, h, 12, 12)

  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, w, h, 12, 12)

  love.graphics.setFont(font_hint)
  love.graphics.setColor(1, 1, 1)
  local tw = font_hint:getWidth(label)
  local th = font_hint:getHeight()
  love.graphics.print(label, x + (w - tw) / 2, y + (h - th) / 2 - 1)
end

local function draw_footer_strip(theme)
  love.graphics.setColor(theme.panel[1], theme.panel[2], theme.panel[3], 0.78)
  love.graphics.rectangle("fill", 26, FOOTER_Y - 6, W - 52, 54, 18, 18)

  love.graphics.setColor(theme.panel_edge[1], theme.panel_edge[2], theme.panel_edge[3], 0.65)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", 26, FOOTER_Y - 6, W - 52, 54, 18, 18)
end

local function draw_reading_prompt(theme)
  local y = FOOTER_Y
  love.graphics.setFont(font_sub)
  love.graphics.setColor(theme.ink[1], theme.ink[2], theme.ink[3], 0.82)
  local txt = "Leia em voz alta e pressione"
  local button_w = 44
  local gap = 12
  local text_w = font_sub:getWidth(txt)
  local total_w = text_w + gap + button_w
  local start_x = (W - total_w) / 2

  love.graphics.print(txt, start_x, y + 2)
  draw_button_icon(theme, start_x + text_w + gap, y, button_w, 34, "A")
end

local function draw_validation_controls(theme)
  love.graphics.setFont(font_hint)
  local y = FOOTER_Y
  local button_w = 52
  local gap = 10

  local left_text = "Correto"
  local left_text_w = font_hint:getWidth(left_text)
  local left_total_w = button_w + gap + left_text_w
  local left_start_x = W * 0.25 - left_total_w / 2

  draw_button_icon(theme, left_start_x, y, button_w, 34, "R1")
  love.graphics.setColor(1, 1, 1, 0.55)
  love.graphics.print(left_text, left_start_x + button_w + gap + 1, y + 9)
  love.graphics.setColor(C.dark[1], C.dark[2], C.dark[3], 0.98)
  love.graphics.print(left_text, left_start_x + button_w + gap, y + 8)

  local right_text = "Tentar de novo"
  local right_text_w = font_hint:getWidth(right_text)
  local right_total_w = button_w + gap + right_text_w
  local right_start_x = W * 0.75 - right_total_w / 2

  draw_button_icon(theme, right_start_x, y, button_w, 34, "L1")
  love.graphics.setColor(1, 1, 1, 0.55)
  love.graphics.print(right_text, right_start_x + button_w + gap + 1, y + 9)
  love.graphics.setColor(C.dark[1], C.dark[2], C.dark[3], 0.98)
  love.graphics.print(right_text, right_start_x + button_w + gap, y + 8)
end

-- ─────────────────────────────────────────────
--  RENDERIZAÇÃO — menu de pausa
-- ─────────────────────────────────────────────
local function draw_pause_menu()
  -- Overlay escuro
  love.graphics.setColor(0, 0, 0, 0.62)
  love.graphics.rectangle("fill", 0, 0, W, H)

  -- Painel central
  local pw, ph = 300, 230
  local px, py = (W - pw) / 2, (H - ph) / 2

  love.graphics.setColor(0, 0, 0, 0.22)
  love.graphics.rectangle("fill", px + 4, py + 6, pw, ph, 20, 20)

  love.graphics.setColor(0.11, 0.14, 0.24, 0.97)
  love.graphics.rectangle("fill", px, py, pw, ph, 18, 18)

  love.graphics.setColor(0.50, 0.62, 0.90, 0.70)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", px, py, pw, ph, 18, 18)

  -- Título
  love.graphics.setFont(font_msg)
  love.graphics.setColor(1, 1, 1)
  local title = "PAUSA"
  love.graphics.print(title, px + (pw - font_msg:getWidth(title)) / 2, py + 16)

  -- Separador
  love.graphics.setColor(0.45, 0.55, 0.80, 0.45)
  love.graphics.setLineWidth(1)
  love.graphics.line(px + 20, py + 64, px + pw - 20, py + 64)

  -- Itens do menu
  love.graphics.setFont(font_sub)
  for i, item in ipairs(PAUSE_ITEMS) do
    local iy = py + 76 + (i - 1) * 46
    if i == pause_sel then
      love.graphics.setColor(0.28, 0.46, 0.88, 0.68)
      love.graphics.rectangle("fill", px + 14, iy - 5, pw - 28, 38, 8, 8)
      love.graphics.setColor(1, 1, 1)
    else
      love.graphics.setColor(0.70, 0.78, 0.96)
    end
    love.graphics.print(item, px + (pw - font_sub:getWidth(item)) / 2, iy)
  end

  -- Dica de controle
  love.graphics.setFont(font_hint)
  love.graphics.setColor(0.45, 0.52, 0.72)
  local hint = "Start: voltar ao jogo"
  love.graphics.print(hint, px + (pw - font_hint:getWidth(hint)) / 2, py + ph - 26)
end

-- ─────────────────────────────────────────────
--  RENDERIZAÇÃO — tela de configurações
-- ─────────────────────────────────────────────
local function draw_screen_header(title_text)
  love.graphics.setColor(0.09, 0.11, 0.19)
  love.graphics.rectangle("fill", 0, 0, W, H)
  love.graphics.setColor(0.13, 0.16, 0.28)
  love.graphics.rectangle("fill", 0, 0, W, 60)
  love.graphics.setFont(font_msg)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(title_text, (W - font_msg:getWidth(title_text)) / 2, 10)
  love.graphics.setColor(0.40, 0.50, 0.72, 0.55)
  love.graphics.setLineWidth(1)
  love.graphics.line(20, 60, W - 20, 60)
end

local function draw_config_menu()
  draw_screen_header("CONFIGURAÇÕES")

  local item_h = 52
  local list_y = 90
  local cx     = W / 2

  for i, item in ipairs(CONFIG_ITEMS) do
    local iy = list_y + (i - 1) * item_h
    local selected = (i == config_sel) and not reset_confirm

    if selected then
      love.graphics.setColor(0.24, 0.40, 0.80, 0.60)
      love.graphics.rectangle("fill", 60, iy - 6, W - 120, item_h - 4, 10, 10)
    end

    love.graphics.setFont(font_sub)
    if i == 1 then
      local col = selected and {1, 1, 1} or {0.70, 0.78, 0.96}
      love.graphics.setColor(col)
      love.graphics.print(item, cx - font_sub:getWidth(item) / 2, iy + 10)
    elseif i == 2 then
      local col = selected and {1.0, 0.90, 0.30} or {0.80, 0.70, 0.24}
      love.graphics.setColor(col)
      love.graphics.print(item, cx - font_sub:getWidth(item) / 2, iy + 10)
    else
      local col = selected and {1, 1, 1} or {0.65, 0.72, 0.90}
      love.graphics.setColor(col)
      love.graphics.print(item, cx - font_sub:getWidth(item) / 2, iy + 10)
    end
  end

  -- Toast de confirmação de reset (faixa no rodapé)
  if reset_confirm_timer > 0 then
    local alpha = math.min(1, reset_confirm_timer)
    love.graphics.setColor(0.18, 0.65, 0.32, alpha)
    love.graphics.rectangle("fill", 0, H - 44, W, 44)
    love.graphics.setFont(font_hint)
    love.graphics.setColor(1, 1, 1, alpha)
    local msg = "Recorde zerado!"
    love.graphics.print(msg, cx - font_hint:getWidth(msg) / 2, H - 32)
  else
    love.graphics.setFont(font_hint)
    love.graphics.setColor(0.35, 0.40, 0.58)
    local hint = "B / Esc: voltar"
    love.graphics.print(hint, cx - font_hint:getWidth(hint) / 2, H - 28)
  end

  -- ── Modal de confirmação de reset ───────────────
  if not reset_confirm then return end

  -- Overlay escuro
  love.graphics.setColor(0, 0, 0, 0.68)
  love.graphics.rectangle("fill", 0, 0, W, H)

  -- Painel do modal
  local mw, mh = 360, 170
  local mx, my = (W - mw) / 2, (H - mh) / 2

  love.graphics.setColor(0, 0, 0, 0.20)
  love.graphics.rectangle("fill", mx + 4, my + 6, mw, mh, 16, 16)
  love.graphics.setColor(0.14, 0.16, 0.28, 0.98)
  love.graphics.rectangle("fill", mx, my, mw, mh, 14, 14)
  love.graphics.setColor(0.80, 0.60, 0.20, 0.80)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", mx, my, mw, mh, 14, 14)

  love.graphics.setFont(font_sub)
  love.graphics.setColor(1, 1, 1)
  local q1 = "Resetar o recorde?"
  local q2 = "Esta ação não pode ser desfeita."
  love.graphics.print(q1, mx + (mw - font_sub:getWidth(q1)) / 2, my + 18)
  love.graphics.setFont(font_hint)
  love.graphics.setColor(0.65, 0.65, 0.80)
  love.graphics.print(q2, mx + (mw - font_hint:getWidth(q2)) / 2, my + 52)

  -- Botões Sim / Não
  local bw, bh = 110, 40
  local gap    = 30
  local bx_sim = mx + mw / 2 - bw - gap / 2
  local bx_nao = mx + mw / 2 + gap / 2
  local by     = my + mh - bh - 20

  -- Sim
  if reset_confirm_sel == 1 then
    love.graphics.setColor(0.75, 0.22, 0.12, 0.90)
  else
    love.graphics.setColor(0.28, 0.18, 0.16, 0.80)
  end
  love.graphics.rectangle("fill", bx_sim, by, bw, bh, 10, 10)
  love.graphics.setColor(reset_confirm_sel == 1 and {1, 0.7, 0.6} or {0.55, 0.40, 0.38})
  love.graphics.setLineWidth(1.5)
  love.graphics.rectangle("line", bx_sim, by, bw, bh, 10, 10)
  love.graphics.setFont(font_sub)
  love.graphics.setColor(1, 1, 1)
  local sim = "Sim"
  love.graphics.print(sim, bx_sim + (bw - font_sub:getWidth(sim)) / 2, by + (bh - font_sub:getHeight()) / 2)

  -- Não
  if reset_confirm_sel == 2 then
    love.graphics.setColor(0.25, 0.45, 0.82, 0.90)
  else
    love.graphics.setColor(0.16, 0.20, 0.30, 0.80)
  end
  love.graphics.rectangle("fill", bx_nao, by, bw, bh, 10, 10)
  love.graphics.setColor(reset_confirm_sel == 2 and {0.7, 0.85, 1.0} or {0.38, 0.44, 0.58})
  love.graphics.setLineWidth(1.5)
  love.graphics.rectangle("line", bx_nao, by, bw, bh, 10, 10)
  love.graphics.setFont(font_sub)
  love.graphics.setColor(1, 1, 1)
  local nao = "Nao"
  love.graphics.print(nao, bx_nao + (bw - font_sub:getWidth(nao)) / 2, by + (bh - font_sub:getHeight()) / 2)
end

-- ─────────────────────────────────────────────
--  RENDERIZAÇÃO — submenu escolher sílabas
-- ─────────────────────────────────────────────
local function draw_silabas_menu()
  draw_screen_header("ESCOLHER SILABAS")

  local item_h = 36
  local list_y = 68
  local list_x = 28
  local total  = silabas_total()

  for di = 1, SILABAS_VISIBLE do
    local ii = silabas_scroll + di
    if ii > total then break end

    local iy = list_y + (di - 1) * item_h

    if ii == silabas_sel then
      love.graphics.setColor(0.24, 0.40, 0.80, 0.60)
      love.graphics.rectangle("fill", list_x - 4, iy - 1, W - (list_x - 4) * 2, item_h - 2, 7, 7)
    end

    if ii <= #SILABAS_GRUPOS then
      local g      = SILABAS_GRUPOS[ii]
      local active = grupos_ativos[ii]

      -- Checkbox
      local cx, cy, cs = list_x, iy + 8, 18
      love.graphics.setColor(active and {0.28, 0.78, 0.42} or {0.24, 0.26, 0.36})
      love.graphics.rectangle("fill", cx, cy, cs, cs, 4, 4)
      love.graphics.setColor(active and {0.6, 1.0, 0.7} or {0.40, 0.42, 0.54})
      love.graphics.setLineWidth(1.5)
      love.graphics.rectangle("line", cx, cy, cs, cs, 4, 4)
      if active then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(2.5)
        love.graphics.line(cx + 3,       cy + cs * 0.55,
                           cx + cs * 0.46, cy + cs - 4,
                           cx + cs - 3,  cy + 4)
      end

      love.graphics.setFont(font_sub)
      love.graphics.setColor(active and {1, 1, 1} or {0.46, 0.48, 0.58})
      love.graphics.print(g.name, list_x + 26, iy + 4)

      love.graphics.setFont(font_hint)
      love.graphics.setColor(active and {0.70, 0.82, 1.0} or {0.30, 0.32, 0.42})
      love.graphics.print(table.concat(g.sils, "  "), list_x + 72, iy + 8)

    else
      -- Voltar
      love.graphics.setFont(font_sub)
      love.graphics.setColor(ii == silabas_sel and {1, 1, 1} or {0.65, 0.72, 0.90})
      love.graphics.print("Voltar", list_x + 26, iy + 4)
    end
  end

  -- Indicadores de scroll
  love.graphics.setFont(font_hint)
  if silabas_scroll > 0 then
    love.graphics.setColor(1, 1, 1, 0.50)
    local arr = "[ mais acima ]"
    love.graphics.print(arr, (W - font_hint:getWidth(arr)) / 2, list_y - 16)
  end
  if silabas_scroll + SILABAS_VISIBLE < total then
    love.graphics.setColor(1, 1, 1, 0.50)
    local arr = "[ mais abaixo ]"
    love.graphics.print(arr, (W - font_hint:getWidth(arr)) / 2, list_y + SILABAS_VISIBLE * item_h + 2)
  end

  love.graphics.setFont(font_hint)
  love.graphics.setColor(0.35, 0.40, 0.58)
  local hint = "A / Espaco: marcar   B / Esc: voltar"
  love.graphics.print(hint, (W - font_hint:getWidth(hint)) / 2, H - 28)
end

-- ─────────────────────────────────────────────
--  LOVE.DRAW
-- ─────────────────────────────────────────────
function love.draw()
  local theme = active_theme()

  -- Config e submenu têm fundo próprio
  if state == S_CONFIG then
    draw_config_menu()
    return
  end
  if state == S_SILABAS then
    draw_silabas_menu()
    return
  end

  draw_gradient_bg(theme)
  draw_atmosphere(theme)
  draw_hud(theme)

  if state ~= S_CORRECT and state ~= S_WRONG and state ~= S_STREAK then
    draw_panel(theme)
    draw_combo_meter(theme)
  end

  -- ── LEITURA ──────────────────────────────
  if state == S_READING or state == S_PAUSE then
    draw_syllable_centered(theme)

  -- ── ACERTO ───────────────────────────────
  elseif state == S_CORRECT then
    love.graphics.setColor(1, 1, 1, flash_alpha * 0.45)
    love.graphics.rectangle("fill", 0, 0, W, H)

    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.circle("fill", W * 0.5, H * 0.52, 150)
    love.graphics.circle("fill", W * 0.5, H * 0.52, 96)

    local pts = 10 * combo
    center_text(font_feedback, "Correto!",
                144, theme.ink[1], theme.ink[2], theme.ink[3])
    center_text(font_points, "+" .. pts .. " pontos",
                224, theme.accent[1], theme.accent[2], theme.accent[3])

    if combo >= 2 then
      center_text(font_sub, "Sequência de " .. combo .. "!",
                  298, theme.ink[1], theme.ink[2], theme.ink[3], 0.88)
    end

  -- ── ERRO ─────────────────────────────────
  elseif state == S_WRONG then
    love.graphics.setColor(0.9, 0.3, 0, flash_alpha * 0.28)
    love.graphics.rectangle("fill", 0, 0, W, H)

    love.graphics.setColor(1, 1, 1, 0.10)
    love.graphics.circle("fill", W * 0.5, H * 0.52, 138)

    center_text(font_feedback, "Tente novamente!",
                160, theme.ink[1], theme.ink[2], theme.ink[3])

  -- ── CELEBRAÇÃO DE SEQUÊNCIA ──────────────
  elseif state == S_STREAK then
    local pulse = 0.88 + 0.12 * math.sin(timer * 7)
    love.graphics.setColor(1, 1, 1, pulse * 0.10)
    love.graphics.circle("fill", W * 0.5, H * 0.50, 162)
    love.graphics.circle("fill", W * 0.5, H * 0.50, 104)

    if particles then
      for _, p in ipairs(particles) do
        if p.life > 0 then
          local a   = p.life / p.max
          local r,g,b = hue_rgb(p.hue)
          love.graphics.setColor(r, g, b, a)
          love.graphics.rectangle("fill",
            p.x - p.size / 2, p.y - p.size / 2, p.size, p.size)
        end
      end
    end

    center_text(font_feedback, "Festa!",
                132, theme.ink[1], theme.ink[2], theme.ink[3])
    center_text(font_points, combo .. " seguidos!",
                214, theme.accent[1], theme.accent[2], theme.accent[3])

    local sc = 0.92 + 0.08 * math.sin(timer * 5.5)
    local cel = "Incrivel! Continue assim!"
    love.graphics.setFont(font_sub)
    love.graphics.setColor(theme.ink[1], theme.ink[2], theme.ink[3], 0.92)
    love.graphics.push()
    love.graphics.translate(W / 2, 298)
    love.graphics.scale(sc, sc)
    love.graphics.translate(-W / 2, -298)
    love.graphics.print(cel, (W - font_sub:getWidth(cel)) / 2, 298)
    love.graphics.pop()
  end

  -- Banner de novo recorde (sobrepõe qualquer estado de jogo)
  draw_record_banner()

  -- Menu de pausa por cima de tudo
  if state == S_PAUSE then
    draw_pause_menu()
  end
end
