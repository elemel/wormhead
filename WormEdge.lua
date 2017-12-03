local utils = require("utils")

local WormEdge = {}
WormEdge.__index = WormEdge
WormEdge.entityType = "wormEdge"

function WormEdge.new(tail, head)
    local edge = setmetatable({}, WormEdge)
    edge.tail = assert(tail)
    edge.head = assert(head)
    local oldTail = nil

    if edge.head.tailEdge then
        oldTail = assert(edge.head.tailEdge.tail)
        edge.head.tailEdge:destroy()
    end

    edge.tail.headEdge = edge
    edge.head.tailEdge = edge
    local x1, y1 = tail.body:getWorldPoint(0, -0.5)
    local x2, y2 = head.body:getWorldPoint(0, 0.5)
    local angle1 = tail.body:getAngle()
    local angle2 = head.body:getAngle()
    local referenceAngle = 2 * math.pi * math.floor((angle2 - angle1) / (2 * math.pi) + 0.5)
    edge.joint = love.physics.newRevoluteJoint(tail.body, head.body, x1, y1, x2, y2, false, referenceAngle)

    edge.joint:setUserData({
        entity = edge,
        userType = "wormEdge",
    })

    edge.joint:setLimitsEnabled(true)
    edge.joint:setLimits(-0.25 * math.pi, 0.25 * math.pi)
    edge.tail.groupIndex = edge.head.groupIndex
    edge.tail.fixture:setGroupIndex(-edge.tail.groupIndex)

    if oldTail then
        WormEdge.new(oldTail, edge.tail)
    end

    return edge
end

function WormEdge:destroy()
    self.joint:destroy()
    self.head.tailEdge = nil
    self.tail.groupIndex = 0
    self.tail.fixture:setGroupIndex(0)
    self.tail.headEdge = nil
end

function WormEdge:destroyTail()
    if self.tail.tailEdge then
        self.tail.tailEdge:destroyTail()
    end

    self:destroy()
end

return WormEdge
