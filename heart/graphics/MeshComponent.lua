local MeshComponent = {}
MeshComponent.__index = MeshComponent
MeshComponent.objectType = "component"
MeshComponent.componentType = "mesh"

function MeshComponent.new(entity, config)
    local component = setmetatable({}, MeshComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    component.graphicsSystem = assert(component.entity.game.systems.graphics)
    component.graphicsSystem.meshComponents[component] = true
    component.transformComponent = assert(entity:getAncestorComponent("transform"))
    return component
end

function MeshComponent:destroy()
    self.graphicsSystem.meshComponents[self] = nil
    self.entity:removeComponent(self)
end

return MeshComponent
