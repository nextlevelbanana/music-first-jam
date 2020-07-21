Object = require("libs/classic")

require("title")
require("menu")
require("lore")
require("minigame-1-rename-me")

bgm = love.audio.newSource("assets/music/main_theme.wav", "stream")
bgm:setLooping(true)
bgm:setVolume(0.5)
love.audio.play(bgm)

function love.load()
    minigame1load()
    scene="title"
end

function love.update(dt)
    if scene=="title" then
        titleupdate()
    elseif scene=="menu" then
        menuupdate()
    elseif scene=="minigame-1-rename-me" then
        minigame1update(dt)
    elseif scene=="lore" then
        loreupdate()
    end
end

function love.draw()
    if scene=="title" then
        titledraw()
    elseif scene=="menu" then
        menudraw()
    elseif scene=="minigame-1-rename-me" then
        minigame1draw()
    elseif scene=="lore" then
        loredraw()
    else
        love.graphics.print("???", 200,200)
    end
end
