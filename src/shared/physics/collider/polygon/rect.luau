-- inherit from collider
local polygon = require(script.Parent)
local module = setmetatable({}, polygon)
module.__index = module

export type Rect = polygon.Polygon&{
    size : Vector2
}

function module:calculateArea()
    return self.size.X * self.size.Y
end

function module:setSize(size : Vector2)
    self.size = size

    local halfSize : Vector2 = self.size / 2
    self:setVertices({
         Vector2.new( halfSize.X,  halfSize.Y)
        ,Vector2.new( halfSize.X, -halfSize.Y)
        ,Vector2.new(-halfSize.X, -halfSize.Y)
        ,Vector2.new(-halfSize.X,  halfSize.Y)
    })

    return true
end

function module.new(size) : polygon.Polygon
    local polygon = polygon.new()
    local self = setmetatable(polygon, module)

    self:setSize(size)

    return self
end

return module