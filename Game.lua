local Camera = require("Camera")
local Mine = require("Mine")
local Physics = require("Physics")
local WormHead = require("WormHead")

local Game = {}
Game.__index = Game

function Game.new()
    local game = setmetatable({}, Game)
    game.camera = Camera.new({scale = 1 / 32})
    game.resources = {}
    game.resources.images = {}
    game.resources.images.mine = love.graphics.newImage("resources/images/mine.png")
    game.resources.images.wormhead = love.graphics.newImage("resources/images/wormhead.png")
    game.updates = {}
    game.draws = {}
    game.texelScale = 1 / 16
    game.physics = Physics.new()
    WormHead.new(game)
    Mine.new(game)
    return game
end

function Game:update(dt)
    for obj, func in pairs(self.updates) do
        func(obj, dt)
    end

    self.physics:update(dt)
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
