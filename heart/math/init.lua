local Matrix = require("heart.math.Matrix")

local heartMath = {}

heartMath.newMatrix = Matrix.new

function heartMath.clampLength2(x, y, length1, length2)
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

return heartMath
