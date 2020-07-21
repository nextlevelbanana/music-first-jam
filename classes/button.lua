Button = Object.extend(Object)

function Button.new(self, x, y, string, font)
  self.x = x
  self.y = y
  self.width = 150
  self.height = 50
  self.text = string
  self.font = font
  self.size_x = self.x + self.width
  self.size_y = self.y + self.height
end

function Button:update(dt)

end

function Button:draw()
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  love.graphics.setFont(self.font)
  love.graphics.print(self.text, self.x+25, self.y+5)
end
