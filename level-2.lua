require("classes/enemy")
require("classes/clue")

letters = {"F", "A", "C", "E"}
numOfClues = #letters

bgColor = {0.15, 0.15, 0.15, 0}
speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")

-- Audio and SFX
levelClear = love.audio.newSource("assets/music/level_clear.wav", "static")

gameOver = love.audio.newSource("assets/music/game_over.wav", "static")
gameOver:setVolume(0.3)

ghostVoice = {}
for i = 0,4 do
  table.insert(ghostVoice, love.audio.newSource("assets/sfx/hmm"..i..".wav", "static"))
end

letterChime = {}
for i = 1,#letters do
  table.insert(letterChime, love.audio.newSource("assets/sfx/letter_clues/marim_"..letters[i]..".wav", "static"))
  letterChime[i]:setVolume(0.3)
  --letterChime[i].played = false
end

local bgLevel1 = love.graphics.newImage("assets/backgrounds/bg_level2.png")

local restart = false

---------------------------------
-- Loaded variables on restart
---------------------------------

function level2load()

  -- music = {volume = bgmVolume, path = bgm}
  -- musicTween = tween.new(2, music, {volume = 0.0})

  ghostAnim = newAnimation(love.graphics.newImage("assets/ghost_detective/idleAnim.png"), 250, 250, 4)
  winStamp = newAnimation(love.graphics.newImage("assets/ghost_detective/winStamp.png"), 250, 250, 4)
  loseStamp = newAnimation(love.graphics.newImage("assets/ghost_detective/loseStamp.png"), 250, 250, 4)
  angryAnim = newAnimation(love.graphics.newImage("assets/enemies/angryAnim.png"), 250, 250, 1)

  anims = {ghostAnim, winStamp, loseStamp, angryAnim}
  -- Playable area container
  playableArea = {}
  playableArea.x = 250
  playableArea.y = 20
  playableArea.border = 20
  playableArea.size_x = love.graphics.getWidth() - playableArea.x - playableArea.border
  playableArea.size_y = love.graphics.getHeight() - playableArea.y - playableArea.border

  -- Main player cursor
  finderLens = {}  -- finderLens is the main controller component that reveals hidden "clues" within the background layer
  finderLens.x = (love.graphics.getWidth() / 2) + (playableArea.x / 2)
  finderLens.y = (love.graphics.getHeight() / 2) + (playableArea.y / 2)
  finderLens.size = 40  -- Size of the lens that reveals objects, 40 fits nicely with the current size of finderHandle, will change with art
  finderLens.speed = 200  -- Set player movement speed
  finderLens.image = love.graphics.newImage("assets/temp/finderHandle.png")
  finderLens.origin_x = finderLens.image:getWidth() / 2
  finderLens.origin_y = finderLens.image:getHeight() / 2
  finderLens.offset_x = 50
  finderLens.offset_y = 48
  finderLens.visibility = true
  isMoving = false

  -- Instantiate enemies for this level
  enemySpeed = 75
  enemy1 = Enemy(false, false, 300, 200)

  -- Instantiate clues for this level
  clueColor = {}
  for i = 1,#letters do
    table.insert(clueColor, 0.3)
  end
  clue1 = Clue(false, true, 275, 550, letters[1])
  clue2 = Clue(false, false, 600, 100, letters[2])
  clue3 = Clue(false, false, 400, 400, letters[3])
  clue4 = Clue(false, false, 300, 200, letters[4])
  clues = {clue1, clue2, clue3, clue4}

  -- NOTE: Clue randomizer for later:
  -- math.random(playableArea.x + finderLens.size, playableArea.size_x)
  -- math.random(playableArea.y + finderLens.size, playableArea.size_y)

  -- Bounding box for keeping the finderLens in the playable area
  roomWidth = playableArea.size_x - finderLens.size
  roomHeight = playableArea.size_y - finderLens.size

  -- Condition variables for all prompts
  win = false
  timeElapsed = 0
  busted = false

  -- Cron / clock variables
  local speakClock
  allowSpeak = true
  levelFader = 0
  local sceneClock
  allowChange = false
  local invisClock
  allowInvis = false
  local duration
  visible = true

  -- Unsorted set conditions
  love.graphics.newFont(35)
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2, 0.4)
end

