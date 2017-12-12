local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(a, b, c, d, e, f)
    local matrix = setmetatable({}, Matrix)

    matrix.a = a or 1
    matrix.b = b or 0
    matrix.c = c or 0

    matrix.d = d or 0
    matrix.e = e or 1
    matrix.f = f or 0

    return matrix
end

function Matrix:get()
  return self.a, self.b, self.c, self.d, self.e, self.f
end

function Matrix:reset(a, b, c, d, e, f)
    self.a = a or 1
    self.b = b or 0
    self.c = c or 0

    self.d = d or 0
    self.e = e or 1
    self.f = f or 0
end

function Matrix:multiply(a, b, c, d, e, f)
    self:reset(
        self.a * a + self.b * d,
        self.a * b + self.b * e,
        self.a * c + self.b * f + self.c,

        self.d * a + self.e * d,
        self.d * b + self.e * e,
        self.d * c + self.e * f + self.f)
end

function Matrix:multiplyRight(a, b, c, d, e, f)
    self:reset(
        a * self.a + b * self.d,
        a * self.b + b * self.e,
        a * self.c + b * self.f + c,

        d * self.a + e * self.d,
        d * self.b + e * self.e,
        d * self.c + e * self.f + f)
end

function Matrix:translate(x, y)
    self:multiply(
        1, 0, x,
        0, 1, y)
end

function Matrix:rotate(angle, x, y)
    local cosAngle = math.cos(angle)
    local sinAngle = math.sin(angle)

    if x then
        self:translate(-x, -y)
    end

    self:multiply(
        cosAngle, -sinAngle, 0,
        sinAngle, cosAngle, 0)

    if x then
        self:translate(x, y)
    end
end

function Matrix:scale(scaleX, scaleY)
    self:multiply(
        scaleX, 0, 0,
        0, scaleY, 0)
end

function Matrix:shear(shearX, shearY)
    self:multiply(
        1, shearX, 0,
        shearY, 1, 0)
end

function Matrix:reflect(angle, x, y)
    local axisY, axisX = math.atan2(angle)

    if x then
      self:translate(-x, -y)
    end

    self:multiply(
        axisX * axisX - axisY * axisY,
        2 * axisX * axisY,
        0,

        2 * axisX * axisY,
        axisY * axisY - axisX * axisX,
        0)

    if x then
        self:translate(x, y)
    end
end

function Matrix:transformVector(x, y)
    return self.a * x + self.b * y, self.d * x + self.e * y
end

function Matrix:transformPoint(x, y)
    return self.a * x + self.b * y + self.c, self.d * x + self.e * y + self.f
end

function Matrix:invert()
    local invDeterminant = 1 / (self.a * self.e - self.b * self.d)

    self:reset(
        invDeterminant * self.e,
        invDeterminant * -self.b,
        invDeterminant * (self.b * self.f - self.c * self.e),

        invDeterminant * -self.d,
        invDeterminant * self.a,
        invDeterminant * (-self.a * self.f + self.c * self.d))
end

function Matrix:compose(x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY)
    self:translate(x or 0, y or 0)
    self:rotate(angle or 0)
    self:scale(scaleX or 1, scaleY or scaleX or 1)
    self:shear(shearX or 0, shearY or 0)
    self:translate(-(originX or 0), -(originY or 0))
end

function Matrix:decompose()
    local x = self.c
    local y = self.f
    local angle = math.atan2(self.d, self.a)
    local scaleX = math.sqrt(self.a * self.a + self.d * self.d)
    local scaleY = scaleX
    local originX = 0
    local originY = 0
    local shearX = 0
    local shearY = 0
    return x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY
end

return Matrix
