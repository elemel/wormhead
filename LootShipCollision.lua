local WormEdge = require("WormEdge")

local LootShipCollision = {}
LootShipCollision.__index = LootShipCollision

function LootShipCollision.new(loot, ship)
    local collision = setmetatable({}, LootShipCollision)
    collision.loot = assert(loot)
    collision.ship = assert(ship)
    collision.game = assert(ship.game)
    collision.game.collideHandlers[collision] = collision.collide
    return collision
end

function LootShipCollision:destroy()
    self.game.collideHandlers[self] = nil
end

function LootShipCollision:collide(dt)
    if self.loot.destroyed or self.loot.headEdge then
        self:destroy()
        return
    end

    local tail = self.ship

    while tail.tailEdge do
        tail = tail.tailEdge.tail
    end

    WormEdge.new(self.loot, tail)
    self:destroy()
end

return LootShipCollision
