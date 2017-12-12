local ScriptingSystem = {}
ScriptingSystem.__index = ScriptingSystem
ScriptingSystem.systemType = "scripting"

function ScriptingSystem.new(game, config)
    local system = setmetatable({}, ScriptingSystem)
    system.game = assert(game)
    system.game.systems.scripting = system
    system.scriptComponents = {}
    system.scripts = {}
    system.scriptUpdateHandlers = {}

    system.environment = {
        require = function(filename)
            return system:loadScript(filename .. ".lua")
        end,
    }

    system.environment.__index = system.environment
    system.game.updateHandlers.scripting[system] = system.update
    return system
end

function ScriptingSystem:destroy()
    self.game.updateHandlers.scripting[self] = nil
    self.game.systems.scripting = nil
end

function ScriptingSystem:addScriptComponent(component)
  self.scriptComponents[component] = true
end

function ScriptingSystem:removeScriptComponent(component)
  self.scriptComponents[component] = nil
end

function ScriptingSystem:update(dt)
    for component, handler in pairs(self.scriptUpdateHandlers) do
        handler(component.script, dt)
    end
end

function ScriptingSystem:loadScript(filename)
    local script = self.scripts[filename]

    if not script then
        local scriptFunction = assert(loadfile(filename, "t"))
        local scriptEnvironment = {}
        setmetatable(scriptEnvironment, self.environment)
        setfenv(scriptFunction, scriptEnvironment)
        script = scriptFunction()
        self.scripts[filename] = scripts
    end

    return script
end

return ScriptingSystem
