local Camera = {}
Camera.__index = Camera

function Camera.new(config)
    camera = setmetatable({}, Camera)
    config = config or {}
    camera.x = config.x or 0
    camera.y = config.y or 0
    camera.scale = config.scale or 1
    return camera
end

return Camera
