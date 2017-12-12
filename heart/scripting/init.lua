local ScriptComponent = require("heart.scripting.ScriptComponent")
local ScriptingSystem = require("heart.scripting.ScriptingSystem")

local utils = require("heart.utils")

local scripting = {}

scripting.newScriptComponent = ScriptComponent.new
scripting.newScriptingSystem = ScriptingSystem.new

return scripting
