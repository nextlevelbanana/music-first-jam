--! file: enemy.lua

--Pass Object as first argument
Enemy = Object.extend(Object)

function Enemy.new(self, x, y)
  self.x = x
  self.y = y
  self.speed = 100
  self.angle = 0
  self.image = love.graphics.newImage("assets/temp/arrowRight.png")
  self.size = 40
  self.origin_x = self.image:getWidth() / 2
  self.origin_y = self.image:getHeight() / 2
end

function Enemy:update(target, dt)

  -- NOTE: this code is currently contained in the minigame update per enemy instance
  self.angle = math.atan2(target.y - self.y, target.x - self.x)
  cos = math.cos(self.angle)
  sin = math.sin(self.angle)
  self.x = self.x + self.speed * cos * dt
  self.y = self.y + self.speed * sin * dt
end

function Enemy:draw()
  love.graphics.draw(self.image, self.x, self.y, self.angle,
     1, 1, self.origin_x, self.origin_y)
end
