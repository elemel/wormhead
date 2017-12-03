local Bullet = require("Bullet")
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
    local linearVelocityX = config.linearVelocityX or 0
    local linearVelocityY = config.linearVelocityY or 0
    ship.body:setLinearVelocity(linearVelocityX, linearVelocityY)
    local angularVelocity = config.angularVelocity or 0
    ship.body:setAngularVelocity(angularVelocity)
    local shape = love.physics.newCircleShape(0.5)
    ship.fixture = love.physics.newFixture(ship.body, shape, 16)
    ship.fixture:setGroupIndex(-ship.groupIndex)

    ship.fixture:setUserData({
        entity = ship,
        userType = "ship",
    })

    ship.turner = Turner.new(ship, {maxTorque = 128})
    ship.sprite = Sprite.new(game, game.resources.images.wormhead)
    ship.maxTurnSpeed = 2 * math.pi
    ship.maxThrustForce = 128
    ship.destroyed = false
    ship.maxCooldown = 0.5
    ship.cooldown = 0
    return ship
end

function Ship:destroy()
    self.destroyed = true

    if self.tailEdge then
        self.tailEdge:destroyTail()
    end

    self.turner:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
    self.game.entities.ship[self] = nil

    if self.level then
        self.level.shipSpawnDelay = 3
    end
end

function Ship:update(dt)
    local leftInput = love.keyboard.isDown("a") or love.keyboard.isDown("left")
    local rightInput = love.keyboard.isDown("d") or love.keyboard.isDown("right")
    local upInput = love.keyboard.isDown("w") or love.keyboard.isDown("up")
    local downInput = love.keyboard.isDown("s") or love.keyboard.isDown("down")
    local fireInput = love.keyboard.isDown("space")
    local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
    local inputY = (upInput and 1 or 0) - (downInput and 1 or 0)
    local turnSpeed = self.maxTurnSpeed * inputX
    self.turner.body:setAngularVelocity(turnSpeed)
    local thrustForce = self.maxThrustForce * inputY
    local forwardX, forwardY = self.body:getWorldVector(0, -1)
    self.body:applyForce(thrustForce * forwardX, thrustForce * forwardY)
    self.cooldown = self.cooldown - dt

    if fireInput and self.cooldown < 0 then
        self.cooldown = self.maxCooldown
        local x, y = self.body:getWorldPoint(0, -0.5)
        local worldDirectionX, worldDirectionY = self.body:getWorldVector(0, -1)
        local linearVelocityX, linearVelocityY = self.body:getLinearVelocityFromLocalPoint(0, -0.5)
        local bulletLinearVelocityX = linearVelocityX + 8 * worldDirectionX
        local bulletLinearVelocityY = linearVelocityY + 8 * worldDirectionY

        Bullet.new(self.game, {
            x = x,
            y = y,
            linearVelocityX = bulletLinearVelocityX,
            linearVelocityY = bulletLinearVelocityY,

            colors = {
                0xff, 0xff, 0x66, 0x99,
                0x66, 0xff, 0x00, 0x99,
                0x00, 0x66, 0x00, 0x99,
                0x00, 0x00, 0x00, 0x99,
            },

            groupIndex = -self.groupIndex,
        })
    end
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
