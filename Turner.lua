local Turner = {}
Turner.__index = Turner

function Turner.new(vehicle, config)
    local turner = setmetatable({}, Turner)
    turner.vehicle = assert(vehicle)
    local world = turner.vehicle.body:getWorld()
    turner.body = love.physics.newBody(world, 0, 0, "kinematic")
    turner.joint = love.physics.newFrictionJoint(turner.vehicle.body, turner.body, 0, 0)
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
