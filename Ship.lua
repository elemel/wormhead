local Sprite = require("Sprite")
local Turner = require("Turner")

local Ship = {}
Ship.__index = Ship
Ship.entityType = "ship"

function Ship.new(game, config)
    local ship = setmetatable({}, Ship)
    ship.game = assert(game)
    ship.game.entities.ship[ship] = true
    ship.game.updateHandlers[ship] = ship.update
    ship.game.animateHandlers[ship] = ship.animate
    ship.game.drawHandlers[ship] = ship.draw
    ship.groupIndex = ship.game.physics:generateGroupIndex()
    config = config or {}
    local world = assert(ship.game.physics.world)
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    ship.body = love.physics.newBody(world, x, y, "dynamic")
    ship.body:setAngle(angle)
    local shape = love.physics.newCircleShape(0.5)
    ship.fixture = love.physics.newFixture(ship.body, shape, 8)
    ship.fixture:setGroupIndex(-ship.groupIndex)

    ship.fixture:setUserData({
        entity = ship,
        userType = "ship",
    })

    ship.turner = Turner.new(ship, {maxTorque = 16})
    ship.sprite = Sprite.new(game, game.resources.images.wormhead)
    ship.maxTurnSpeed = 2 * math.pi
    ship.maxThrustForce = 64
    ship.destroyed = false
    return ship
end

function Ship:destroy()
    self.destroyed = true
    self.turner:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
    self.game.entities.ship[self] = nil
end

function Ship:update(dt)
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

function Ship:animate()
    local x, y = self.body:getPosition()
    self.game.camera.x = x
    self.game.camera.y = y
    self.sprite.x, self.sprite.y = x, y
    self.sprite.angle = self.body:getAngle()
end

function Ship:draw()
    self.sprite:draw()
end

return Ship
