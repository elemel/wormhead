local PolygonFixtureComponent = {}
PolygonFixtureComponent.__index = PolygonFixtureComponent
PolygonFixtureComponent.objectType = "component"
PolygonFixtureComponent.componentType = "polygonFixture"

function PolygonFixtureComponent.new(entity, config)
    local component = setmetatable({}, PolygonFixtureComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    local bodyComponent = assert(entity:getAncestorComponent("body"))
    local transformComponent = assert(entity:getAncestorComponent("transform"))
    transformComponent:setDirty(false)
    local vertices = {unpack(assert(config.vertices))}

    for i = 1, #vertices, 2 do
        local x = vertices[i]
        local y = vertices[i + 1]
        x, y = transformComponent.worldTransform:transformPoint(x, y)
        x, y = bodyComponent.body:getLocalPoint(x, y)
        vertices[i] = x
        vertices[i + 1] = y
    end

    local shape = love.physics.newPolygonShape(vertices)
    local density = config.density or 1
    component.fixture = love.physics.newFixture(bodyComponent.body, shape, density)
    component.fixture:setUserData(component)
    return component
end

function PolygonFixtureComponent:destroy()
    self.fixture:destroy()
    self.entity:removeComponent(self)
end

return PolygonFixtureComponent
