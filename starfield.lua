starfield = {}
starfield.state = "initial"
starfield.count = 128
starfield.stars = {}
starfield.vel_multiplier = 1

function updateStarfield(dt)
    for i=1,#starfield.stars,1 do
        local v = starfield.stars[i]
        v.y = v.y + v.velocity*dt
        v.x = v.x - .1*player.xvel*dt
        v.y = v.y - .1*player.yvel*dt
        if v.y > 600 then
            v = resetStar(v, v.x, v.y)
        end
    end
end

function resetStar(star, x, y)
    star.y = -5
    star.x = math.random(600)
    star.velocity = (math.random(10) + 1) * starfield.vel_multiplier
    star.radius = math.random(1.5)
    star.color_r = 200+math.random(55)
    star.color_g = 200+math.random(55)
    star.color_b = 200+math.random(55)
    return star
end

function drawStarfield()
    for i=1,#starfield.stars,1 do
        local v = starfield.stars[i]
        love.graphics.setColor(v.color_r, v.color_g, v.color_b);
        love.graphics.circle("fill",v.x,v.y,v.radius,6)
    end
end

return starfield
