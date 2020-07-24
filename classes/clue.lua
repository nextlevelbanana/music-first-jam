--! file: clue.lua

Clue = Object.extend(Object)

function Clue.new(self, u_state, d_state, x, y, letter)
  self.x = x
  self.y = y
  self.size = 20
  self.angle = math.random() * math.random(-1, 1)
  self.image = love.graphics.newImage("assets/temp/clueIconTemp.png")
  self.letter = love.graphics.newImage("assets/letters/letter"..letter..".png")
  self.color = 0.3
  self.origin_x = self.image:getWidth() / 2
  self.origin_y = self.image:getHeight() / 2
  self.update_state = u_state
  self.draw_state = d_state
end

function Clue:update(color, dt)
  -- empty
end

function Clue:draw(color, bgColor, letter)
  if color >= 1 then
    love.graphics.setColor(0.7, 0.7, 0.7)
    self.image = self.letter
    love.graphics.draw(self.image, self.x, self.y, self.angle, 1, 1, self.origin_x, self.origin_y)
    self.complete = true
  else
    love.graphics.setStencilTest("greater", 0)
    love.graphics.setColor(color, color, color)
    love.graphics.draw(self.image, self.x, self.y, self.angle, 1, 1, self.origin_x, self.origin_y)

    -- Now only allow rendering on pixels whose stencil value is equal to 0.
    love.graphics.setStencilTest("equal", 0)
    love.graphics.setColor(bgColor)
    love.graphics.draw(self.image, self.x, self.y, self.angle, 1, 1, self.origin_x, self.origin_y)
  end
end
