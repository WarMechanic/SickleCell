local collider = require(script.Parent)

local module = {}
module.__index = module


function module.new(radius : number)
    local collider = collider.new()
    local new = setmetatable(collider, module)

    new.radius = radius
    collider.area = math.pi * new.radius^2

    return new
end


return module