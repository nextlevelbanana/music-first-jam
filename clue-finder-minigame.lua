---------------------------------
-- Load
---------------------------------

function love.load()
  finderLens = {}  -- finderLens is the main controller component that reveals hidden "clues" within the background layer
  finderLens.x = (love.graphics.getWidth() / 2)
  finderLens.y = (love.graphics.getHeight() / 2)
  finderLens.size = 40  -- Size of the lens that reveals objects, 40 fits nicely with the current size of finderHandle, will change with art
  finderLens.speed = 150  -- Set player movement speed

  -- Load PNG files for static images
  finderHandle = love.graphics.newImage("finderHandle.png")
  arrowRight = love.graphics.newImage("arrowRight.png")

  -- Contain controller within screen bounds
  roomWidth = love.graphics.getWidth() - finderLens.size
  roomHeight = love.graphics.getHeight() - finderLens.size

  -- Set background color; bgColor is also called by generateClue() below
  bgColor = {0.592, 0.706, 0.773}
  love.graphics.setBackgroundColor(bgColor)
end

---------------------------------
-- Update
---------------------------------

function love.update(dt)

  -- Controls for finderLens() using arrow keys or WASD - bound by roomWidth and roomHeight
  if finderLens.x <= roomWidth and
    love.keyboard.isDown('right') or love.keyboard.isDown('d') then
      finderLens.x = finderLens.x + finderLens.speed * dt
  end
  if finderLens.x >= finderLens.size and
    love.keyboard.isDown('left') or love.keyboard.isDown('a') then
      finderLens.x = finderLens.x - finderLens.speed * dt
  end
  if finderLens.y <= roomHeight and
    love.keyboard.isDown('down') or love.keyboard.isDown('s') then
      finderLens.y = finderLens.y + finderLens.speed * dt
  end
  if finderLens.y >= finderLens.size and
    love.keyboard.isDown('up') or love.keyboard.isDown('w') then
      finderLens.y = finderLens.y - finderLens.speed * dt
  end

end

---------------------------------
-- Draw
---------------------------------

local function finderLensStencil()
   -- Stencil function that is used to reveal hidden "clue" layer
   love.graphics.circle("fill", finderLens.x, finderLens.y, finderLens.size)
end

function love.draw()
   -- Each pixel touched by the circle will have its stencil value set to 1. The rest will be 0.
   love.graphics.stencil(finderLensStencil, "replace", 1)

   -- generateClue can be used to instance any raster image given a variable name in love.load() above
   generateClue(arrowRight, 400, 300) -- Create rightArrow at 400, 300
   generateClue(arrowRight, 600, 300) -- Create rightArrow at 600, 300

   love.graphics.setStencilTest() -- Handles wild stencil stuff I don't fully understand
   love.graphics.setColor(1, 1, 1, 1) -- Color for finderHandle
   love.graphics.draw(finderHandle, finderLens.x - 46, finderLens.y - 48) -- Offset numbers that will change with new artwork for finderHandle
end

---------------------------------
-- Other functions
---------------------------------

function generateClue(image, x, y)
  -- Only allow rendering on pixels whose stencil value is greater than 0.
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0, 0, 0)
  love.graphics.draw(image, x, y)

  -- Now only allow rendering on pixels whose stencil value is equal to 0.
  love.graphics.setStencilTest("equal", 0)
  love.graphics.setColor(bgColor)
  love.graphics.draw(image, x, y)
end
