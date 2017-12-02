local WormTail = {}
WormTail.__index = WormTail

function WormTail.new(head)
    local tail = setmetatable({}, WormTail)
    return tail
end

function WormTail:destroy()
end

return WormTail
