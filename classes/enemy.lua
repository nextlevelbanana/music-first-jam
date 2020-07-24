--! file: enemy.lua

--Pass Object as first argument
Enemy = Object.extend(Object)

local timeElapsed = 0

function Enemy.new(self, u_state, d_state, x, y)
  self.x = x
  self.y = y
  self.speed = 75
  self.angle = 0
  self.image = love.graphics.newImage("assets/enemies/angry.png")
  self.size = 40
  self.origin_x = self.image:getWidth() / 2
  self.origin_y = self.image:getHeight() / 2
  self.update_state = u_state
  self.draw_state = d_state
end

function Enemy:update(target, dt)
  timeElapsed = timeElapsed + 1 * dt

  if timeElapsed > 2 then
    self.angle = math.atan2(target.y - self.y, target.x - self.x)
    cos = math.cos(self.angle)
    sin = math.sin(self.angle)
    self.x = self.x + self.speed * cos * dt
    self.y = self.y + self.speed * sin * dt
  end
end

function Enemy:draw()
  love.graphics.draw(self.image, self.x, self.y, 0,
     1, 1, self.origin_x, self.origin_y)
end
