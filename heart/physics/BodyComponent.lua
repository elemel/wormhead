local BodyComponent = {}
BodyComponent.__index = BodyComponent
BodyComponent.objectType = "component"
BodyComponent.componentType = "body"

function BodyComponent.new(entity, config)
    local component = setmetatable({}, BodyComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    component.physicsSystem = assert(component.entity.game.systems.physics)
    component.physicsSystem.bodyComponents[component] = true
    component.transformComponent = assert(entity.components.transform)
    component.transformComponent:setMode("world")

    local x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY =
        component.transformComponent.worldTransform:decompose()

    local bodyType = config.bodyType or "static"
    component.body = love.physics.newBody(component.physicsSystem.world, x, y, bodyType)
    component.body:setUserData(component)
    component.body:setAngle(angle)
    local fixedRotation = config.fixedRotation or false
    component.body:setFixedRotation(fixedRotation)
    local linearVelocityX = config.linearVelocityX or 0
    local linearVelocityY = config.linearVelocityY or 0
    component.body:setLinearVelocity(linearVelocityX, linearVelocityY)
    local angularVelocity = config.angularVelocity or 0
    component.body:setAngularVelocity(angularVelocity)
    return component
end

function BodyComponent:destroy()
    self.body:destroy()
    self.physicsSystem.bodyComponents[self] = nil
    self.entity:removeComponent(self)
end

return BodyComponent
