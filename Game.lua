local Camera = require("Camera")
local Wormhead = require("Wormhead")

local Game = {}
Game.__index = Game

function Game.new()
    local game = setmetatable({}, Game)
    game.camera = Camera.new({scale = 1 / 32})
    game.resources = {}
    game.resources.images = {}
    game.resources.images.wormhead = love.graphics.newImage("resources/images/wormhead.png")
    game.updates = {}
    game.draws = {}
    game.texelScale = 1 / 16
    game.world = love.physics.newWorld(0, 0.1)
    Wormhead.new(game)
    return game
end

function Game:update(dt)
    for obj, func in pairs(self.updates) do
        func(obj, dt)
    end

    self.world:update(dt)
end

function Game:draw()
    local viewportWidth, viewportHeight = love.graphics.getDimensions()
    love.graphics.translate(0.5 * viewportWidth, 0.5 * viewportHeight)
    local viewportScale = math.sqrt(viewportWidth ^ 2 + viewportHeight ^ 2)
    local scale = self.camera.scale * viewportScale
    love.graphics.scale(scale)
    love.graphics.translate(-self.camera.x, -self.camera.y)

    for obj, func in pairs(self.draws) do
        func(obj)
    end
end

return Game
