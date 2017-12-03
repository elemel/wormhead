local Jammer = require("Jammer")
local Mine = require("Mine")
local Ship = require("Ship")
local utils = require("utils")

local Level = {}
Level.__index = Level

function Level.new(game, config)
    local level = setmetatable({}, Level)
    level.game = assert(game)
    level.game.updateHandlers[level] = level.update
    config = config or {}
    level.maxJammerCount = config.maxJammerCount or 4
    level.maxMineCount = config.maxMineCount or 32
    level.maxAngularVelocity = config.maxAngularVelocity or math.pi
    level.maxLinearVelocity = config.maxLinearVelocity or 1
    return level
end

function Level:destroy()
    self.game.updateHandlers[self] = nil
end

function Level:update(dt)
    if not next(self.game.entities.ship) then
        local angle = utils.generateAngle()
        local linearVelocityX, linearVelocityY = self:generateLinearVelocity()
        local angularVelocity = self:generateAngularVelocity()

        Ship.new(self.game, {
            angle = angle,
            linearVelocityX = linearVelocityX,
            linearVelocityY = linearVelocityY,
            angularVelocity = angularVelocity,
        })
    end

    if utils.count(self.game.entities.jammer) < self.maxJammerCount then
        local x, y = self:generateSpawnPosition()
        local angle = utils.generateAngle()
        local linearVelocityX, linearVelocityY = self:generateLinearVelocity()
        local angularVelocity = self:generateAngularVelocity()

        Jammer.new(self.game, {
            x = x,
            y = y,
            angle = angle,
            linearVelocityX = linearVelocityX,
            linearVelocityY = linearVelocityY,
            angularVelocity = angularVelocity,
        })
    end

    if utils.count(self.game.entities.mine) < self.maxMineCount then
        local x, y = self:generateSpawnPosition()
        local angle = utils.generateAngle()
        local linearVelocityX, linearVelocityY = self:generateLinearVelocity()
        local angularVelocity = self:generateAngularVelocity()

        Mine.new(self.game, {
            x = x,
            y = y,
            angle = angle,
            linearVelocityX = linearVelocityX,
            linearVelocityY = linearVelocityY,
            angularVelocity = angularVelocity,
        })
    end
end

function Level:generateSpawnPosition()
    local directionX, directionY = utils.generateDirection()
    local distance = utils.mix(self.game.spawnDistance, self.game.despawnDistance, love.math.random())
    local x = self.game.camera.x + distance * directionX
    local y = self.game.camera.y + distance * directionY
    return x, y
end

function Level:generateLinearVelocity()
    local linearVelocity = self.maxLinearVelocity * love.math.random()
    local directionX, directionY = utils.generateDirection()
    return linearVelocity * directionX, linearVelocity * directionY
end

function Level:generateAngularVelocity()
    return utils.mix(-self.maxAngularVelocity, self.maxAngularVelocity, love.math.random())
end

return Level
