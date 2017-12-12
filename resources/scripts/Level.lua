local Level = {}
Level.__index = Level

function Level.new(component)
    local level = setmetatable({}, Level)
    level.component = assert(component)
    return level
end

function Level:start()
    self.maxAsteroidCount = 16
end

function Level:update(dt)
    local asteroidsEntity = assert(self.component.entity.children.asteroids)

    if #asteroidsEntity.children < self.maxAsteroidCount then
        heart.game.newEntity(self.component.entity.game, asteroidsEntity, {
            components = {
                {
                    componentType = "transform",
                },

                {
                    componentType = "body",
                },

                {
                    componentType = "circleFixture",
                },
            },
        })
    end
end

return Level
