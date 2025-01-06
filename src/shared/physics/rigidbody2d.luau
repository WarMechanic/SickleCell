local circleCollider = require(script.Parent.physics.collider.circle)

local module = {}
module.__index = module


function module.new()
    local new = setmetatable({}, module)

    new.position = Vector2.new()
    new.linearVelocity = Vector2.new()

    new.rotation = Vector2.new()
    new.rotationalVelocity = Vector2.new()

    --todo: multiple collider support
    new.collider = circleCollider.new(1)

    -- density is a constant, mass scales off density and geometry
    new.density = 1
    new.mass = 0

    -- isStatic makes the object immovable, use for terrain / static props
    new.isStatic = false

    return new
end


return module