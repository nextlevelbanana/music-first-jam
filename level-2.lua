require("classes/enemy")
require("classes/clue")

local letters = {"F", "A", "C", "E"}
local numOfClues = #letters

local bgColor = {0.15, 0.15, 0.15, 0}
local speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")

-- Audio and SFX
local levelClear = love.audio.newSource("assets/music/level_clear.wav", "static")

local gameOver = love.audio.newSource("assets/music/game_over.wav", "static")
gameOver:setVolume(0.3)

local ghostVoice = {}
for i = 0,4 do
  table.insert(ghostVoice, love.audio.newSource("assets/sfx/hmm"..i..".wav", "static"))
end

local letterChime = {}
for i = 1,numOfClues do
  table.insert(letterChime, love.audio.newSource("assets/sfx/letter_clues/marim_"..letters[i]..".wav", "static"))
  letterChime[i]:setVolume(0.3)
  --letterChime[i].played = false
end

local bgLevel2 = love.graphics.newImage("assets/backgrounds/bg_level2.png")
local restart = false

---------------------------------
-- Loaded variables on restart
---------------------------------

function level2load()

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
  enemy2 = Enemy(false, false, 600, 100)

  -- Instantiate clues for this level
  clueColor = {}
  for i = 1,#letters do
    table.insert(clueColor, 0.3)
  end
  clue1 = Clue(false, true, 350, 550, letters[1])
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
  if busted == false and (timeElapsed > 65 or restart) and finderLens.visibility then
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
  if (restart or timeElapsed >= 70) and not win then
    enemy1.draw_state = true
    allowInvis = true
    enemy1.update_state = true
    enemy1:update(finderLens, visible, enemySpeed, dt)
  end

  if clue3.update_state and not win then
    enemySpeed = 100
    enemy2.draw_state = true
    enemy2.update_state = true
    enemy2:update(finderLens, visible, enemySpeed, dt)
  end


  -- Clue handler
  for i = 1,numOfClues do
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
  if clues[numOfClues].update_state then
    win = true
    levelFader = levelFader + 1 * dt
    if levelFader >= 1 then
      bgm:stop()
      levelClear:play()
      clear_level2 = true
      love.timer.sleep(4)
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

function level2draw()
   -- Each pixel touched by the circle will have its stencil value set to 1. The rest will be 0.
   love.graphics.stencil(finderLensStencil, "replace", 1)

   love.graphics.draw(bgLevel2, -400, -250, 0, 0.24, 0.24)
   love.graphics.setColor(0, 0, 0, 0.5)
   love.graphics.rectangle("fill", 0, 0, 800, 600)

   love.graphics.setColor(1,1,1)

   -- SPEECH BLOCK
   -- Clue 1:
   if clues[1].update_state == false and (timeElapsed > 70 or restart) then
     drawText("Oh no! More ghosts... rookie! Let's find the clues around here and get a move on!")
   elseif clues[1].update_state == false and timeElapsed > 65 and not restart then
     drawText("It's why I became a detective! \n \nDo you think, maybe...?")
   elseif clues[1].update_state == false and timeElapsed > 60 and not restart then
     drawText("I've been looking for the clues to how I... you know... became a ghost.")
   elseif clues[1].update_state == false and timeElapsed > 55 and not restart then
     drawText("But I've been wondering for a long time now... how did I get here?")
   elseif clues[1].update_state == false and timeElapsed > 50 and not restart then
     drawText("That's a very silly note.")
   elseif clues[1].update_state == false and timeElapsed > 49 and not restart then
     drawText("...")
   elseif clues[1].update_state == false and timeElapsed > 45 and not restart then
     drawText("'Ehehe... Ghost Buddy is Done For!' ...? EGBDF...")
   elseif clues[1].update_state == false and timeElapsed > 40 and not restart then
     drawText("Oh? You found a note with one of the clues back there? What does it say?")
   elseif clues[1].update_state == false and timeElapsed > 35 and not restart then
     drawText("...you don't think that's it? Hm... it does seem awfully irrelevant...")
   elseif clues[1].update_state == false and timeElapsed > 30 and not restart then
     drawText("It's a headline I read one time. I can't believe I remembered that one.")
   elseif clues[1].update_state == false and timeElapsed > 25 and not restart then
     drawText("Egg-buh- Aha! \n \nEndearing Gladiator Buys Dog Food! Of course!")
   elseif clues[1].update_state == false and timeElapsed > 20 and not restart then
     drawText("EGBDF... egg-bi-duf. Hmm...")
   elseif clues[1].update_state == false and timeElapsed > 15 and not restart then
     drawText("I hear it's called 'in too witchin.' It's how I find all my clues! Not all ghosts have it. Now...")
   elseif clues[1].update_state == false and timeElapsed > 8 and not restart then
     drawText("This is another spot I'm suspicious of. I'm not sure why, but something tells me there are clues here.")
   elseif clues[1].update_state == false and timeElapsed > 3 and not restart and clueColor[1] <= 0.3 then
     drawText("Nice work, rookie! What a clue... I wonder what it means? And way to escape that unfriendly ghost!")
   -- Clue 2
   elseif clues[2].update_state == false and timeElapsed > 10 and clueColor[2] > 0.3 then
     drawText("Another clue! Let's get a closer look at that.")
   elseif clues[2].update_state == false and timeElapsed > 10 and clueColor[2] <= 0.3 then
     drawText("'F...'' Okay, there must be more.")
   -- Clue 3
   elseif clues[3].update_state == false and timeElapsed > 10 and clueColor[3] > 0.3 then
     drawText("Wait! Another clue! Oh thank goodness.")
   elseif clues[3].update_state == false and timeElapsed > 10 and clueColor[3] <= 0.3 then
     drawText("'FA.' FAulty brakes? FAther? Oh no...'")
   -- Clue 4
   elseif clues[4].update_state == false and timeElapsed > 10 and clueColor[4] > 0.3 then
     drawText("I think that's the last one - let's hurry up and get outta' here!")
   elseif clues[4].update_state == false and timeElapsed > 10 and clueColor[4] <= 0.3 then
     drawText("My FACulties tell me we're onto something good here.")
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

   for i = 1,numOfClues do
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

   if restart then
     enemy1.draw_state = true
   end

   if enemy1.draw_state then
     enemy1:draw(angryAnim)
   end
   if enemy2.draw_state then
     enemy2:draw(angryAnim)
   end

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
      --restart = true
  end

  if finderLens.visibility and distanceBetween(enemy2.x, enemy2.y, finderLens.x, finderLens.y) <
    enemy2.size and enemy2.draw_state and win == false then
      love.graphics.setColor(1,1,1)
      local spriteNum2 = math.floor(
        loseStamp.currentTime / loseStamp.duration *
        #loseStamp.quads) + 1
      love.graphics.draw(
        loseStamp.spriteSheet, loseStamp.quads[spriteNum2],
        love.graphics.getWidth() / 2 - 125,
        love.graphics.getHeight() / 2 - 125, 0, 1)
      busted = true
      --restart = true
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
