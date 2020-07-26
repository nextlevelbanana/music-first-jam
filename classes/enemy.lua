--! file: enemy.lua

--Pass Object as first argument
Enemy = Object.extend(Object)

local timeElapsed = 0

function Enemy.new(self, u_state, d_state, x, y)
  --self.anim = newAnimation(love.graphics.newImage("assets/enemies/angryAnim.png"), 250, 250, 4)
  self.x = x
  self.y = y
  self.speed = 75
  self.angle = 0
  self.size = 50
  self.origin_x = 125
  self.origin_y = 125
  self.update_state = u_state
  self.draw_state = d_state
  self.previous_x = 0
end

function Enemy:update(target, speed, dt)
  timeElapsed = timeElapsed + 1 * dt

  if timeElapsed > 2 then
    self.angle = math.atan2(target.y - self.y, target.x - self.x)
    cos = math.cos(self.angle)
    sin = math.sin(self.angle)
    self.previous_x = self.x
    self.x = self.x + math.max(self.speed, speed)  * cos * dt
    self.y = self.y + math.max(self.speed, speed) * sin * dt
  end
end

function Enemy:draw(anim)
  local spriteNum = math.floor(anim.currentTime / anim.duration * #anim.quads) + 1
  if self.previous_x > self.x then
    love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], self.x, self.y, 0, -1, 1, self.origin_x, self.origin_y)
  else
    love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], self.x, self.y, 0, 1, 1, self.origin_x, self.origin_y)
  end
end
