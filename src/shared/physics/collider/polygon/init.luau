-- inherit from collider
local collider = require(script.Parent)
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
    if  self.transformVertices == {} or 
        (self.rigidbody2d.position == self.transformPosition and self.rigidbody2d.rotation == self.transformRotation)
    then
        return self._transformVertices
    end

    -- otherwise transform all the vertices and cache the result
    self._transformVertices = {}
    self.transformPosition = self.rigidbody2d.position
    self.transformRotation = self.rigidbody2d.rotation

    for index, vertex : Vector2 in self.vertices do
        self._transformVertices[index] = getTransformVertex(vertex, self.transformRotation) + self.transformPosition
    end

    return self._transformVertices
end

-- pre-req functions for module:intersectPolygon
-- projects a set of vertices on an axis to find minimum and maximum values
local projectVertices = function(vertices : table<Vector2>, axis : Vector2) : boolean & number & number
    local min = math.huge
    local max = -math.huge
    
    for index, vertex : Vector2 in vertices do
        local projection = vertex:Dot(axis)
        if      (projection < min) then min = projection
        elseif  (projection > max) then max = projection
        end
    end

    return true, min, max
end

-- tests all vertices from shapes A and B on normal axes of vertices A
local testAxes = function(verticesA : table<Vector2>, verticesB : table<Vector2>)
    local outNormal = Vector2.zero
    local outDepth = math.huge

    if (verticesA == nil or verticesB == nil) then
        return false, outNormal, outDepth
    end

    -- use current and next vertex to create edges, and then create normals
    for index, vertex : Vector2 in verticesA do
        local vertexNext = verticesA[index % #verticesA + 1]

        local edge = vertexNext - vertex
        local axis = Vector2.new(-edge.Y, edge.X)

        -- project all vertices along this axis to find mins and maxes
        local _, minA, maxA = projectVertices(verticesA, axis)
        local _, minB, maxB = projectVertices(verticesB, axis)

        -- escape if we find an axis that does not intersect
        if (minA >= maxB or minB >= maxA) then return false, outNormal, outDepth end

        -- otherwise, store the minimum depth
        local axisDepth = math.min(maxB - minA, maxA - minB)
        if (axisDepth < outDepth) then
            outNormal = axis
            outDepth = axisDepth
        end
    end

    return true, outNormal, outDepth
end

-- runs aforementioned test twice, where both this and the other polygon are used as main shapes
-- check if two circle colliders intersect, does NOT resolve collisions (useful for triggers)
function module:intersectPolygon(other : Polygon)
    local testA, normalA, depthA = testAxes(self:getTransformedVertices(), other:getTransformedVertices())
    local testB, normalB, depthB = testAxes(other:getTransformedVertices(), self:getTransformedVertices())
    if (not (testA or testB)) then
        return false
    end

    local outNormal = normalA
    local outDepth = depthA

    if (depthB < depthA) then
        outNormal = normalB
        outDepth = normalB
    end

    -- we dont normalise depth until now to save resources
    outDepth /= outNormal.Magnitude
    outNormal = outNormal.Unit

    return true, outNormal, outDepth
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