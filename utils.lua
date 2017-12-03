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

function utils.generatePolygon(vertexCount, x, y, scaleX, scaleY, irregularity, random)
    vertexCount = vertexCount or 8
    x = x or 0
    y = y or 0
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    irregularity = irregularity or 0.5
    random = random or love.math.random
    local seed = random()
    local vertices = {}

    for i = 1, vertexCount do
        local angle = 2 * math.pi * (seed + i + irregularity * random()) / vertexCount
        local vertexX = x + scaleX * math.cos(angle)
        local vertexY = y + scaleY * math.sin(angle)
        table.insert(vertices, vertexX)
        table.insert(vertices, vertexY)
    end

    return vertices
end

return utils
