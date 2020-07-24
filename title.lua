rockwell_title = love.graphics.newFont("fonts/Rockwell.TTF", 200)
rockwell_button = love.graphics.newFont("fonts/Rockwell.TTF", 30)
require("classes/button")

local cron = require("libs/cron")
local tween = require("libs/tween")

title = {}
title.name = "title"
title.x = 100
title.y = -100
title.font = rockwell_title

titleTween = tween.new(2, title, {y = 0}, 'outBounce')

cursor = {}
cursor.x = 450
cursor.y = 260
cursor.angle = 0
cursor.scale = 1
cursor.image = love.graphics.newImage("assets/temp/finderHandleSmall.png")

buttonStart = Button(500, 250, "New Game", rockwell_button)
buttonCredits = Button(500, 320, "Lore", rockwell_button)
buttonExit = Button(500, 390, "Exit", rockwell_button)

function titleload()

  -- Main Menu audio
  bgm = love.audio.newSource("assets/music/main_theme.wav", "stream")
  bgmVolume = 0.5
  bgm:setLooping(true)
  bgm:setVolume(bgmVolume)
  if not bgm:isPlaying() then
    love.audio.play(bgm)
  end

  sfxNewGame = love.audio.newSource("assets/sfx/sfx_rim_tom.wav", "static")
  sfxNewGame:setVolume(0.4)
  sfxLore = love.audio.newSource("assets/sfx/sfx_bass_longhigh_1.wav", "static")
  sfxLore:setVolume(0.4)
  sfxCursorUp0 = love.audio.newSource("assets/sfx/sfx_bass_shorthigh_1.wav", "static")
  sfxCursorUp0:setVolume(0.2)
  sfxCursorUp1 = love.audio.newSource("assets/sfx/sfx_bass_shorthigh_1.wav", "static")
  sfxCursorUp1:setPitch(1.1)
  sfxCursorUp1:setVolume(0.15)
  sfxCursorDown0 = love.audio.newSource("assets/sfx/sfx_bass_shortlow_1.wav", "static")
  sfxCursorDown0:setVolume(0.2)
  sfxCursorDown1 = love.audio.newSource("assets/sfx/sfx_bass_shortlow_1.wav", "static")
  sfxCursorDown1:setPitch(1.1)
  sfxCursorDown1:setVolume(0.15)

  posStart = 260
  posCredits = 330
  posExit = 400

  local moveClock
  allowMove = true
  titleFader = 0
  titleFaderState = false

  fadeTween = {5, titleFader, 1.0, 'linear'}
end

function titledraw()
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(rockwell_title)
  love.graphics.print(title.name, title.x, title.y)

  buttonStart:draw()
  buttonCredits:draw()
  buttonExit:draw()

  love.graphics.draw(cursor.image, cursor.x, cursor.y, cursor.angle, cursor.scale, cursor.scale, cursor.origin_x)
  love.graphics.setColor(0,0,0,titleFader)
  love.graphics.rectangle("fill", 0, 0, 800, 600)
end

function titleupdate(dt)

  titleTween:update(dt)

  if moveClock then moveClock:update(dt) end

  if love.keyboard.isDown('down','s') and cursor.y < posExit and allowMove then
    if sfxCursorDown0:isPlaying() then
      sfxCursorDown1:play()
    else sfxCursorDown0:play() end
    cursor.y = cursor.y + 70
    allowMoveTimer()
  end
  if love.keyboard.isDown('up','w') and cursor.y > posStart and allowMove then
    if sfxCursorUp0:isPlaying() then
      sfxCursorUp1:play()
    else sfxCursorUp0:play() end
    cursor.y = cursor.y - 70
    allowMoveTimer()
  end

  if love.keyboard.isDown('space') and cursor.y == posStart then
    love.audio.play(sfxNewGame)
    titleFaderState = true
  elseif love.keyboard.isDown('space') and cursor.y == posCredits then
    love.audio.play(sfxLore)
    scene="lore"
  elseif love.keyboard.isDown('space') and cursor.y == posExit then
    love.event.quit(0)
  end

  if titleFaderState then
    titleFader = titleFader + 1 * dt
    bgmVolume = bgmVolume - 2 * dt
    bgm:setVolume(bgmVolume)
    if titleFader >= 1 then
      bgm:stop()
      scene="level-1" end
  end
end

function allowMoveTimer()
  if allowMove then
    allowMove = false
  end
  moveClock = cron.after(0.3, function() allowMove = true end)
end

--
-- function distanceBetween (x1, y1, x2, y2)
-- 	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
-- end

--
-- function checkButtonPress(x, y)
--   if love.mouse.isDown(1) and love.mouse.getX() <= x and love.mouse.getY() <= y then
--     return true
--   end
-- end
