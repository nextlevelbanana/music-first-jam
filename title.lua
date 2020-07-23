rockwell_title = love.graphics.newFont("fonts/Rockwell.TTF", 200)
rockwell_button = love.graphics.newFont("fonts/Rockwell.TTF", 30)
require("classes/button")

title = {}
title.name = "title"
title.x = 100
title.y = 0
title.font = rockwell_title

cursor = {}
cursor.x = 480
cursor.y = 275
cursor.size = 10

-- Main Menu audio
sfxNewGame = love.audio.newSource("assets/sfx/sfx_rim_tom.wav", "static")
sfxNewGame:setVolume(0.4)
sfxLore = love.audio.newSource("assets/sfx/sfx_bass_longhigh.wav", "static")
sfxLore:setVolume(1)
sfxCursorUp = love.audio.newSource("assets/sfx/sfx_bass_shorthigh.wav", "static")
sfxCursorUp:setVolume(1)
sfxCursorDown = love.audio.newSource("assets/sfx/sfx_bass_shortlow.wav", "static")
sfxCursorDown:setVolume(1)

buttonStart = Button(500, 250, "New Game", rockwell_button)
buttonCredits = Button(500, 320, "Lore", rockwell_button)
buttonExit = Button(500, 390, "Exit", rockwell_button)

posStart = 275
posCredits = 345
posExit = 415

function titledraw()
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(rockwell_title)
  love.graphics.print(title.name, title.x, title.y)

  buttonStart:draw()
  buttonCredits:draw()
  buttonExit:draw()

  love.graphics.circle("fill", cursor.x, cursor.y, cursor.size)
end

function titleupdate(dt)

  if love.keyboard.isDown('down','s') and cursor.y < 415 then
    love.audio.play(sfxCursorDown)
    cursor.y = cursor.y + 70
    love.event.wait(20)
  end

  if love.keyboard.isDown('up','w') and cursor.y > 275 then
    love.audio.play(sfxCursorUp)
    cursor.y = cursor.y - 70
    love.event.wait(20)
  end

  if love.keyboard.isDown('space') and cursor.y == posStart then
    love.audio.play(sfxNewGame)
    scene="level-1"
  elseif love.keyboard.isDown('space') and cursor.y == posCredits then
    love.audio.play(sfxLore)
    scene="lore"
  elseif love.keyboard.isDown('space') and cursor.y == posExit then
    love.event.quit(0)
  end

end

function distanceBetween (x1, y1, x2, y2)
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function checkButtonPress(x, y)
  if love.mouse.isDown(1) and love.mouse.getX() <= x and love.mouse.getY() <= y then
    return true
  end
end
