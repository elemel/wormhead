local PhysicsSystem = {}
PhysicsSystem.__index = PhysicsSystem
PhysicsSystem.objectType = "system"
PhysicsSystem.systemType = "physics"

function PhysicsSystem.new(game, config)
    local system = setmetatable({}, PhysicsSystem)
    system.game = assert(game)
    system.game.systems.physics = system
    system.graphicsSystem = assert(game.systems.graphics)
    system.graphicsSystem.overlayHandlers[system] = PhysicsSystem.drawOverlay
    local gravityX = config.gravityX or 0
    local gravityY = config.gravityY or 0
    system.world = love.physics.newWorld(gravityX, gravityY)
    system.bodyComponents = {}
    system.game.updateHandlers.physics[system] = system.updatePhysics
    return system
end

function PhysicsSystem:destroy()
    self.graphicsSystem.overlayHandlers[self] = nil
    self.game.updateHandlers.physics[self] = nil
    self.game.systems.physics = nil
end

function PhysicsSystem:updatePhysics(dt)
    self.world:update(dt)

    for component, _ in pairs(self.bodyComponents) do
        assert(component.transformComponent.mode == "world")
        component.transformComponent.worldTransform:reset()
        local x, y = component.body:getPosition()
        local angle = component.body:getAngle()
        component.transformComponent.worldTransform:compose(x, y, angle)
        component.transformComponent:setDirty(true)
    end
end

function PhysicsSystem:drawOverlay()
    local red, green, blue, alpha = love.graphics.getColor()
    love.graphics.setColor(0, 255, 0, 255)

    for i, body in ipairs(self.world:getBodyList()) do
        for j, fixture in ipairs(body:getFixtureList()) do
            local shape = fixture:getShape()
            local shapeType = shape:getType()

            if shapeType == "polygon" then
                love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
            elseif shapeType == "circle" then
                local x, y = body:getWorldPoint(shape:getPoint())
                local radius = shape:getRadius()
                love.graphics.circle("line", x, y, radius, 16)
                local angle = body:getAngle()
                love.graphics.line(x, y, x + radius * math.cos(angle), y + radius * math.sin(angle))
            elseif shapeType == "chain" then
                love.graphics.line(body:getWorldPoints(shape:getPoints()))
            else
                print(shapeType)
            end
        end
    end

    for i, joint in ipairs(self.world:getJointList()) do
        local jointType = joint:getType()

        if jointType == "rope" then
            local x1, y1, x2, y2 = joint:getAnchors()
            love.graphics.line(x1, y1, x2, y2)
        elseif jointType == "distance" then
            local x1, y1, x2, y2 = joint:getAnchors()
            love.graphics.line(x1, y1, x2, y2)
        elseif jointType == "friction" then
            local x1, y1, x2, y2 = joint:getAnchors()
            love.graphics.line(x1, y1, x2, y2)
        end
    end

    love.graphics.setColor(red, green, blue, alpha)
end

return PhysicsSystem
