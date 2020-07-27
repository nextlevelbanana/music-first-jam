function loreupdate()
  if love.keyboard.isDown('escape') then
    scene = "title"
  end
end

function loredraw()
    love.graphics.draw(background, 0, 0, 0, 0.25, 0.25)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Credits", 100,50)
    love.graphics.print("Code: Jordan Laurent", 100,100)
    love.graphics.print("Art: Amanda Rivera", 100,150)
    love.graphics.print("Music and SFX: Makenna Bach", 100,200)
    love.graphics.print("With special thanks to Qristy Overton!", 100,250)
    love.graphics.print("Press ESC to return to the main menu.", 10,10)
end
