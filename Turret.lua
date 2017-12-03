local Sprite = require("Sprite")

local Turret = {}
Turret.__index = Turret
Turret.entityType = "turret"

function Turret.new(asteroid, config)
    local turret = setmetatable({}, Turret)
    turret.asteroid = assert(asteroid)
    turret.asteroid.turrets[turret] = true
    turret.game = assert(asteroid.game)
    turret.game.animateHandlers[turret] = turret.animate
    turret.game.drawHandlers[turret] = turret.draw
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

    local referenceAngle = angle - turret.asteroid.body:getAngle()
    turret.joint = love.physics.newWeldJoint(turret.asteroid.body, turret.body, x, y, x, y, false, referenceAngle)
    turret.sprite = Sprite.new(turret.game, turret.game.resources.images.turret)
    return turret
end

function Turret:destroy()
    self.joint:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.animateHandlers[self] = nil
    self.game.drawHandlers[self] = nil
    self.asteroid.turrets[self] = nil
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
