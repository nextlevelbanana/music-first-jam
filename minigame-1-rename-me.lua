require("classes/enemy")
require("classes/clue")

-- Animations
ghost = {}
for i = 0,7 do
  table.insert(ghost, love.graphics.newImage("assets/ghost_detective/ghost"..i..".png"))
end
animationFrame = 1

-- Audio and SFX
ghostVoice = {}
for i = 0,4 do
  table.insert(ghostVoice, love.audio.newSource("assets/sfx/hmm"..i..".wav", "static"))
end

letters = {"E", "G", "B", "D", "F"}
numOfClues = #letters

bgColor = {0.15, 0.15, 0.15}
speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")

---------------------------------
-- Local variables
---------------------------------

function minigame1load()

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

  -- Instantiate enemies
  enemy1 = Enemy(false, false, 300, 200)

  -- Instantiate clues
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

function minigame1update(dt)

  timeElapsed = timeElapsed + 1 * dt

  -- Runs animations
  animationFrame = animationFrame + dt * 5
  if animationFrame >= 9 then
    animationFrame = 1
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
    --local timeElapsed = 0
    --if timeElapsed > 2 then
    enemy1:update(finderLens, dt)
    enemy1.update_state = true
    enemy1.draw_state = true
  end

  -- Distance checks
  if busted then
    love.event.wait(1000)
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
        if love.audio.getActiveSourceCount() < 2 and clues[i].draw_state then
          love.audio.play(ghostVoice[math.random(1,5)])
        end
        if clueColor[i] >= 1 then
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

function minigame1draw()
   -- Each pixel touched by the circle will have its stencil value set to 1. The rest will be 0.
   love.graphics.stencil(finderLensStencil, "replace", 1)

   --love.graphics.print(numOfClues, 100, 100)

   -- Draw ghost
   love.graphics.push()
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.translate(-20, 250)
   love.graphics.scale(0.15, 0.15)
   love.graphics.draw(ghost[math.floor(animationFrame)])
   love.graphics.pop()

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
         --clues[i+1]:draw(clueColor[i+1], bgColor, letters[i+1])
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

  if distanceBetween(enemy1.x, enemy1.y, finderLens.x, finderLens.y) < enemy1.size and enemy1.draw_state then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Busted!", finderLens.x - 46, finderLens.y - 100)
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
