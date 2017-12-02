local utils = {}

function utils.mix(x1, x2, t)
    return (1 - t) * x1 + t * x2
end

function utils.length2(x, y)
    return math.sqrt(x * x + y * y)
end

function utils.distance2(x1, y1, x2, y2)
    return utils.length2(x2 - x1, y2 - y1)
end

function utils.generateAngle(random)
    random = random or love.math.random
    return 2 * math.pi * random()
end

function utils.generateDirection(random)
    local angle = utils.generateAngle(random)
    return math.cos(angle), math.sin(angle)
end

function utils.count(t)
    local count = 0

    for k, v in pairs(t) do
        count = count + 1
    end

    return count
end

return utils
