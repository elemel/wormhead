local utils = require("utils")

local WormEdge = {}
WormEdge.__index = WormEdge
WormEdge.entityType = "wormEdge"

function WormEdge.new(tail, head)
    local edge = setmetatable({}, WormEdge)
    edge.tail = assert(tail)
    edge.tail.headEdge = edge
    edge.head = assert(head)
    edge.head.tailEdge = edge
    local x1, y1 = tail.body:getWorldPoint(0, -0.5)
    local x2, y2 = head.body:getWorldPoint(0, 0.5)
    edge.joint = love.physics.newRevoluteJoint(tail.body, head.body, x1, y1, x2, y2, false, 0)

    edge.joint:setUserData({
        entity = edge,
        userType = "wormEdge",
    })

    edge.joint:setLimitsEnabled(true)
    edge.joint:setLimits(-0.375 * math.pi, 0.375 * math.pi)
    edge.tail.groupIndex = edge.head.groupIndex
    edge.tail.fixture:setGroupIndex(-edge.tail.groupIndex)
    return edge
end

function WormEdge:destroy()
    self.joint:destroy()
    self.head.tailEdge = nil
    self.tail.headEdge = nil
end

return WormEdge
