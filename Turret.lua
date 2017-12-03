local Bullet = require("Bullet")
local Sprite = require("Sprite")
local utils = require("utils")

local Turret = {}
Turret.__index = Turret
Turret.entityType = "turret"

function Turret.new(asteroid, config)
    local turret = setmetatable({}, Turret)
    turret.asteroid = assert(asteroid)
    turret.asteroid.turrets[turret] = true
    turret.game = assert(asteroid.game)
    turret.game.updateHandlers[turret] = turret.update
    turret.game.animateHandlers[turret] = turret.animate
    turret.game.drawHandlers[turret] = turret.draw
    turret.groupIndex = turret.game.physics:generateGroupIndex()
    local world = assert(turret.game.physics.world)
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    turret.body = love.physics.newBody(world, x, y, "dynamic")
    turret.body:setAngle(angle)
    local shape = love.physics.newRectangleShape(1, 1)
    turret.fixture = love.physics.newFixture(turret.body, shape, 16)

    turret.fixture:setUserData({
        entity = turret,
        userType = "turret",
    })

    turret.fixture:setGroupIndex(-turret.groupIndex)
    local referenceAngle = angle - turret.asteroid.body:getAngle()
    turret.joint = love.physics.newWeldJoint(turret.asteroid.body, turret.body, x, y, x, y, false, referenceAngle)
    turret.sprite = Sprite.new(turret.game, turret.game.resources.images.turret)
    turret.maxCooldown = 3
    turret.cooldown = turret.maxCooldown * love.math.random()
    turret.destroyed = false
    return turret
end

function Turret:destroy()
    self.destroyed = true
    self.joint:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
    self.asteroid.turrets[self] = nil
end

function Turret:update(dt)
    self.cooldown = self.cooldown - dt

    if self.cooldown < 0 then
        self.cooldown = self.maxCooldown
        local x, y = self.body:getWorldPoint(0, -0.5)
        local angle = -0.5 * math.pi + utils.mix(-0.25 * math.pi, 0.25 * math.pi, love.math.random())
        local directionX = math.cos(angle) 
        local directionY = math.sin(angle) 
        local worldDirectionX, worldDirectionY = self.body:getWorldVector(directionX, directionY)
        local linearVelocityX, linearVelocityY = self.body:getLinearVelocityFromLocalPoint(0, -0.5)
        local bulletLinearVelocityX = linearVelocityX + 4 * worldDirectionX
        local bulletLinearVelocityY = linearVelocityY + 4 * worldDirectionY

        Bullet.new(self.game, {
            x = x,
            y = y,
            linearVelocityX = bulletLinearVelocityX,
            linearVelocityY = bulletLinearVelocityY,
            groupIndex = -self.groupIndex,
        })
    end
end

function Turret:animate()
    local x, y = self.body:getPosition()
    self.sprite.x, self.sprite.y = x, y
    self.sprite.angle = self.body:getAngle()
end

function Turret:draw()
    self.sprite:draw()
end

return Turret
