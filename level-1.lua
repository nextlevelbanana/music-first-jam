require("classes/enemy")
require("classes/clue")

letters = {"E", "G", "B", "D", "F"}
numOfClues = #letters

bgColor = {0.15, 0.15, 0.15}
speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")

-- Audio and SFX
gameOver = love.audio.newSource("assets/music/game_over.wav", "static")

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


---------------------------------
-- Loaded variables on restart
---------------------------------

function level1load()

  ghostAnim = newAnimation(love.graphics.newImage("assets/ghost_detective/idleAnim.png"), 250, 250, 4)
  winStamp = newAnimation(love.graphics.newImage("assets/ghost_detective/winStamp.png"), 250, 250, 4)
  loseStamp = newAnimation(love.graphics.newImage("assets/ghost_detective/loseStamp.png"), 250, 250, 4)

  anims = {ghostAnim, winStamp, loseStamp}
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
  isMoving = false

  -- Instantiate enemies for this level
  enemy1 = Enemy(false, false, 300, 200)

  -- Instantiate clues for this level
  clueColor = {}
  for i = 1,5 do
    table.insert(clueColor, 0.3)
  end
  clue1 = Clue(false, true, 400, 300, letters[1])
  clue2 = Clue(false, false, 600, 200, letters[2])
  clue3 = Clue(false, false, 300, 500, letters[3])
  clue4 = Clue(false, false, 400, 100, letters[4])
  clue5 = Clue(false, false, 700, 300, letters[5])
  clues = {clue1, clue2, clue3, clue4, clue5}

  -- NOTE: Clue randomizer for later:
  -- math.random(playableArea.x + finderLens.size, playableArea.size_x)
  -- math.random(playableArea.y + finderLens.size, playableArea.size_y)

  -- Bounding box for keeping the finderLens in the playable area
  roomWidth = playableArea.size_x - finderLens.size
  roomHeight = playableArea.size_y - finderLens.size
  -- Unsorted variables
  win = false
  timeElapsed = 0
  busted = false
  -- Unsorted set conditions
  love.graphics.newFont(35)
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
end

---------------------------------
-- Early functions (dependencies)
---------------------------------

function finderLensStencil()
   -- Stencil function that is used to reveal hidden "clue" layer
   love.graphics.circle("fill", finderLens.x, finderLens.y, finderLens.size)
end

---------------------------------
-- Update
---------------------------------

function level1update(dt)

  for i = 1,#anims do
    anims[i].currentTime = anims[i].currentTime + dt
    if anims[i].currentTime >= anims[i].duration then
      anims[i].currentTime = anims[i].currentTime - anims[i].duration
    end
  end

  -- Player controller using arrow keys or WASD
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

  -- Enemy AI controller
  if not win and clue2.update_state then
    enemy1:update(finderLens, dt)
    enemy1.update_state = true
    enemy1.draw_state = true
  end

  -- Distance checks
  if busted then
    love.audio.stop(bgm)
    love.audio.play(gameOver)
    love.timer.sleep(2)
    love.load()
  end

  --for i = clues

  for i = 1,5 do
    if clues[i].update_state and i < #letters then
      clues[i+1]:update(clueColor[i+1], dt)
    end
    if clues[i].draw_state then
      clues[i]:update(clueColor[i], dt)
      if distanceBetween(clues[i].x, clues[i].y, finderLens.x, finderLens.y) < clues[i].size then
        clueColor[i] = clueColor[i] + (0.3 * dt)
        if love.audio.getActiveSourceCount() < 2 and clues[i].update_state == false then
          love.audio.play(ghostVoice[math.random(1,5)])
        end
        if clueColor[i] >= 1 and clues[i].update_state == false then
          love.audio.play(letterChime[i])
          clues[i].update_state = true
        end
      end
    end
  end


  if love.keyboard.isDown('escape') then
    love.load()
  end

end

---------------------------------
-- Draw
---------------------------------

function level1draw()
   -- Each pixel touched by the circle will have its stencil value set to 1. The rest will be 0.
   love.graphics.stencil(finderLensStencil, "replace", 1)

   -- Draw Ghost
   local spriteNum0 = math.floor(ghostAnim.currentTime / ghostAnim.duration * #ghostAnim.quads) + 1
   love.graphics.draw(ghostAnim.spriteSheet, ghostAnim.quads[spriteNum0], 0, 270, 0, 1)

   -- Draw playable area
   love.graphics.setColor(1, 1, 1)
   love.graphics.rectangle("line", playableArea.x, playableArea.y,
      playableArea.size_x, playableArea.size_y)
   love.graphics.setColor(bgColor)
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
   love.graphics.setColor(1, 1, 1, 1) -- Color for finderHandle
   love.graphics.draw(finderLens.image, finderLens.x - 46, finderLens.y - 48) -- Offset numbers that will change with new artwork for finderHandle

   if clue2.update_state then
     enemy1:draw()
   end
   --enemy2:draw()

  if win then
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("You won!", 0, 0)
  end

  if timeElapsed > 5 and clueColor[1] > 0.3 then
    drawText("Oh! I just need more time on that clue!")
  elseif timeElapsed > 5 and clueColor[1] <= 0.3 then
    drawText("There must be a clue around here somewhere...")
  end

  if distanceBetween(enemy1.x, enemy1.y, finderLens.x, finderLens.y) <
    enemy1.size and enemy1.draw_state then
      local spriteNum1 = math.floor(
        loseStamp.currentTime / loseStamp.duration *
        #loseStamp.quads) + 1
      love.graphics.draw(
        loseStamp.spriteSheet, loseStamp.quads[spriteNum1],
        love.graphics.getWidth() / 2 - 125,
        love.graphics.getHeight() / 2 - 125, 0, 1)
      busted = true
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
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.printf(text, 30, 113, 180)
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
