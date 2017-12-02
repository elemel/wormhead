local Sprite = require("Sprite")

local Mine = {}
Mine.__index = Mine

function Mine.new(game, config)
    local mine = setmetatable({}, Mine)
    mine.game = assert(game)
    mine.game.draws[mine] = Mine.draw
    local world = assert(mine.game.physics.world)
    config = config or {}
    local x = config.x or 0
    local y = config.y or 0
    local angle = config.angle or 0
    mine.body = love.physics.newBody(world, x, y, "dynamic")
    mine.body:setAngle(angle)
    local shape = love.physics.newCircleShape(0.5)
    mine.fixture = love.physics.newFixture(mine.body, shape)
    mine.sprite = Sprite.new(game, game.resources.images.mine)
    return mine
end

function Mine:destroy()
    self.fixture:destroy()
    self.body:destroy()
    self.game.draws[self] = nil
end

function Mine:draw()
    self.sprite.x, self.sprite.y = self.body:getPosition()
    self.sprite.angle = self.body:getAngle()
    self.sprite:draw()
end

return Mine
