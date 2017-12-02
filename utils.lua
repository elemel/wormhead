local utils = {}

function utils.length2(x, y)
    return math.sqrt(x * x + y * y)
end

function utils.distance2(x1, y1, x2, y2)
    return utils.length2(x2 - x1, y2 - y1)
end

function utils.randomDirection(random)
    random = random or love.math.random
    local angle = 2 * math.pi * random()
    return math.cos(angle), math.sin(angle)
end

return utils
