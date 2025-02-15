local module = {}
module.__index = module

-- intersect check for two circles (very simple!)
function module:intersectCircleCircle(positionA : Vector2, positionB : Vector2, radiusA : number, radiusB : number)
    local distance : number = (positionB - positionA).Magnitude

    -- two circles touch when the distance between them is less than or equal to both their radii
    local radii = radiusA + radiusB

    if (distance > radii) then
        return false
    end

    -- output additional values beyond check for functionality
    local outNormal = (positionB - positionA).Unit
    local outDepth = radii - distance

    return true, outNormal, outDepth
end

-- pre-req functions for module:intersectPolygonPolygon
-- projects a set of vertices on an axis to find minimum and maximum values
local projectVerticesPolygon = function(vertices : table<Vector2>, axis : Vector2) : boolean & number & number
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

local projectVerticesCircle = function(vertices : table<Vector2> | Vector2, axis : Vector2, radius : number)
    local position = vertices[1]
    local direction = axis.Unit
    local directionAndRadius = direction * radius

    local p1 = position + directionAndRadius
    local p2 = position - directionAndRadius

    local min = p1:Dot(axis)
    local max = p2:Dot(axis)

    if (min > max) then
        local t = min
        min = max
        max = t
    end

    return true, min, max
end

local projectVertices = function(vertices: table, axis : Vector2, radius : number?)
    if type(vertices) ~= "table" then
        vertices = {vertices}
    end

    if not radius then
        return projectVerticesPolygon(vertices, axis)
    end
    return projectVerticesCircle(vertices, axis, radius)
end
-- tests all vertices from shapes A and B on normal axes of vertices A
local testAxes = function(verticesA : table<Vector2>, verticesB : table<Vector2>, radiusA, radiusB)
    local outNormal = Vector2.zero
    local outDepth = math.huge

    if (verticesA == nil or verticesB == nil) then
        return false, outNormal, outDepth
    end

    if type(verticesA) ~= "table" then
        verticesA = {verticesA}
    end

    -- use current and next vertex to create edges, and then create normals
    for index, vertex : Vector2 in verticesA do
        local vertexNext = verticesA[index % #verticesA + 1]

        local edge = vertexNext - vertex
        local axis = Vector2.new(-edge.Y, edge.X)

        -- project all vertices along this axis to find mins and maxes
        local _, minA, maxA = projectVertices(verticesA, axis, radiusA)
        local _, minB, maxB = projectVertices(verticesB, axis, radiusB)

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

function module:intersectPolygonPolygon(positionA : Vector2, positionB : Vector2, verticesA, verticesB)
    local testA, normalA, depthA = testAxes(verticesA, verticesB, nil, nil)
    local testB, normalB, depthB = testAxes(verticesB, verticesA, nil, nil)
    if (not (testA or testB)) then
        return false
    end

    local outNormal = normalA
    local outDepth = depthA

    if (depthB < depthA) then
        outNormal = normalB
        outDepth = depthB
    end

    -- we dont normalise depth until now to save resources
    outDepth /= outNormal.Magnitude
    outNormal = outNormal.Unit

    -- ensure the normal is pointing outward rather than inward
    -- LIMITATION, assumes that the average position is in the center, this won't always be the case!
    local direction : Vector2 = positionB - positionA
    if (direction:Dot(outNormal) < 0) then outNormal = -outNormal end

    return true, outNormal, outDepth
end

local findClosestPointOnPolygon = function(center : Vector2, vertices : table)
    local out = -1
    local min = math.huge

    for i = 1, #vertices, 1 do
        local vertex = vertices[i]
        local distance = (vertex - center).Magnitude

        if (distance < min) then
            min = distance
            out = i
        end
    end

    if (out > -1) then
        return true, out
    end
    return false
end

function module:intersectCirclePolygon(circlePosition : Vector2, circleRadius : number, polygonPosition : Vector2, polygonVertices : table)
    local circleTest, circleNormal, circleDepth = testAxes(circlePosition, polygonVertices, circleRadius, nil)
    local polygonTest, polygonNormal, polygonDepth = testAxes(polygonVertices, circlePosition, nil, circleRadius)
    if (not (circleTest or polygonTest)) then
        return false
    end

    local outNormal = circleNormal
    local outDepth = circleDepth

    if (polygonDepth < circleDepth) then
        outNormal = polygonNormal
        outDepth = polygonDepth
    end
 
    -- circles require an additional check for the closest point to the circle
    local _, cpIndex = findClosestPointOnPolygon(circlePosition, polygonVertices)
    local cp = polygonVertices[cpIndex]

    local axis = cp - circlePosition
    
    -- axis test from circle to closest point
    local _, circleMin, circleMax = projectVertices(circlePosition, axis, circleRadius)
    local _, polygonMin, polygonMax = projectVertices(polygonVertices, axis, nil)

    if (circleMin >= polygonMax or polygonMin >= circleMax) then return false, outNormal, outDepth end

    local axisDepth = math.min(polygonMax - circleMin, circleMax - polygonMin)
    if (axisDepth < outDepth) then
        outNormal = axis
        outDepth = axisDepth
    end

    if (outNormal.Magnitude == 0) then return false, outNormal, outDepth end

    -- we dont normalise depth until now to save resources
    outDepth /= outNormal.Magnitude
    outNormal = outNormal.Unit

    -- ensure the normal is pointing outward rather than inward
    -- LIMITATION, assumes that the average position is in the center, this won't always be the case!
    local direction : Vector2 = polygonPosition - circlePosition
    if (direction:Dot(outNormal) < 0) then outNormal = -outNormal end

    return true, outNormal, outDepth
end

return module