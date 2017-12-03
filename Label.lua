local Label = {}
Label.__index = Label

function Label.new(fontCache, config)
    local label = setmetatable({}, Label)
    label.fontCache = assert(fontCache)
    config = config or {}
    label.text = config.text or ""
    label.fontFilename = config.fontFilename
    label.fontSize = config.fontSize or 12
    label.x = config.x or 0
    label.y = config.y or 0
    label.angle = config.angle or 0
    label.alignmentX = config.alignmentX or 0.5
    label.alignmentY = config.alignmentY or 0.5
    return label
end

function Label:draw()
    local font = self.fontCache:getFont(self.fontFilename, self.fontSize)
    local oldFont = love.graphics.getFont()
    love.graphics.setFont(font)
    local width = font:getWidth(self.text)
    local height = font:getHeight()
    local originX = self.alignmentX * width
    local originY = self.alignmentY * height
    love.graphics.print(self.text, self.x, self.y, self.angle, 1, 1, originX, originY)
    love.graphics.setFont(oldFont)
end

return Label
