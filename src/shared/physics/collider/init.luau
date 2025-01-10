local rigidbody2d = require(script.Parent.rigidbody2d)

--base class for colliders
local module = {}
module.__index = module

export type Collider = {
    rigidbody2d : rigidbody2d.Rigidbody2d
    ,area : number
}

function module:test()
    print("hi")
    print(self)
end

function module.new() : Collider
    local self = setmetatable({}, module)
    self.rigidbody2d = nil

    -- area is determined by the shape
    self.area = 0

    return self
end


return module