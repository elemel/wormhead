local Game = require("Game")

function love.load()
    love.window.setTitle("Wormhead")

    love.window.setMode(800, 600, {
        fullscreentype = "desktop",
        highdpi = true,
        resizable = true,
    })

    love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.physics.setMeter(1)
    game = Game.new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end
