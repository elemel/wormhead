local utils = {}

function utils.key(t, v)
    for k, value in pairs(t) do
        if value == v then
            return k
        end
    end

    return nil
end

function utils.index(t, v)
    for i, value in ipairs(t) do
        if value == v then
            return i
        end
    end

    return nil
end

function utils.lastIndex(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            return i
        end
    end

    return nil
end

function utils.sign(x)
    return x < 0 and -1 or 1
end

function utils.split(s, sep)
    local t = {}
    local i = 1

    while true do
        local j, k = string.find(s, sep, i, false)

        if j == nil then
            table.insert(t, string.sub(s, i))
            break
        end

        table.insert(t, string.sub(s, i, j - 1))
        i = k + 1
    end

    return t
end

function utils.dot2(x1, y1, x2, y2)
    return x1 * x2 + y1 * y2
end

function utils.clampLength2(x, y, length1, length2)
    local lengthSquared = x * x + y * y

    if lengthSquared < length1 * length1 or lengthSquared > length2 * length2 then
        local length = math.sqrt(lengthSquared)
        x = x / length
        y = y / length
        length = math.min(math.max(length, length1), length2)
        x = length * x
        y = length * y
    end

    return x, y
end

function utils.distanceSquared2(x1, y1, x2, y2)
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
end

function utils.lengthSquared2(x, y)
    return x * x + y * y
end

function utils.length2(x, y)
    return math.sqrt(x * x + y * y)
end

function utils.get2(t, x, y)
    return t[x] and t[x][y]
end

function utils.set2(t, x, y, value)
    if value == nil then
        if t[x] then
            t[x][y] = nil

            if not next(t[x]) then
                t[x] = nil
            end
        end
    else
        if not t[x] then
            t[x] = {}
        end

        t[x][y] = value
    end
end

function utils.get3(t, x, y, z)
    return t[x] and t[x][y] and t[x][y][z]
end

function utils.set3(t, x, y, z, value)
    if value == nil then
        if t[x] then
            if t[x][y] then
                t[x][y][z] = nil

                if not next(t[x][y]) then
                    t[x][y] = nil

                    if not next(t[x]) then
                        t[x] = nil
                    end
                end
            end
        end
    else
        if not t[x] then
            t[x] = {}
        end

        if not t[x][y] then
            t[x][y] = {}
        end

        t[x][y][z] = value
    end
end

function utils.newInscribedPolygonShape(n, x, y, r, sx, sy)
    n = n or 3
    x = x or 0
    y = y or 0
    r = r or 0
    sx = sx or 1
    sy = sy or sx
    local vertices = {}

    for i = 1, n do
        table.insert(vertices, x + sx * math.cos(r + 2 * math.pi * (i - 1) / n))
        table.insert(vertices, y + sy * math.sin(r + 2 * math.pi * (i - 1) / n))
    end

    return love.physics.newPolygonShape(vertices)
end

function utils.parseStyle(s)
    local style = {}
    local attrs = utils.split(s, ";")

    for i, attr in ipairs(attrs) do
        local k, v = unpack(utils.split(attr, ":"))
        style[k] = v
    end

    return style
end

function utils.parseColor(s)
    s = s:gsub("#", "")
    return tonumber("0x" .. s:sub(1, 2)), tonumber("0x" .. s:sub(3, 4)), tonumber("0x" .. s:sub(5,6))
end

function utils.parsePath(s)
  local path = {}

  string.gsub(s, "([-%d.]+),([-%d.]+)", function (x, y)
    table.insert(path, x)
    table.insert(path, y)
  end)

  return path
end

function utils.fbm(x, noise, octave, lacunarity, gain)
    noise = noise or love.math.noise
    octave = octave or 3
    lacunarity = lacunarity or 2
    gain = gain or 1 / lacunarity

    local integralOctave, fractionalOctave = math.modf(octave)
    local amplitude = 1

    local totalNoise = 0
    local totalAmplitude = 0

    for i = 1, integralOctave do
        totalNoise = totalNoise + amplitude * noise(x, 0)
        totalAmplitude = totalAmplitude + amplitude

        x = x * lacunarity
        amplitude = amplitude * gain
    end

    if fractionalOctave > 0 then
        totalNoise = totalNoise + fractionalOctave * amplitude * noise(x)
        totalAmplitude = totalAmplitude + fractionalOctave * amplitude
    end

    return totalNoise / totalAmplitude
end

function utils.fbm2(x, y, noise, octave, lacunarityX, lacunarityY, gain)
    noise = noise or love.math.noise
    octave = octave or 3
    lacunarityX = lacunarityX or 2
    lacunarityY = lacunarityY or 2
    gain = gain or 2 / (lacunarityX + lacunarityY)

    local integralOctave, fractionalOctave = math.modf(octave)
    local amplitude = 1

    local totalNoise = 0
    local totalAmplitude = 0

    for i = 1, integralOctave do
        totalNoise = totalNoise + amplitude * noise(x, y)
        totalAmplitude = totalAmplitude + amplitude

        x = x * lacunarityX
        y = y * lacunarityY
        amplitude = amplitude * gain
    end

    if fractionalOctave > 0 then
        totalNoise = totalNoise + fractionalOctave * amplitude * noise(x, y)
        totalAmplitude = totalAmplitude + fractionalOctave * amplitude
    end

    return totalNoise / totalAmplitude
end

function utils.fbm3(
    x, y, z, noise, octave, lacunarityX, lacunarityY, lacunarityZ, gain)

    noise = noise or love.math.noise
    octave = octave or 3
    lacunarityX = lacunarityX or 2
    lacunarityY = lacunarityY or 2
    lacunarityZ = lacunarityZ or 2
    gain = gain or 3 / (lacunarityX + lacunarityY + lacunarityZ)

    local integralOctave, fractionalOctave = math.modf(octave)
    local amplitude = 1

    local totalNoise = 0
    local totalAmplitude = 0

    for i = 1, integralOctave do
        totalNoise = totalNoise + amplitude * noise(x, y, z)
        totalAmplitude = totalAmplitude + amplitude

        x = x * lacunarityX
        y = y * lacunarityY
        z = z * lacunarityZ
        amplitude = amplitude * gain
    end

    if fractionalOctave > 0 then
        totalNoise = totalNoise + fractionalOctave * amplitude * noise(x, y, z)
        totalAmplitude = totalAmplitude + fractionalOctave * amplitude
    end

    return totalNoise / totalAmplitude
end

function utils.fbm4(
    x, y, z, w, noise, octave, lacunarityX, lacunarityY, lacunarityZ,
    lacunarityW, gain)

    noise = noise or love.math.noise
    octave = octave or 3
    lacunarityX = lacunarityX or 2
    lacunarityY = lacunarityY or 2
    lacunarityZ = lacunarityZ or 2
    lacunarityW = lacunarityW or 2
    gain = gain or 4 / (lacunarityX + lacunarityY + lacunarityZ + lacunarityW)

    local integralOctave, fractionalOctave = math.modf(octave)
    local amplitude = 1

    local totalNoise = 0
    local totalAmplitude = 0

    for i = 1, integralOctave do
        totalNoise = totalNoise + amplitude * noise(x, y, z, w)
        totalAmplitude = totalAmplitude + amplitude

        x = x * lacunarityX
        y = y * lacunarityY
        z = z * lacunarityZ
        w = w * lacunarityW
        amplitude = amplitude * gain
    end

    if fractionalOctave > 0 then
        totalNoise = totalNoise + fractionalOctave * amplitude * noise(x, y, z, w)
        totalAmplitude = totalAmplitude + fractionalOctave * amplitude
    end

    return totalNoise / totalAmplitude
end

return utils
