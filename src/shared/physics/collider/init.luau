local module = {}
module.__index = module

function module:test()
    print("hi")
    print(self)
end

function module.new()
    local self = setmetatable({}, module)

    -- area is determined by the shape
    self.area = 0
    self.rigidbody2d = nil

    return self
end


return module