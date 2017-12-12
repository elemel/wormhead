local WheelJointComponent = {}
WheelJointComponent.__index = WheelJointComponent
WheelJointComponent.componentType = "wheelJoint"
WheelJointComponent.componentName = "joint"

function WheelJointComponent.new(entity, config)
    local component = setmetatable({}, WheelJointComponent)
    component.entity = assert(entity)
    component.entity:addComponent(component)
    local childBodyComponent = assert(entity:getAncestorComponent("body"))
    local parentBodyComponent = assert(childBodyComponent.entity:getAncestorComponent("body", 1))
    local transformComponent = assert(entity:getAncestorComponent("transform"))
    transformComponent:setDirty(false)
    local x, y = transformComponent.worldTransform:transformPoint(0, 0)
    local axisX, axisY = transformComponent.worldTransform:transformVector(0, -1)
    component.joint = love.physics.newWheelJoint(parentBodyComponent.body, childBodyComponent.body, x, y, axisX, axisY)
    component.joint:setUserData(component)
    local springFrequency = config.springFrequency or 1
    component.joint:setSpringFrequency(springFrequency)
    local motorEnabled = config.motorEnabled or false
    component.joint:setMotorEnabled(motorEnabled)
    local maxMotorTorque = config.maxMotorTorque or 1
    component.joint:setMaxMotorTorque(maxMotorTorque)
    return component
end

function WheelJointComponent:destroy()
    self.joint:destroy()
    self.entity:removeComponent(self)
end

return WheelJointComponent
