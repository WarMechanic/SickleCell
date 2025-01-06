local module = {}
module.__index = module


function module.new()
    local new = setmetatable({}, module)

    new.area = 0

    return new
end


return module