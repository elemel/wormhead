local LootShipCollision = require("LootShipCollision")

local Physics = {}
Physics.__index = Physics

function Physics.new()
    local physics = setmetatable({}, Physics)
    config = config or {}
    local gravityX = config.gravityX or 0
    local gravityY = config.gravityY or 0
    physics.world = love.physics.newWorld(gravityX, gravityY)

    local function beginContact(fixture1, fixture2, contact)
        local userData1 = assert(fixture1:getUserData())
        local userData2 = assert(fixture2:getUserData())
        local userType1 = assert(userData1.userType)
        local userType2 = assert(userData2.userType)
        local direction = 1

        if userType1 > userType2 then
            userData1, userData2 = userData2, userData1
            userType1, userType2 = userType2, userType1
            direction = -1
        end

        local entity1 = assert(userData1.entity)
        local entity2 = assert(userData2.entity)

        if userType1 == "mine" and userType2 == "ship" then
            LootShipCollision.new(entity1, entity2)
        end

        if userType1 == "jammer" and userType2 == "ship" then
            LootShipCollision.new(entity1, entity2)
        end
    end

    physics.world:setCallbacks(beginContact, nil, nil, nil)
    return physics
end

function Physics:update(dt)
    self.world:update(dt)
end

function Physics:draw()
    for i, body in ipairs(self.world:getBodyList()) do
        for i, fixture in ipairs(body:getFixtureList()) do
            local shape = fixture:getShape()
            local shapeType = shape:getType()

            if shapeType == "circle" then
                local x, y = body:getWorldPoint(shape:getPoint())
                local radius = shape:getRadius()
                love.graphics.circle("line", x, y, radius, 16)
            else
                print(shapeType)
            end
        end
    end
end

return Physics
