require("classes/enemy")

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

  -- Clue instantiator
  clueInst = {}
  clueInst.x = 400
  clueInst.y = 300
  clueInst.size = 40
  clueInst.image = love.graphics.newImage("assets/temp/clueIconTemp.png")

  -- Enemy controller variables
  enemy1 = Enemy(300, 200)
  enemy2 = Enemy(700, 500)

  -- Animations
  ghost = {}
  for i = 0,7 do
    table.insert(ghost, love.graphics.newImage("assets/ghost_detective/ghost"..i..".png"))
  end
  animationFrame = 1

  -- Audio and SFX

  -- local bgm = love.audio.newSource("assets/music/main_theme.wav", "stream")
  ghostVoice = {}
  for i = 0,4 do
    table.insert(ghostVoice, love.audio.newSource("assets/sfx/hmm"..i..".wav", "static"))
  end

  -- Bounding box for keeping the finderLens in the playable area
  roomWidth = playableArea.size_x - finderLens.size
  roomHeight = playableArea.size_y - finderLens.size

  -- Unsorted variables
  bgColor = {0.15, 0.15, 0.15}
  win = false
  clueColor = 0.3
  timeElapsed = 0
  speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")
  busted = false

  -- Unsorted set conditions
  love.graphics.newFont(35)
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

  -- Local Audio params
  -- bgm:setLooping(true)
  -- bgm:setVolume(0.5)
  -- love.audio.play(bgm)
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
  if not win and timeElapsed > 2 then
    enemy1:update(finderLens, dt)
    enemy2:update(finderLens, dt)
  end

  -- Distance checks
  if busted then
    love.event.wait(1000)
    love.load()
  end

  --for i = clues
  if distanceBetween(clueInst.x, clueInst.y, finderLens.x, finderLens.y) < clueInst.size then
    clueColor = clueColor + (0.3 * dt)
    if love.audio.getActiveSourceCount() < 2 then
      love.audio.play(ghostVoice[math.random(0,4)])
    end
    if clueColor >= 1 then
      win = true
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

   -- generateClue can be used to instance any raster image given a variable name in love.load() above
   clue = generateClue(clueInst.image, 400, 300) -- Create rightenemy at 400, 300
   --generateClue(clueInst.image, 600, 300) -- Create rightenemy at 600, 300

   love.graphics.setStencilTest() -- Handles wild stencil stuff I don't fully understand
   love.graphics.setColor(1, 1, 1, 1) -- Color for finderHandle
   love.graphics.draw(finderLens.image, finderLens.x - 46, finderLens.y - 48) -- Offset numbers that will change with new artwork for finderHandle

   enemy1:draw()
   enemy2:draw()

  if win then
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("You won!", 0, 0)
  end

  if timeElapsed > 5 and clueColor > 0.3 then
    drawText("Oh! I just need more time on that clue!")
  elseif timeElapsed > 5 and clueColor <= 0.3 then
    drawText("There must be a clue around here somewhere...")
  end

  if distanceBetween(enemy1.x, enemy1.y, finderLens.x, finderLens.y) < enemy1.size then
    love.graphics.print("Busted!", finderLens.x - 46, finderLens.y - 100)
    busted = true

  end

end

---------------------------------
-- Other functions
---------------------------------

function generateClue(image, x, y)
  -- Only allow rendering on pixels whose stencil value is greater than 0.
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(clueColor, clueColor, clueColor)
  love.graphics.draw(image, x, y)

  -- Now only allow rendering on pixels whose stencil value is equal to 0.
  love.graphics.setStencilTest("equal", 0)
  love.graphics.setColor(bgColor)
  love.graphics.draw(image, x, y)
end

function distanceBetween (x1, y1, x2, y2)
	-- distance formula: d = √(y2 - y1)^2 + (x2 - x1)^2
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function drawText(text)
  love.graphics.draw(speechBubble, 17, 100)
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.printf(text, 30, 113, 180)
end
