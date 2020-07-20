---------------------------------
-- Local variables
---------------------------------

-- Playable area container
local playableArea = {}
playableArea.x = 250
playableArea.y = 20
playableArea.border = 20
playableArea.size_x = love.graphics.getWidth() - playableArea.x - playableArea.border
playableArea.size_y = love.graphics.getHeight() - playableArea.y - playableArea.border

-- Main player cursor
local finderLens = {}  -- finderLens is the main controller component that reveals hidden "clues" within the background layer
finderLens.x = (love.graphics.getWidth() / 2) + (playableArea.x / 2)
finderLens.y = (love.graphics.getHeight() / 2) + (playableArea.y / 2)
finderLens.size = 40  -- Size of the lens that reveals objects, 40 fits nicely with the current size of finderHandle, will change with art
finderLens.speed = 200  -- Set player movement speed
finderLens.image = love.graphics.newImage("assets/temp/finderHandle.png")

local clueInst = {}
clueInst.x = 400
clueInst.y = 300
clueInst.size = 40
clueInst.image = love.graphics.newImage("assets/temp/clueIconTemp.png")

-- Enemy controller variables
local enemy = {}
enemy.x = 300
enemy.y = 200
enemy.speed = 100
enemy.angle = 0
enemy.image = love.graphics.newImage("assets/temp/arrowRight.png")
enemy.size = 40
enemy.origin_x = enemy.image:getWidth() / 2
enemy.origin_y = enemy.image:getHeight() / 2

local ghost = {}
for i = 0,7 do
  table.insert(ghost, love.graphics.newImage("assets/ghost_detective/ghost"..i..".png"))
end

local ghostVoice = {}
for i = 0,4 do
  table.insert(ghostVoice, love.audio.newSource("assets/sfx/hmm"..i..".wav", "static"))
end

local isMoving = false
local roomWidth = playableArea.size_x - finderLens.size
local roomHeight = playableArea.size_y - finderLens.size
local bgm = love.audio.newSource("assets/music/main_theme.wav", "stream")
local animationFrame = 1
local bgColor = {0.15, 0.15, 0.15}
local win = false
local clueColor = 0.3
local timeElapsed = 0
local speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")

love.graphics.newFont(35)
love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
bgm:setLooping(true)
love.audio.play(bgm)

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
    enemy.angle = math.atan2(finderLens.y - enemy.y, finderLens.x - enemy.x)
    cos = math.cos(enemy.angle)
    sin = math.sin(enemy.angle)
    enemy.x = enemy.x + enemy.speed * cos * dt
    enemy.y = enemy.y + enemy.speed * sin * dt
  end

  -- Distance checks
  if distanceBetween(enemy.x, enemy.y, finderLens.x, finderLens.y) < enemy.size then
    love.event.quit("restart")
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

   love.graphics.draw(enemy.image, enemy.x, enemy.y, enemy.angle,
      1, 1, enemy.origin_x, enemy.origin_y)

  if win then
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("You won!", 0, 0)
  end

  if timeElapsed > 5 and clueColor > 0.3 then
    drawText("Oh! I just need more time on that clue!")
  elseif timeElapsed > 5 and clueColor <= 0.3 then
    drawText("There must be a clue around here somewhere...")
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
