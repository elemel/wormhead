local FontCache = {}
FontCache.__index = FontCache

function FontCache.new()
    local cache = setmetatable({}, FontCache)
    cache.fonts = {}
    cache.defaultFonts = {}
    return cache
end

function FontCache:getFont(filename, size)
    size = math.floor(size + 0.5)
    local fonts

    if filename == nil then
        fonts = self.defaultFonts

        if not fonts[size] then
            fonts[size] = love.graphics.newFont(size)
        end
    else
        if not self.fonts[filename] then
            self.fonts[filename] = {}
        end

        fonts = self.fonts[filename]

        if not fonts[size] then
            fonts[size] = love.graphics.newFont(filename, size)
        end
    end

    return fonts[size]
end

return FontCache
