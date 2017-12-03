local Asteroid = require("Asteroid")
local Jammer = require("Jammer")
local Label = require("Label")
local Mine = require("Mine")
local Ship = require("Ship")
local Turret = require("Turret")
local utils = require("utils")

local Level = {}
Level.__index = Level

function Level.new(game, config)
    local level = setmetatable({}, Level)
    level.game = assert(game)
    level.game.updateHandlers[level] = level.update
    level.game.animateHandlers[level] = level.animate
    level.game.drawHudHandlers[level] = level.drawHud
    config = config or {}
    level.maxJammerCount = config.maxJammerCount or 4
    level.maxMineCount = config.maxMineCount or 16
    level.maxAsteroidCount = config.maxAsteroidCount or 8
    level.minAsteroidRadius = config.minAsteroidRadius or 8
    level.maxAsteroidRadius = config.maxAsteroidRadius or 16
    level.maxAngularVelocity = config.maxAngularVelocity or 0.125 * math.pi
    level.maxLinearVelocity = config.maxLinearVelocity or 1
    level.turretProbability = config.turretProbability or 0.25
    level.highscoreLabel = Label.new(level.game.fontCache)
    level.highscore = 0
    level.shipSpawnDelay = 0
    return level
end

function Level:destroy()
    self.game.drawHudHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
end

function Level:update(dt)
    self.shipSpawnDelay = self.shipSpawnDelay - dt

    if self.shipSpawnDelay < 0 and not next(self.game.entities.ship) then
        local angle = utils.generateAngle()
        local linearVelocityX, linearVelocityY = self:generateLinearVelocity()
        local angularVelocity = self:generateAngularVelocity()

        local ship = Ship.new(self.game, {
            angle = angle,
            linearVelocityX = linearVelocityX,
            linearVelocityY = linearVelocityY,
            angularVelocity = angularVelocity,
        })

        ship.level = self
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

    if utils.count(self.game.entities.asteroid) < self.maxAsteroidCount then
        local x, y = self:generateSpawnPosition()
        local angle = utils.generateAngle()
        local linearVelocityX, linearVelocityY = self:generateLinearVelocity()
        local angularVelocity = self:generateAngularVelocity()
        local scaleX = utils.mix(self.minAsteroidRadius, self.maxAsteroidRadius, love.math.random())
        local scaleY = utils.mix(self.minAsteroidRadius, self.maxAsteroidRadius, love.math.random())
        local vertexCount = 8
        local vertices = utils.generatePolygon(vertexCount, 0, 0, scaleX, scaleY, 0.75)

        local asteroid = Asteroid.new(self.game, {
            x = x,
            y = y,
            angle = angle,
            linearVelocityX = linearVelocityX,
            linearVelocityY = linearVelocityY,
            angularVelocity = angularVelocity,
            vertices = vertices,
        })

        for i = 1, vertexCount do
            if love.math.random() < self.turretProbability then
                local turretX1 = vertices[(2 * i - 3 - 1) % (2 * vertexCount) + 1]
                local turretY1 = vertices[(2 * i - 2 - 1) % (2 * vertexCount) + 1]
                local turretX2 = vertices[2 * i - 1]
                local turretY2 = vertices[2 * i]
                local turretX3 = vertices[(2 * i + 1 - 1) % (2 * vertexCount) + 1]
                local turretY3 = vertices[(2 * i + 2 - 1) % (2 * vertexCount) + 1]
                worldTurretX, worldTurretY = asteroid.body:getWorldPoint(turretX2, turretY2)
                local tangentX1, tangentY1 = utils.normalize2(turretX2 - turretX1, turretY2 - turretY1)
                local tangentX2, tangentY2 = utils.normalize2(turretX3 - turretX2, turretY3 - turretY2)
                local tangentX = 0.5 * (tangentX1 + tangentX2)
                local tangentY = 0.5 * (tangentY1 + tangentY2)
                local turretAngle = angle + math.atan2(tangentY, tangentX)

                Turret.new(asteroid, {
                    x = worldTurretX,
                    y = worldTurretY,
                    angle = turretAngle,
                })
            end
        end
    end
end

function Level:animate()
    local ship = next(self.game.entities.ship)

    if ship then
        local score = 0
        local tail = ship

        while tail.tailEdge do
            score = score + 1
            tail = tail.tailEdge.tail
        end

        self.highscore = math.max(self.highscore, score)
    end

    local width, height = love.graphics.getDimensions()
    local pixelScale = love.window.getPixelScale()
    self.highscoreLabel.fontSize = pixelScale * 32
    self.highscoreLabel.text = "HIGHSCORE " .. self.highscore
    self.highscoreLabel.alignmentY = 1
    self.highscoreLabel.x = math.floor(0.5 * width)
    self.highscoreLabel.y = height - pixelScale * 16
end

function Level:drawHud()
    self.highscoreLabel:draw()
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
