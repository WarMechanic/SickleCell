--base class for colliders
local module = {}
module.__index = module

export type Collider = {
    rigidbody2d : Rigidbody2d
    ,area : number
}

function module:test()
    print("hi")
    print(self)
end

--implemented in child classes
function module:calculateArea()
    return 0
end

function module.new() : Collider
    local self = setmetatable({}, module)
    self.rigidbody2d = nil

    -- area is determined by the shape
    self.area = 0

    return self
end


return module