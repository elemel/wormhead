local utils = require("utils")

local Level = {}
Level.__index = Level

function Level.new(component, config)
    local level = setmetatable({}, Level)
    level.component = assert(component)
    level.minAsteroidDistance = 64
    level.maxAsteroidDistance = 128
    level.maxAsteroidCount = config.maxAsteroidCount or 8
    level.minAsteroidRadius = config.minAsteroidRadius or 8
    level.maxAsteroidRadius = config.maxAsteroidRadius or 16
    level.minAngularVelocity = config.minAngularVelocity or 0
    level.maxAngularVelocity = config.maxAngularVelocity or 0.125 * math.pi
    level.minLinearVelocity = config.minLinearVelocity or 0
    level.maxLinearVelocity = config.maxLinearVelocity or 1
    return level
end

function Level:update(dt)
    self:updateAsteroids(dt)
end

function Level:updateAsteroids(dt)
    local asteroidsEntity = assert(self.component.entity.children.asteroids)
    local maxDistance = -math.huge
    local mostDistantAsteroidEntity = nil

    local cameraEntity = assert(self.component.entity.children.camera)
    local cameraTransformComponent = assert(cameraEntity.components.transform)
    cameraTransformComponent:setDirty(false)
    local cameraX, cameraY = cameraTransformComponent.worldTransform:transformPoint(0, 0)

    for i, asteroidEntity in ipairs(asteroidsEntity.children) do
        local bodyComponent = assert(asteroidEntity.components.body)
        local x, y = bodyComponent.body:getPosition()
        local distance = utils.distance2(x, y, cameraX, cameraY)

        if distance > maxDistance then
            maxDistance = distance
            mostDistantAsteroidEntity = asteroidEntity
        end
    end

    if mostDistantAsteroidEntity and maxDistance > self.maxAsteroidDistance then
        mostDistantAsteroidEntity:destroy()
    end

    if #asteroidsEntity.children < self.maxAsteroidCount then
        self:generateAsteroid()
    end
end

function Level:generateAsteroid()
    local asteroidsEntity = assert(self.component.entity.children.asteroids)
    local x, y = self:generateAsteroidPosition()
    local angle = utils.generateAngle()
    local linearVelocityX, linearVelocityY = self:generateLinearVelocity()
    local angularVelocity = self:generateAngularVelocity()
    local scaleX = utils.mix(self.minAsteroidRadius, self.maxAsteroidRadius, love.math.random())
    local scaleY = utils.mix(self.minAsteroidRadius, self.maxAsteroidRadius, love.math.random())
    local vertexCount = 8
    local vertices = utils.generatePolygon(vertexCount, 0, 0, scaleX, scaleY, 0.75)

    local entity = heart.game.newEntity(self.component.entity.game, asteroidsEntity, {
        components = {
            transform = {
                x = x,
                y = y,
                angle = angle,
            },

            body = {
                bodyType = "dynamic",
                linearVelocityX = linearVelocityX,
                linearVelocityY = linearVelocityY,
                angularVelocity = angularVelocity,
            },

            polygonFixture = {
                vertices = vertices,
            },

            mesh = {},
        },
    })

    local meshVertices = {}

    for i = 1, #vertices, 2 do
        local x = vertices[i]
        local y = vertices[i + 1]
        table.insert(meshVertices, {x, y})
    end

    entity.components.mesh.mesh = love.graphics.newMesh(meshVertices)
    return entity
end

function Level:generateAsteroidPosition()
    local cameraEntity = assert(self.component.entity.children.camera)
    local cameraTransformComponent = assert(cameraEntity.components.transform)
    cameraTransformComponent:setDirty(false)
    local cameraX, cameraY = cameraTransformComponent.worldTransform:transformPoint(0, 0)
    local directionX, directionY = utils.generateDirection()
    local distance = utils.mix(self.minAsteroidDistance, self.maxAsteroidDistance, love.math.random())
    local x = cameraX + distance * directionX
    local y = cameraY + distance * directionY
    return x, y
end

function Level:generateLinearVelocity()
    local linearVelocity = utils.mix(self.minLinearVelocity, self.maxLinearVelocity, love.math.random())
    local directionX, directionY = utils.generateDirection()
    return linearVelocity * directionX, linearVelocity * directionY
end

function Level:generateAngularVelocity()
    local angularVelocity = utils.mix(self.minAngularVelocity, self.maxAngularVelocity, love.math.random())
    return utils.generateSign() * angularVelocity
end

return Level
