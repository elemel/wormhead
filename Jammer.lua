local Sprite = require("Sprite")
local utils = require("utils")

local Jammer = {}
Jammer.__index = Jammer
Jammer.entityType = "jammer"

function Jammer.new(game, config)
    local jammer = setmetatable({}, Jammer)
    jammer.game = assert(game)
    jammer.game.entities.jammer[jammer] = true
    jammer.game.updateHandlers[jammer] = jammer.update
    jammer.game.animateHandlers[jammer] = jammer.animate
    jammer.game.drawHandlers[jammer] = jammer.draw
    local world = assert(jammer.game.physics.world)
    config = config or {}
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    jammer.body = love.physics.newBody(world, x, y, "dynamic")
    jammer.body:setAngle(angle)
    local shape = love.physics.newCircleShape(0.5)
    jammer.fixture = love.physics.newFixture(jammer.body, shape)

    jammer.fixture:setUserData({
        entity = jammer,
        userType = "jammer",
    })

    jammer.sensorRadius = config.sensorRadius or 4.5
    local sensorShape = love.physics.newCircleShape(jammer.sensorRadius)
    jammer.sensorFixture = love.physics.newFixture(jammer.body, sensorShape, 0)

    jammer.sensorFixture:setUserData({
        entity = jammer,
        userType = "jammingSignal",
    })

    jammer.sensorFixture:setSensor(true)
    jammer.sprite = Sprite.new(game, game.resources.images.jammer)
    jammer.blinkTime = 2 * math.pi * love.math.random()
    return jammer
end

function Jammer:destroy()
    self.sensorFixture:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
    self.game.entities.jammer[self] = nil
end

function Jammer:update(dt)
    local x, y = self.body:getPosition()

    if utils.distance2(x, y, self.game.camera.x, self.game.camera.y) > self.game.despawnDistance then
        self:destroy()
        return
    end
end

function Jammer:animate(dt)
    self.sprite.x, self.sprite.y = self.body:getPosition()
    self.sprite.angle = self.body:getAngle()
    self.blinkTime = self.blinkTime + dt
end

function Jammer:draw()
    self.sprite:draw()

    local alpha = 0xff * (0.5 + 0.125 * math.sin(math.pi * self.blinkTime))
    love.graphics.setColor(0x00, 0x99, 0xff, alpha)
    love.graphics.circle("line", self.sprite.x, self.sprite.y, self.sensorRadius, 64)
    love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
end

return Jammer
