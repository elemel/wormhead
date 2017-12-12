local ScriptComponent = {}
ScriptComponent.__index = ScriptComponent
ScriptComponent.objectType = "component"
ScriptComponent.componentType = "script"

function ScriptComponent.new(entity, config)
    local component = setmetatable({}, ScriptComponent)
    component.name = config.name
    component.entity = assert(entity)
    component.entity:addComponent(component)
    component.scriptingSystem = assert(component.entity.game.systems.scripting)
    component.scriptingSystem:addScriptComponent(component)
    component.scriptFilename = assert(config.scriptFilename)
    local scriptClass = component.scriptingSystem:loadScript(component.scriptFilename)
    component.script = scriptClass.new(component, config.script or {})
    component.scriptingSystem.scriptUpdateHandlers[component] = component.script.update
    return component
end

function ScriptComponent:start()
    if self.script.start then
        self.script:start()
    end
end

function ScriptComponent:stop()
    if self.script.stop then
        self.script:stop()
    end
end

function ScriptComponent:destroy()
    self.scriptingSystem.scriptUpdateHandlers[self] = nil

    if self.script.destroy then
        self.script:destroy()
    end

    self.system:removeScriptComponent(self)
    self.entity:removeComponent(self)
end

return ScriptComponent
