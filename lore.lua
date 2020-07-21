function loreupdate()
  if love.keyboard.isDown('escape') then
    scene = "title"
  end
end

function loredraw()
    love.graphics.setColor(1,1,1)
    love.graphics.print("Press ESC to return to the main menu.", 10,10)
end
