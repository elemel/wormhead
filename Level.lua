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
    return level
end

function Level:destroy()
    self.game.updateHandlers[self] = nil
end

function Level:update(dt)
    if not next(self.game.entities.ship) then
        Ship.new(self.game)
    end

    if utils.count(self.game.entities.jammer) < self.maxJammerCount then
        local x, y = self:generateSpawnPosition()

        Jammer.new(self.game, {
            x = x,
            y = y,
            angle = utils.generateAngle(),
        })
    end

    if utils.count(self.game.entities.mine) < self.maxMineCount then
        local x, y = self:generateSpawnPosition()

        Mine.new(self.game, {
            x = x,
            y = y,
            angle = utils.generateAngle(),
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

return Level
