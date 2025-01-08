local collider = require(script.Parent)

local module = setmetatable({}, collider)
module.__index = module

function module:intersectCircle(other)
    local distance : number = (other.rigidbody2d.position - self.rigidbody2d.position).Magnitude
    local radii = self.radius + other.radius

    if (distance > radii) then
        return false
    end

    local outNormal = (other.rigidbody2d.position - self.rigidbody2d.position).Unit
    local outDepth = radii - distance

    return true, outNormal, outDepth
end

function module.new(radius : number)
    local collider = collider.new()
    local self = setmetatable(collider, module)

    self.radius = radius

    self.area = math.pi * self.radius^2

    return self
end

return module