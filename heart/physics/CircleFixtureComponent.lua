local CircleFixtureComponent = {}
CircleFixtureComponent.__index = CircleFixtureComponent
CircleFixtureComponent.objectType = "component"
CircleFixtureComponent.componentType = "circleFixture"

function CircleFixtureComponent.new(entity, config)
    local component = setmetatable({}, CircleFixtureComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    local bodyComponent = assert(entity:getAncestorComponent("body"))
    local transformComponent = assert(entity:getAncestorComponent("transform"))
    transformComponent:setDirty(false)

    local x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY =
        transformComponent.worldTransform:decompose()

    x, y = bodyComponent.body:getLocalPoint(x, y)
    local radius = config.radius or 1
    radius = radius * math.sqrt(math.abs(scaleX * scaleY))
    local shape = love.physics.newCircleShape(x, y, radius)
    local density = config.density or 1
    component.fixture = love.physics.newFixture(bodyComponent.body, shape, density)
    component.fixture:setUserData(component)
    local friction = config.friction or 0.5
    component.fixture:setFriction(friction)
    local restitution = config.restitution or 0
    component.fixture:setRestitution(restitution)
    return component
end

function CircleFixtureComponent:destroy()
    self.fixture:destroy()
    self.entity:removeComponent(self)
end

return CircleFixtureComponent
