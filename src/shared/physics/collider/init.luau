local module = {}
module.__index = module


function module.new()
    local new = setmetatable({}, module)

    -- area is determined by the shape
    new.area = 0
    new.rigidbody2d = nil

    --unimplemented, implement in children
    new.intersectCircle = function() return false end
    new.intersectPolygon = function() return false end

    return new
end


return module