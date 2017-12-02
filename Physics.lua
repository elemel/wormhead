local Physics = {}
Physics.__index = Physics

function Physics.new()
    local physics = setmetatable({}, Physics)
    config = config or {}
    local gravityX = config.gravityX or 0
    local gravityY = config.gravityY or 0
    physics.world = love.physics.newWorld(gravityX, gravityY)
    return physics
end

function Physics:update(dt)
    self.world:update(dt)
end

return Physics
