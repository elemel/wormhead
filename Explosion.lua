local Explosion = {}
Explosion.__index = Explosion

function Explosion.new(game, config)
    explosion = setmetatable({}, Explosion)
    explosion.game = assert(game)
    explosion.game.animateHandlers[explosion] = Explosion.animate
    explosion.game.drawHandlers[explosion] = Explosion.draw
    local image = assert(game.resources.images.pixel)
    config = config or {}
    explosion.particles = love.graphics.newParticleSystem(image)

    explosion.particles:setColors(
        0xff, 0xff, 0x66, 0xff,
        0xff, 0x66, 0x00, 0xff,
        0x66, 0x00, 0x00, 0xff,
        0x00, 0x00, 0x00, 0xff)

    explosion.particles:setLinearDamping(2, 4)
    explosion.particles:setParticleLifetime(0.5)
    local x = config.x or 0
    local y = config.y or 0
    explosion.particles:setPosition(x, y)
    explosion.particles:setSizes(8 * explosion.game.texelScale)
    explosion.particles:setSpeed(0, 16)
    explosion.particles:setSpin(-math.pi, math.pi)
    explosion.particles:setSpread(2 * math.pi)
    explosion.particles:emit(1000)
    return explosion
end

function Explosion:destroy()
    self.game.drawHandlers[self] = nil
    self.game.animateHandlers[self] = nil
end

function Explosion:animate(dt)
    self.particles:update(dt)
end

function Explosion:draw()
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.particles)
    love.graphics.setBlendMode("alpha")
end

return Explosion
