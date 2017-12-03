local Bullet = {}
Bullet.__index = Bullet
Bullet.entityType = "bullet"

function Bullet.new(game, config)
    local bullet = setmetatable({}, Bullet)
    bullet.game = assert(game)
    bullet.game.updateHandlers[bullet] = bullet.update
    bullet.game.animateHandlers[bullet] = bullet.animate
    bullet.game.drawHandlers[bullet] = bullet.draw
    local image = assert(game.resources.images.pixel)
    config = config or {}
    local world = assert(bullet.game.physics.world)
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    bullet.body = love.physics.newBody(world, x, y, "dynamic")
    bullet.body:setAngle(angle)
    local linearVelocityX = config.linearVelocityX or 0
    local linearVelocityY = config.linearVelocityY or 0
    bullet.body:setLinearVelocity(linearVelocityX, linearVelocityY)
    local angularVelocity = config.angularVelocity or 0
    bullet.body:setAngularVelocity(angularVelocity)
    local shape = love.physics.newCircleShape(0.25)
    bullet.fixture = love.physics.newFixture(bullet.body, shape, 16)

    bullet.fixture:setUserData({
        entity = bullet,
        userType = "bullet",
    })

    local groupIndex = config.groupIndex or 0
    bullet.fixture:setGroupIndex(groupIndex)
    bullet.particles = love.graphics.newParticleSystem(image, 128)
    bullet.particles:setAreaSpread("ellipse", 0.25, 0.25)

    local colors = config.colors or {
        0xff, 0xff, 0x66, 0x99,
        0xff, 0x66, 0x00, 0x99,
        0x66, 0x00, 0x00, 0x99,
        0x00, 0x00, 0x00, 0x99,
    }

    bullet.particles:setColors(unpack(colors))
    bullet.particles:setEmissionRate(256)
    bullet.particles:setEmitterLifetime(9.5)
    bullet.particles:setLinearDamping(4, 8)
    bullet.particles:setParticleLifetime(0.5)
    local x = config.x or 0
    local y = config.y or 0
    bullet.particles:setPosition(x, y)
    bullet.particles:setRotation(-math.pi, math.pi)
    bullet.particles:setSizes(4 * bullet.game.texelScale)
    bullet.particles:setSpeed(0, 4)
    bullet.particles:setSpin(-math.pi, math.pi)
    bullet.particles:setSpread(2 * math.pi)
    bullet.ttl = 10
    return bullet
end

function Bullet:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
    self.game.updateHandlers[self] = nil
end

function Bullet:update(dt)
    self.ttl = self.ttl - dt

    if self.ttl < 0 then
        self:destroy()
    end
end

function Bullet:animate(dt)
    local x, y = self.body:getPosition()
    self.particles:setPosition(x, y)
    self.particles:update(dt)
end

function Bullet:draw()
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.particles)
    love.graphics.setBlendMode("alpha")
end

return Bullet
