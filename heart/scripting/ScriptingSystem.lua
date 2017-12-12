local ScriptingSystem = {}
ScriptingSystem.__index = ScriptingSystem
ScriptingSystem.systemType = "scripting"

function ScriptingSystem.new(game, config)
    local system = setmetatable({}, ScriptingSystem)
    system.game = assert(game)
    system.game.systems.scripting = system
    system.scriptComponents = {}
    system.scriptClasses = {}
    system.scriptUpdateHandlers = {}

    system.environment = {
        assert = assert,
        getmetatable = getmetatable,
        math = math,
        next = next,
        print = print,
        setmetatable = setmetatable,
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

function ScriptingSystem:loadScriptClass(filename)
    local scriptClass = self.scriptClasses[filename]

    if not scriptClass then
        local scriptFunction = assert(loadfile(filename, "t"))
        local scriptEnvironment = {}
        setmetatable(scriptEnvironment, self.environment)
        setfenv(scriptFunction, scriptEnvironment)
        scriptClass = scriptFunction()
        self.scriptClasses[filename] = scriptClass
    end

    return scriptClass
end

return ScriptingSystem
