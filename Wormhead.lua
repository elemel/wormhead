local Sprite = require("Sprite")
local Turner = require("Turner")

local Wormhead = {}
Wormhead.__index = Wormhead

function Wormhead.new(game, config)
    local wormhead = setmetatable({}, Wormhead)
    wormhead.game = assert(game)
    wormhead.game.updates[wormhead] = Wormhead.update
    wormhead.game.draws[wormhead] = Wormhead.draw
    config = config or {}
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    wormhead.body = love.physics.newBody(wormhead.game.world, x, y, "dynamic")
    wormhead.body:setAngle(angle)
    local shape = love.physics.newCircleShape(0.5)
    wormhead.fixture = love.physics.newFixture(wormhead.body, shape)
    wormhead.turner = Turner.new(wormhead, {maxTorque = 16})
    wormhead.sprite = Sprite.new(game, game.resources.images.wormhead)
    wormhead.maxTurnSpeed = 2 * math.pi
    wormhead.maxThrustForce = 8
    return wormhead
end

function Wormhead:destroy()
    self.turner:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.draws[self] = nil
    wormhead.game.updates[wormhead] = nil
end

function Wormhead:update(dt)
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

function Wormhead:draw()
    self.sprite.x, self.sprite.y = self.body:getPosition()
    self.sprite.angle = self.body:getAngle()
    self.sprite:draw()
end

return Wormhead
