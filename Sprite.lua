local Sprite = {}
Sprite.__index = Sprite

function Sprite.new(game, image, config)
    local sprite = setmetatable({}, Sprite)
    sprite.game = assert(game)
    sprite.image = assert(image)
    config = config or {}
    sprite.x = config.x or 0
    sprite.y = config.y or 0
    sprite.angle = config.angle or 0
    sprite.scaleX = config.scaleX or 1
    sprite.scaleY = config.scaleY or 1
    sprite.alignmentX = config.alignmentX or 0.5
    sprite.alignmentY = config.alignmentY or 0.5
    return sprite
end

function Sprite:draw()
    local width, height = self.image:getDimensions()
    local scale = self.game.texelScale
    local originX = width * self.alignmentX
    local originY = height * self.alignmentY

    love.graphics.draw(
        self.image,
        self.x, self.y,
        self.angle,
        scale, scale,
        originX, originY)
end

return Sprite