---------------------------------
-- Early functions (dependencies)
---------------------------------

function finderLensStencil()
   -- Stencil function that is used to reveal hidden "clue" layer
   love.graphics.setColor(1, 1, 1)
   love.graphics.circle("fill", finderLens.x, finderLens.y, finderLens.size)
end

---------------------------------
-- Update
---------------------------------

function level2update(dt)

  if love.keyboard.isDown('space') and allowInvis and not busted then
    finderLens.visibility = false
    invisDuration()
    invisibilityTimer()
  elseif visible then
    finderLens.visibility = true
  end

  if not love.graphics.setFont(rockwell_speech) then
    love.graphics.setFont(rockwell_speech)
  end

  timeElapsed = timeElapsed + 1 * dt

  if speakClock then speakClock:update(dt) end
  if sceneClock then sceneClock:update(dt) end
  if invisClock then invisClock:update(dt) end
  if duration then duration:update(dt) end

  -- Loss condition controller
  if not bgm:isPlaying() and not busted then
    bgm = love.audio.newSource("assets/music/bgm_level2.ogg", "static")
    bgm:setVolume(0.5)
    bgm:play()
  elseif busted then
    love.audio.play(gameOver)
    while bgmVolume > 0.0 do
      bgmVolume = bgmVolume - 2.0 * dt
      bgm:setVolume(bgmVolume)
    end
    levelFader = levelFader + 1 * dt
    if levelFader >= 1 then
      bgm:stop()
      love.timer.sleep(2.5)
      love.load()
    end
  end

  for i = 1,#anims do
    anims[i].currentTime = anims[i].currentTime + dt
    if anims[i].currentTime >= anims[i].duration then
      anims[i].currentTime = anims[i].currentTime - anims[i].duration
    end
  end

  -- Player controller using arrow keys or WASD
  if busted == false and (timeElapsed > 5 or restart) and finderLens.visibility then
    if finderLens.x <= roomWidth + playableArea.x and
      love.keyboard.isDown('right', 'd') then
        finderLens.x = finderLens.x + finderLens.speed * dt
        isMoving = true
    end
    if finderLens.x >= finderLens.size + playableArea.x and
      love.keyboard.isDown('left', 'a') then
        finderLens.x = finderLens.x - finderLens.speed * dt
        isMoving = true
    end
    if finderLens.y <= roomHeight + playableArea.y and
      love.keyboard.isDown('down', 's') then
        finderLens.y = finderLens.y + finderLens.speed * dt
        isMoving = true
    end
    if finderLens.y >= finderLens.size + playableArea.y and
      love.keyboard.isDown('up', 'w') then
        finderLens.y = finderLens.y - finderLens.speed * dt
        isMoving = true
    end
    if not love.keyboard.isDown('up', 'down', 'left', 'right',
      'w', 'a', 's', 'd') then
      isMoving = false
    end
  end

  -- Enemy AI controller
  if not win and clue2.update_state then
    enemy1.draw_state = true
    if clue1.update_state then
      allowInvis = true
      enemy1.update_state = true
      enemy1:update(finderLens, visible, enemySpeed, dt)
    end
    if clue2.update_state then
      enemySpeed = 100
    end
  end

  -- Clue handler
  for i = 1,5 do
    if clues[i].update_state and i < #letters then
      clues[i+1]:update(clueColor[i+1], dt)
    end
    if clues[i].draw_state then
      clues[i]:update(clueColor[i], dt)
      if distanceBetween(clues[i].x, clues[i].y, finderLens.x, finderLens.y) < clues[i].size then
        clueColor[i] = clueColor[i] + (0.3 * dt)
        if love.audio.getActiveSourceCount() < 2 and clues[i].update_state == false and allowSpeak and clueColor[i] < 0.9 then
          ghostVoice[math.floor(math.random(1,4))]:play()
          speakTimer()
        end
        if clueColor[i] >= 1 and clues[i].update_state == false then
          love.audio.play(letterChime[i])
          clues[i].update_state = true
        end
      end
    end
  end

  --clue5.update_state = true
  --  Win condition
  if clue5.update_state then
    win = true
    levelFader = levelFader + 1 * dt
    if levelFader >= 1 then
      bgm:stop()
      levelClear:play()
      love.timer.sleep(2)
      --sceneTimer()
      --if allowChange then
        love.load()
    --  end
    end
  end

  -- Escape key back to main menu
  if love.keyboard.isDown('escape') then
    bgm:stop()
    love.timer.sleep(1)
    love.load()
  end
