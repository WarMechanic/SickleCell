-- inherit from collider
local collider = require(script.Parent)
local collisions = require(script.Parent.Parent.collisions)

local module = setmetatable({}, collider)
module.__index = module

export type Circle = collider.Collider&{
    radius : number
    ,
}

function module:calculateArea()
    return math.pi * self.radius^2
end

-- check if two circle colliders intersect, does NOT resolve collisions (useful for triggers)
function module:intersectCircle(other)
    return collisions:intersectCircleCircle(
        self.rigidbody2d.position,
        other.rigidbody2d.position,
        self.radius,
        other.radius
    )
end

function module.new(radius : number)
    local collider = collider.new()
    local self = setmetatable(collider, module)

    self.radius = radius

    self.area = math.pi * self.radius^2

    return self
end

return module