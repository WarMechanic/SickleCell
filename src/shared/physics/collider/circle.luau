local collider = require(script.Parent)

local module = {}
module.__index = module


function module.new(radius : number)
    local collider = collider.new()
    local new = setmetatable(collider, module)

    new.radius = radius

    new.area = math.pi * new.radius^2

    new.intersectCircle = function(other)
        local distance : number = (new.rigidbody2d.position + other.rigidbody2d.position).Magnitude
        local radii = new.radius + other.radius

        if (distance > radii) then
            return false
        end

        local outNormal = (other.rigidbody2d.position - new.rigidbody2d.position).Unit
        local outDepth = distance - radii

        return true, outNormal, outDepth
    end

    return new
end


return module