utilities = {}

function distance(x1, y1, x2, y2)
    local xdist = math.pow(x1-x2, 2)
    local ydist = math.pow(y1-y2, 2)
    local dist = math.sqrt(xdist + ydist)
    return dist
end

function circle_overlap(x1,y1,r1,x2,y2,r2)
    local rdist = r1 + r2
    local tdist = distance(x1, y1, x2, y2)
    --return tdist - rdist
    return tdist < rdist
end

function lerp(a, t, b, m)
    local value = math.abs(b - a) * (t / m) + math.min(a, b)
    return value
end

return utilities
