local utils = require("utils")

local Asteroid = {}
Asteroid.__index = Asteroid
Asteroid.entityType = "asteroid"

function Asteroid.new(game, config)
    local asteroid = setmetatable({}, Asteroid)
    asteroid.game = assert(game)
    asteroid.game.entities.asteroid[asteroid] = true
    asteroid.game.updateHandlers[asteroid] = asteroid.update
    asteroid.game.drawHandlers[asteroid] = asteroid.draw
    config = config or {}
    local world = assert(asteroid.game.physics.world)
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    asteroid.body = love.physics.newBody(world, x, y, "dynamic")
    asteroid.body:setAngle(angle)
    local linearVelocityX = config.linearVelocityX or 0
    local linearVelocityY = config.linearVelocityY or 0
    asteroid.body:setLinearVelocity(linearVelocityX, linearVelocityY)
    local angularVelocity = config.angularVelocity or 0
    asteroid.body:setAngularVelocity(angularVelocity)
    asteroid.vertices = config.vertices or utils.generatePolygon()
    local shape = love.physics.newPolygonShape(asteroid.vertices)
    local density = config.density or 16
    asteroid.fixture = love.physics.newFixture(asteroid.body, shape, density)

    asteroid.fixture:setUserData({
        entity = asteroid,
        userType = "asteroid",
    })

    asteroid.turrets = {}
    return asteroid
end

function Asteroid:destroy()
    while true do
        local turret = next(self.turrets)

        if not turret then
            break
        end

        turret:destroy()
    end

    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.updateHandlers[self] = nil
    self.game.entities.asteroid[self] = nil
end

function Asteroid:update(dt)
    local x, y = self.body:getPosition()

    if utils.distance2(x, y, self.game.camera.x, self.game.camera.y) > self.game.despawnDistance then
        self:destroy()
        return
    end
end

function Asteroid:draw()
    love.graphics.setColor(0xcc, 0xcc, 0x99)
    love.graphics.polygon("fill", self.body:getWorldPoints(unpack(self.vertices)))
    love.graphics.setColor(0xff, 0xff, 0xff)
end

return Asteroid
