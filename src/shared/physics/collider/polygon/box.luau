-- inherit from collider
local polygon = require(script.Parent)
local module = setmetatable({}, polygon)
module.__index = module

export type Box = polygon.Polygon&{
    size : Vector2
}

function module:calculateArea()
    return self.size.X
end

function module:setSize(size : Vector2)
    self.size = size
    self:setVertices({
         Vector2.new( self.size.X,  self.size.Y)
        ,Vector2.new( self.size.X, -self.size.Y)
        ,Vector2.new(-self.size.X, -self.size.Y)
        ,Vector2.new(-self.size.X,  self.size.Y)
    })

    return true
end

function module.new(size) : polygon.Polygon
    local polygon = polygon.new()
    local self = setmetatable(polygon, module)

    self.size = size

    return self
end

return module