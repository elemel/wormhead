local utils = require("heart.utils")

local Entity = {}
Entity.__index = Entity
Entity.objectType = "entity"

function Entity.new(game, parent, config)
    assert(game.objectType == "game")
    assert(parent == nil or parent.objectType == "entity")
    local entity = setmetatable({}, Entity)
    entity.game = assert(game)
    entity.name = config.name
    entity:setParent(parent)
    entity.components = {}

    if config.components then
        for i, componentType in ipairs(entity.game.componentTypes) do
            local componentConfig = config.components[componentType]

            if componentConfig then
                local componentCreator = assert(entity.game.componentCreators[componentType])
                componentCreator(entity, componentConfig)
            end
        end
    end

    entity.children = {}

    if config.children then
        for i, childConfig in ipairs(config.children) do
            Entity.new(entity.game, entity, childConfig)
        end
    end

    for i, componentType in ipairs(entity.game.componentTypes) do
        local component = entity.components[componentType]

        if component and component.start then
            component:start()
        end
    end

    return entity
end

function Entity:destroy()
    for i = #self.game.componentTypes, 1, -1 do
        local componentType = self.game.componentTypes[i]
        local component = self.components[componentType]

        if component and component.stop then
            component:stop()
        end
    end

    for i = #self.children, 1, -1 do
        local child = self.children[i]

        if child then
            child:destroy()
        end
    end

    for i = #self.game.componentTypes, 1, -1 do
        local componentType = self.game.componentTypes[i]
        local component = self.components[componentType]

        if component and component.destroy then
            component:destroy()
        end
    end

    self:setParent(nil)
end

function Entity:setParent(parent)
    assert(parent == nil or parent.objectType == "entity")

    if parent ~= self.parent then
        if self.parent then
            local i = assert(utils.lastIndex(self.parent.children, self))
            table.remove(self.parent.children, i)

            if self.name then
                self.parent.children[self.name] = nil
            end
        end

        self.parent = parent

        if self.parent then
            table.insert(self.parent.children, self)

            if self.name then
                self.parent.children[self.name] = self
            end
        end
    end
end

function Entity:addComponent(component)
    assert(component.objectType == "component")
    table.insert(self.components, component)
    self.components[component.componentType] = component
end    

function Entity:removeComponent(component)
    assert(component.objectType == "component")
    self.components[component.componentType] = nil
    local i = assert(utils.lastIndex(self.components, component))
    table.remove(self.components, i)
end

function Entity:getAncestorComponent(componentType, minDistance, maxDistance)
    minDistance = minDistance or 0
    maxDistance = maxDistance or math.huge
    local entity = self
    local distance = 0

    while entity do
        if minDistance <= distance and distance <= maxDistance then
            local component = entity.components[componentType]

            if component then
                return component
            end
        end

        entity = entity.parent
        distance = distance + 1
    end

    return nil
end

function Entity:getDescendantComponent(componentType, minDistance, maxDistance)
    local first = nil

    function callback(component)
        first = component
        return false
    end

    self:getDescendantComponents(componentType, callback, minDistance, maxDistance)
    return first
end

function Entity:getDescendantComponents(componentType, callback, minDistance, maxDistance)
    minDistance = minDistance or 0
    maxDistance = maxDistance or math.huge

    if maxDistance < 0 then
        return true
    end

    if minDistance <= 0 then
        local component = self.components[componentType]

        if component and not callback(component) then
            return false
        end
    end

    for i, child in ipairs(self.children) do
        if not child:getDescendantComponents(componentType, callback, minDistance - 1, maxDistance - 1) then
            return false
        end
    end

    return true
end

return Entity
