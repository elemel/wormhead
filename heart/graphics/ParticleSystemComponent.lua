local utils = require("heart.utils")

local ParticleSystemComponent = {}
ParticleSystemComponent.__index = ParticleSystemComponent
ParticleSystemComponent.objectType = "component"
ParticleSystemComponent.componentType = "particleSystem"

function ParticleSystemComponent.new(entity, config)
    local component = setmetatable({}, ParticleSystemComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    component.graphicsSystem = assert(component.entity.game.systems.graphics)
    component.graphicsSystem.particleSystemComponents[component] = true
    component.transformComponent = assert(entity:getAncestorComponent("transform"))
    component.transformComponent:setDirty(false)
    component.x, component.y = component.transformComponent.worldTransform:transformPoint(0, 0)
    local imageName = config.imageName or "pixel"
    local image = assert(component.entity.game.images[imageName])
    local bufferSize = config.bufferSize
    component.particles = love.graphics.newParticleSystem(image, bufferSize)
    local particleLifetime = config.particleLifetime or 1
    component.particles:setParticleLifetime(particleLifetime)
    local emissionRate = config.emissionRate or 1
    component.particles:setEmissionRate(emissionRate)

    if config.sizes then
        component.particles:setSizes(unpack(config.sizes))
    end

    local minRotation = config.minRotation or config.rotation or 0
    local maxRotation = config.maxRotation or config.rotation or 0
    component.particles:setRotation(minRotation, maxRotation)
    local minLinearAccelerationX = config.minLinearAccelerationX or config.linearAccelerationX or 0
    local minLinearAccelerationY = config.minLinearAccelerationY or config.linearAccelerationY or 0
    local maxLinearAccelerationX = config.maxLinearAccelerationX or config.linearAccelerationX or 0
    local maxLinearAccelerationY = config.maxLinearAccelerationY or config.linearAccelerationY or 0

    component.particles:setLinearAcceleration(
        minLinearAccelerationX, minLinearAccelerationY,
        maxLinearAccelerationX, maxLinearAccelerationY)

    local minLinearDamping = config.minLinearDamping or config.linearDamping or 0
    local maxLinearDamping = config.maxLinearDamping or config.linearDamping or 0
    component.particles:setLinearDamping(minLinearDamping, maxLinearDamping)

    local areaSpreadDistribution = config.areaSpreadDistribution or "none"
    local areaSpreadDistanceX = config.areaSpreadDistanceX or config.areaSpreadDistance or 0
    local areaSpreadDistanceY = config.areaSpreadDistanceY or config.areaSpreadDistance or 0
    component.particles:setAreaSpread(areaSpreadDistribution, areaSpreadDistanceX, areaSpreadDistanceY)

    if config.colors then
        component.particles:setColors(unpack(config.colors))
    end

    return component
end

function ParticleSystemComponent:destroy()
    self.graphicsSystem.particleSystemComponents[self] = nil
    self.entity:removeComponent(self)
end

function ParticleSystemComponent:updateParticles(dt)
    local oldX = self.x
    local oldY = self.y
    self.transformComponent:setDirty(false)
    self.x, self.y = self.transformComponent.worldTransform:transformPoint(0, 0)
    self.particles:setPosition(self.x, self.y)
    local linearVelocityX = (self.x - oldX) / dt
    local linearVelocityY = (self.y - oldY) / dt
    local speed = utils.length2(linearVelocityX, linearVelocityY)
    self.particles:setSpeed(speed)
    local direction = math.atan2(linearVelocityY, linearVelocityX)
    self.particles:setDirection(direction)
    self.particles:update(dt)
end

return ParticleSystemComponent
