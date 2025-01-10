-- require circle collider for default collider
local collider = require(script.Parent.collider)
local circleCollider = require(script.Parent.collider.circle)

local module = {}
module.__index = module

export type rigidbody2d = {
    position : Vector2
    ,linearVelocity : Vector2
    ,rotation : number
    ,rotationalVelocity : number
    ,collider : collider.collider
    ,density : number
    ,mass : number
    ,isStatic : boolean
}

-- !!!! todo: multiple collider support
function module:setCollider(collider)
    if (not collider) then
        return false
    end

    self.collider = collider
    collider.rigidbody2d = self

    return true
end

function module.new()
    local new = setmetatable({}, module)

    new.position = Vector2.new()
    new.linearVelocity = Vector2.new()

    new.rotation = 0
    new.rotationalVelocity = 0

    -- default to a circle, simplest shape
    new:setCollider(circleCollider.new(1))

    -- density is a constant, mass scales off density and geometry
    new.density = 1
    new.mass = 0

    -- isStatic makes the object immovable, use for terrain / static props
    new.isStatic = false

    return new
end


return module