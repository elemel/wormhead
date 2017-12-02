local Explosion = require("Explosion")
local Sprite = require("Sprite")
local utils = require("utils")

local Mine = {}
Mine.__index = Mine
Mine.entityType = "mine"

function Mine.new(game, config)
    local mine = setmetatable({}, Mine)
    mine.game = assert(game)
    mine.game.entities.mine[mine] = true
    mine.game.updateHandlers[mine] = mine.update
    mine.game.animateHandlers[mine] = mine.animate
    mine.game.drawHandlers[mine] = mine.draw
    local world = assert(mine.game.physics.world)
    config = config or {}
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    mine.body = love.physics.newBody(world, x, y, "dynamic")
    mine.body:setAngle(angle)
    local shape = love.physics.newCircleShape(0.5)
    mine.fixture = love.physics.newFixture(mine.body, shape)

    mine.fixture:setUserData({
        entity = mine,
        userType = "mine",
    })

    mine.sensorRadius = config.sensorRadius or 2.5
    local sensorShape = love.physics.newCircleShape(mine.sensorRadius)
    mine.sensorFixture = love.physics.newFixture(mine.body, sensorShape, 0)

    mine.sensorFixture:setUserData({
        entity = mine,
        userType = "proximitySensor",
    })

    mine.sensorFixture:setSensor(true)
    mine.sprite = Sprite.new(game, game.resources.images.disarmedMine)
    mine.state = "armed"
    mine.blinkTime = 2 * math.pi * love.math.random()
    mine.destroyed = false
    return mine
end

function Mine:destroy()
    self.destroyed = true

    if self.tailEdge then
        self.tailEdge:destroy()
    end

    if self.headEdge then
        self.headEdge:destroy()
    end

    self.sensorFixture:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
    self.game.entities.mine[self] = nil
end

function Mine:update(dt)
    local x, y = self.body:getPosition()

    if utils.distance2(x, y, self.game.camera.x, self.game.camera.y) > self.game.despawnDistance then
        self:destroy()
        return
    end

    local jammingSignalCount = 0
    local targetCount = 0

    for i, contact in ipairs(self.body:getContactList()) do
        if contact:isTouching() then
            local fixtureA, fixtureB = contact:getFixtures()
            local direction = 1

            if fixtureA:getBody() ~= self.body then
                fixtureA, fixtureB = fixtureB, fixtureA
                direction = -1
            end

            local userData = assert(fixtureB:getUserData())

            if fixtureA == self.fixture then
                if userData.userType == "jammingSignal" then
                    jammingSignalCount = jammingSignalCount + 1
                end
            end

            if fixtureA == self.sensorFixture then
                if userData.userType == "ship" then
                    targetCount = targetCount + 1
                end
            end
        end
    end

    if self.headEdge and self.headEdge.head.entityType == "jammer" then
        jammingSignalCount = jammingSignalCount + 1
    end

    if self.tailEdge and self.tailEdge.tail.entityType == "jammer" then
        jammingSignalCount = jammingSignalCount + 1
    end

    if jammingSignalCount == 0 then
        self.state = "armed"
    else
        self.state = "disarmed"
    end

    if self.state == "armed" and targetCount >= 1 then
        local x, y = self.body:getPosition()
        Explosion.new(self.game, {x = x, y = y})
        self:destroy()
    end
end

function Mine:animate(dt)
    if self.state == "armed" then
        self.sprite.image = assert(self.game.resources.images.armedMine)
    elseif self.state == "disarmed" then
        self.sprite.image = assert(self.game.resources.images.disarmedMine)
    end

    self.sprite.x, self.sprite.y = self.body:getPosition()
    self.sprite.angle = self.body:getAngle()
    self.blinkTime = self.blinkTime + dt
end

function Mine:draw()
    self.sprite:draw()

    if self.state == "armed" then
        local alpha = 0xff * (0.5 + 0.25 * math.sin(4 * math.pi * self.blinkTime))
        love.graphics.setColor(0xff, 0x99, 0x00, alpha)
        love.graphics.circle("line", self.sprite.x, self.sprite.y, self.sensorRadius, 64)
        love.graphics.setColor(0xff, 0xff, 0xff, 0xff)
    end
end

return Mine
