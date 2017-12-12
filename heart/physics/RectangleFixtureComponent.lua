local RectangleFixtureComponent = {}
RectangleFixtureComponent.__index = RectangleFixtureComponent
RectangleFixtureComponent.objectType = "component"
RectangleFixtureComponent.componentType = "rectangleFixture"
RectangleFixtureComponent.componentName = "fixture"

function RectangleFixtureComponent.new(entity, config)
    local component = setmetatable({}, RectangleFixtureComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    local bodyComponent = assert(entity:getAncestorComponent("body"))
    local transformComponent = assert(entity:getAncestorComponent("transform"))
    transformComponent:setDirty(false)

    local x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY =
        transformComponent.worldTransform:decompose()

    x, y = bodyComponent.body:getLocalPoint(x, y)
    angle = angle - bodyComponent.body:getAngle()
    local width = config.width or 1
    local height = config.height or 1
    width = scaleX * width
    height = scaleY * height
    local shape = love.physics.newRectangleShape(x, y, width, height, angle)
    local density = config.density or 1
    component.fixture = love.physics.newFixture(bodyComponent.body, shape, density)
    component.fixture:setUserData(component)
    return component
end

function RectangleFixtureComponent:destroy()
    self.fixture:destroy()
    self.entity:removeComponent(self)
end

return RectangleFixtureComponent
