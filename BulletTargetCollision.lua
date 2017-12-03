local Explosion = require("Explosion")

local BulletTargetCollision = {}
BulletTargetCollision.__index = BulletTargetCollision

function BulletTargetCollision.new(bullet, target)
    local collision = setmetatable({}, BulletTargetCollision)
    collision.bullet = assert(bullet)
    collision.target = assert(target)
    collision.game = assert(target.game)
    collision.game.collideHandlers[collision] = collision.collide
    return collision
end

function BulletTargetCollision:destroy()
    self.game.collideHandlers[self] = nil
end

function BulletTargetCollision:collide(dt)
    if self.target.destroyed then
        self:destroy()
        return
    end

    local x, y = self.target.body:getPosition()

    Explosion.new(self.game, {
        x = x,
        y = y,
    })

    self.target:destroy()
    self:destroy()
end

return BulletTargetCollision
