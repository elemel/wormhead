local CameraComponent = {}
CameraComponent.__index = CameraComponent
CameraComponent.objectType = "component"
CameraComponent.componentType = "camera"

function CameraComponent.new(entity, config)
    local component = setmetatable({}, CameraComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    component.transformComponent = assert(entity.components.transform)
    component.graphicsSystem = assert(entity.game.systems.graphics)
    component.graphicsSystem.cameraComponents[component] = true
    component.viewportX = config.viewportX or 0
    component.viewportY = config.viewportY or 0
    component.viewportWidth = config.viewportWidth or 800
    component.viewportHeight = config.viewportHeight or 600
    return component
end

function CameraComponent:destroy()
    self.graphicsSystem.cameraComponents[self] = nil
    self.entity:removeComponent(self)
end

function CameraComponent:getWorldPoint(x, y)
    local scale = scaleX * math.min(self.viewportWidth, self.viewportHeight)
    x = self.x + (x - self.viewportX - 0.5 * self.viewportWidth) / scale
    y = self.y + (y - self.viewportY - 0.5 * self.viewportHeight) / scale
    return x, y
end

return CameraComponent
