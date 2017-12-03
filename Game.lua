local Camera = require("Camera")
local Physics = require("Physics")
local Level = require("Level")

local Game = {}
Game.__index = Game

function Game.new()
    local game = setmetatable({}, Game)
    game.camera = Camera.new({scale = 1 / 64})
    game.resources = {}
    game.resources.images = {}
    game.resources.images.armedMine = love.graphics.newImage("resources/images/armed-mine.png")
    game.resources.images.disarmedMine = love.graphics.newImage("resources/images/disarmed-mine.png")
    game.resources.images.jammer = love.graphics.newImage("resources/images/jammer.png")
    game.resources.images.pixel = love.graphics.newImage("resources/images/pixel.png")
    game.resources.images.stars = love.graphics.newImage("resources/images/stars.png")
    game.resources.images.wormhead = love.graphics.newImage("resources/images/wormhead.png")
    game.updateHandlers = {}
    game.collideHandlers = {}
    game.animateHandlers = {}
    game.drawHandlers = {}
    game.entities = {}
    game.entities.asteroid = {}
    game.entities.jammer = {}
    game.entities.mine = {}
    game.entities.ship = {}
    game.texelScale = 1 / 16
    game.spawnDistance = 64
    game.despawnDistance = 128
    game.physics = Physics.new()
    Level.new(game)
    return game
end

function Game:update(dt)
    for entity, handler in pairs(self.updateHandlers) do
        handler(entity, dt)
    end

    self.physics:update(dt)

    for entity, handler in pairs(self.collideHandlers) do
        handler(entity, dt)
    end

    for entity, handler in pairs(self.animateHandlers) do
        handler(entity, dt)
    end
end

function Game:draw()
    local viewportWidth, viewportHeight = love.graphics.getDimensions()
    love.graphics.translate(0.5 * viewportWidth, 0.5 * viewportHeight)
    local viewportScale = math.sqrt(viewportWidth ^ 2 + viewportHeight ^ 2)
    local scale = self.camera.scale * viewportScale
    love.graphics.scale(scale)
    love.graphics.setLineWidth(1 / scale)
    love.graphics.translate(-self.camera.x, -self.camera.y)
    self:drawParallaxStars(0.5, 1, 1)

    for entity, handler in pairs(self.drawHandlers) do
        handler(entity)
    end

    -- self.physics:draw()
end

function Game:drawParallaxStars(parallaxScale, scaleX, scaleY)
    local tileX1 = math.floor(parallaxScale * self.camera.x / 16) - 2
    local tileX2 = math.ceil(parallaxScale * self.camera.x / 16) + 2
    local tileY1 = math.floor(parallaxScale * self.camera.y / 16) - 2
    local tileY2 = math.ceil(parallaxScale * self.camera.y / 16) + 2

    for tileX = tileX1, tileX2 do
        for tileY = tileY1, tileY2 do
            local x = 16 * tileX + parallaxScale * self.camera.x
            local y = 16 * tileY + parallaxScale * self.camera.y

            love.graphics.draw(
                self.resources.images.stars,
                x, y,
                0,
                scaleX * self.texelScale, scaleY * self.texelScale,
                128, 128)
        end
    end

end

return Game
