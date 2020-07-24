Object = require("libs/classic")
tween = require("libs/tween")
cron = require("libs/cron")


require("title")
require("menu")
require("lore")
require("level-1")

math.randomseed(os.time())

function love.load()
    titleload()
    level1load()
    scene="title"
end

function love.update(dt)
    if scene=="title" then
        titleupdate(dt)
    elseif scene=="menu" then
        menuupdate(dt)
    elseif scene=="level-1" then
        level1update(dt)
    elseif scene=="lore" then
        loreupdate(dt)
    end
end

function love.draw()
    if scene=="title" then
        titledraw()
    elseif scene=="menu" then
        menudraw()
    elseif scene=="level-1" then
        level1draw()
    elseif scene=="lore" then
        loredraw()
    else
        love.graphics.print("???", 200,200)
    end
end