end

---------------------------------
-- Draw
---------------------------------

function level1draw()
   -- Each pixel touched by the circle will have its stencil value set to 1. The rest will be 0.
   love.graphics.stencil(finderLensStencil, "replace", 1)

   love.graphics.draw(bgLevel1, 0, 0, 0, 0.25, 0.25)
   love.graphics.setColor(0, 0, 0, 0.5)
   love.graphics.rectangle("fill", 0, 0, 800, 600)

   love.graphics.setColor(1,1,1)

   -- SPEECH BLOCK
   -- Clue 1:
   if clues[1].update_state == false and clueColor[1] > 0.3 then
     drawText("Oh? I think that's a clue - let's get a closer look!")
   elseif clues[1].update_state == false and restart == true then
     drawText("Let's look for clues! Use the arrow keys to find them.")
   elseif clues[1].update_state == false and timeElapsed > 10 then
     drawText("")
   elseif clues[1].update_state == false and timeElapsed > 10 then
     drawText("...")
   elseif clues[1].update_state == false and timeElapsed > 10 then
     drawText("'Ehehe... Ghost Buddy is Done For!' ...?")
   elseif clues[1].update_state == false and timeElapsed > 10 then
     drawText("Oh? You found a note with one of the clues back there? What does it say?")
   elseif clues[1].update_state == false and timeElapsed > 10 then
     drawText("...you don't think that's it? Hm... it does seem awfully irrelevant...")
   elseif clues[1].update_state == false and timeElapsed > 10 then
     drawText("Aha! Endearing Gladiator Buys Dog Food! It's from a headline I read one time. I can't believe I remembered that one.")
   elseif clues[1].update_state == false and timeElapsed > 5 then
     drawText("EGBDF... egg-bi-duf. Hmm...")
   elseif clues[1].update_state == false and timeElapsed > 1 and clueColor[1] <= 0.3 then
     drawText("Nice work, rookie! What a clue... I wonder what it means? And way to escape that unfriendly ghost!")
   -- Clue 2
   elseif clues[2].update_state == false and timeElapsed > 10 and clueColor[2] > 0.3 then
     drawText("Aha - another clue! Let's get a closer look at that.")
   elseif clues[2].update_state == false and timeElapsed > 10 and clueColor[2] <= 0.3 then
     drawText("Wow, rookie! You found a clue! Keep looking while I ponder the meaning of this...")
   -- Clue 3
   elseif clues[3].update_state == false and timeElapsed > 10 and clueColor[3] > 0.3 then
     drawText("'EG'... egg? Ego? Egalitarian? I think we're onto something big here. Maybe.")
   elseif clues[3].update_state == false and timeElapsed > 10 and clueColor[3] <= 0.3 then
     drawText("Hm. That ghost doesn't look too friendly. We should probably avoid him.")
   -- Clue 4
   elseif clues[4].update_state == false and timeElapsed > 10 and clueColor[4] > 0.3 then
     drawText("Another clue - get back to it when you can and hover over it to decode!")
   elseif clues[4].update_state == false and enemy1.timeElapsed > 3 and clueColor[4] <= 0.3 and enemy1.update_state then
     drawText("Uh-oh. Looks like someone doesn't want us snooping around!")
   elseif clues[4].update_state == false and timeElapsed > 10 and clueColor[4] <= 0.3 then
     drawText("'EGB'... nope. I'm stumped.")
   end

   love.graphics.setColor(1, 1, 1)
   -- Draw Ghost
   local spriteNum0 = math.floor(ghostAnim.currentTime / ghostAnim.duration * #ghostAnim.quads) + 1
   love.graphics.draw(ghostAnim.spriteSheet, ghostAnim.quads[spriteNum0], 0, 290, 0, 1)

   -- Draw playable area
   love.graphics.setColor(0.5, 0.5, 0.5)
   love.graphics.rectangle("line", playableArea.x, playableArea.y,
      playableArea.size_x, playableArea.size_y)
   love.graphics.setColor(0.15, 0.15, 0.15, 0.5)
   love.graphics.rectangle("fill", playableArea.x, playableArea.y,
      playableArea.size_x, playableArea.size_y)

   for i = 1,5 do
     if clues[i].draw_state then
       clues[i]:draw(clueColor[i], bgColor, letters[i])
       if clueColor[i] >= 1 and i < (#letters) then
         clues[i+1].draw_state = true
       end
     end
   end

   love.graphics.setStencilTest() -- Handles wild stencil stuff I don't fully understand
   if finderLens.visibility == false then
     love.graphics.setColor(1, 1, 1, 0.5) -- Color for finderHandle
   else
     love.graphics.setColor(1, 1, 1, 1) -- Color for finderHandle
   end
   love.graphics.draw(finderLens.image, finderLens.x - finderLens.offset_x, finderLens.y - finderLens.offset_y) -- Offset numbers that will change with new artwork for finderHandle

   love.graphics.setColor(1, 1, 1, 1)

   if clue2.update_state then
     enemy1:draw(angryAnim)
   end
   --enemy2:draw()

 love.graphics.setColor(0,0,0,levelFader)
 love.graphics.rectangle("fill", 0, 0, 800, 600)

  -- Win condition controller
  if win then
    love.graphics.setColor(1,1,1)
    local spriteNum1 = math.floor(
      winStamp.currentTime / winStamp.duration *
      #winStamp.quads) + 1
    love.graphics.draw(
      winStamp.spriteSheet, winStamp.quads[spriteNum1],
      love.graphics.getWidth() / 2 - 125,
      love.graphics.getHeight() / 2 - 125, 0, 1)
  end

  -- Loss condition controller
  if finderLens.visibility and distanceBetween(enemy1.x, enemy1.y, finderLens.x, finderLens.y) <
    enemy1.size and enemy1.draw_state and win == false then
      love.graphics.setColor(1,1,1)
      local spriteNum1 = math.floor(
        loseStamp.currentTime / loseStamp.duration *
        #loseStamp.quads) + 1
      love.graphics.draw(
        loseStamp.spriteSheet, loseStamp.quads[spriteNum1],
        love.graphics.getWidth() / 2 - 125,
        love.graphics.getHeight() / 2 - 125, 0, 1)
      busted = true
      restart = true
  end
end

---------------------------------
-- Other functions
---------------------------------

function distanceBetween (x1, y1, x2, y2)
	-- distance formula: d = √(y2 - y1)^2 + (x2 - x1)^2
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function drawText(text)
  love.graphics.draw(speechBubble, 17, 100)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.printf(text, 30, 120, 200, "left")
end

-- Animation controller
function newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image;
  animation.quads = {};

  for y = 0, image:getHeight() - height, height do
    for x = 0, image:getWidth() - width, width do
      table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
  end

  animation.duration = duration or 1
  animation.currentTime = 0

  return animation
end

function speakTimer()
  if allowSpeak then
    allowSpeak = false
  end
  speakClock = cron.after(3, function() allowSpeak = true end)
end

function sceneTimer()
  if allowChange then
    allowChange = false
  end
  sceneClock = cron.after(1, function() allowChange = true end)
end

function invisibilityTimer()
  if allowInvis then
    allowInvis = false
  end
  invisClock = cron.after(10, function() allowInvis = true end)
end

function invisDuration()
  if visible then
    visible = false
  end
  duration = cron.after(2, function() visible = true end)
end
