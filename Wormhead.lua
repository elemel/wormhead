local Sprite = require("Sprite")
local Turner = require("Turner")

local WormHead = {}
WormHead.__index = WormHead

function WormHead.new(game, config)
    local head = setmetatable({}, WormHead)
    head.game = assert(game)
    head.game.updates[head] = WormHead.update
    head.game.draws[head] = WormHead.draw
    config = config or {}
    local world = assert(head.game.physics.world)
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    head.body = love.physics.newBody(world, x, y, "dynamic")
    head.body:setAngle(angle)
    local shape = love.physics.newCircleShape(0.5)
    head.fixture = love.physics.newFixture(head.body, shape)
    head.turner = Turner.new(head, {maxTorque = 16})
    head.sprite = Sprite.new(game, game.resources.images.wormhead)
    head.maxTurnSpeed = 2 * math.pi
    head.maxThrustForce = 8
    return head
end

function WormHead:destroy()
    self.turner:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.draws[self] = nil
    head.game.updates[head] = nil
end

function WormHead:update(dt)
    local leftInput = love.keyboard.isDown("a")
    local rightInput = love.keyboard.isDown("d")
    local upInput = love.keyboard.isDown("w")
    local downInput = love.keyboard.isDown("s")
    local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
    local inputY = (upInput and 1 or 0) - (downInput and 1 or 0)
    local turnSpeed = self.maxTurnSpeed * inputX
    self.turner.body:setAngularVelocity(turnSpeed)
    local thrustForce = self.maxThrustForce * inputY
    local forwardX, forwardY = self.body:getWorldVector(0, -1)
    self.body:applyForce(thrustForce * forwardX, thrustForce * forwardY)
end

function WormHead:draw()
    self.sprite.x, self.sprite.y = self.body:getPosition()
    self.sprite.angle = self.body:getAngle()
    self.sprite:draw()
end

return WormHead
