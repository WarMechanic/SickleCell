-- inherit from collider
local collider = require(script.Parent)
local collisions = require(script.Parent.Parent.collisions)
local module = setmetatable({}, collider)
module.__index = module

export type Polygon = collider.Collider&{
    vertices: table<Vector2>
    ,_transformRotation: number
    ,_transformVertices: table<Vector2>
}

-- todo: calculateArea
--[[
function module:calculateArea()
    
end
]]

function module:setVertices(vertices : table<Vector2>)
    self.vertices = vertices
    self.area = self:calculateArea()

    return true
end

-- vector rotation matrix
local getTransformVertex = function(vertex : Vector2, rotation : number)
    return Vector2.new(
        vertex.X * math.cos(rotation) - vertex.Y * math.sin(rotation)
        ,vertex.X * math.sin(rotation) + vertex.Y * math.cos(rotation)
    )
end

-- get transformed vertices based on rigidbody angle
function module:getTransformedVertices() : ...Vector2
    -- (optimisation)
    -- if transform is identical to last time then we can simply return transformVertices
    if  self._transformVertices ~= {} and 
        self.rigidbody2d.position == self._transformPosition and
        self.rigidbody2d.rotation == self._transformRotation
    then
        return self._transformVertices
    end

    -- otherwise transform all the vertices and cache the result
    self._transformVertices = {}
    self._transformPosition = self.rigidbody2d.position
    self._transformRotation = self.rigidbody2d.rotation

    for index, vertex : Vector2 in self.vertices do
        self._transformVertices[index] = getTransformVertex(vertex, self._transformRotation) + self._transformPosition
    end

    return self._transformVertices
end

-- check if two circle colliders intersect, does NOT resolve collisions (useful for triggers)
function module:intersectPolygon(other : Polygon)
    return collisions:intersectPolygonPolygon(
        self.rigidbody2d.position, 
        other.rigidbody2d.position, 
        self:getTransformedVertices(), 
        other:getTransformedVertices()
    )
end

function module:intersectCircle(other : Circle)
    return collisions:intersectCirclePolygon(
        other.rigidbody2d.position,
        other.radius,
        self.rigidbody2d.position,
        self:getTransformedVertices()
    )
end

function module.new(vertices : table<Vector2>) : Polygon
    local collider = collider.new()
    local self = setmetatable(collider, module)

    -- vertices are a table of vectors
    self:setVertices(vertices)

    self._transformRotation = 0
    self._transformVertices = self.vertices or {}

    return self
end

return module