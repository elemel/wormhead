local Turner = {}
Turner.__index = Turner

function Turner.new(vehicle, config)
    local turner = setmetatable({}, Turner)
    turner.vehicle = assert(vehicle)
    local world = turner.vehicle.body:getWorld()
    local x, y = turner.vehicle.body:getPosition()
    turner.body = love.physics.newBody(world, x, y, "kinematic")
    turner.joint = love.physics.newFrictionJoint(turner.body, turner.vehicle.body, x, y)
    config = config or {}
    maxTorque = config.maxTorque or 0
    turner.joint:setMaxTorque(maxTorque)
    return turner
end

function Turner:destroy()
    self.joint:destroy()
    self.body:destroy()
end

return Turner
