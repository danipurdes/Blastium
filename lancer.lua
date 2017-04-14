lancer = {}

lancer.image = love.graphics.newImage("assets/images/enemy_lancer.png")
lancer.x = 50
lancer.y = 50
lancer.rotation = 0
lancer.radius = 8
lancer.speed = -2.5
lancer.removal_flag = false
lancer.score = 500
lancer.state = "preparing"
lancer.prep_age = 0
lancer.prep_duration = 5
lancer.prep_speed = -2.5
lancer.charge_speed = 300
lancer.recover_tgt_x = 0
lancer.recover_tgt_y = 0
lancer.recover_speed = 30

function updateLancer(dt)
    if not (lancer.state == "dead") then
        lancer.x = lancer.x + dt * lancer.speed * math.cos(lancer.rotation)
        lancer.y = lancer.y + dt * lancer.speed * math.sin(lancer.rotation)
        if lancer.state == "preparing" then
            lancer.prep_age = lancer.prep_age + dt
            lancer.rotation = math.atan2(player.y - lancer.y, player.x - lancer.x)
            if lancer.prep_age >= lancer.prep_duration then
                lancer.state = "charging"
                lancer.speed = lancer.charge_speed
                lancer.prep_age = 0
            end
        elseif lancer.state == "charging" then
            local outb = false
            if lancer.x >= world.width + 16 then
                outb = true
            elseif lancer.x <= -16 then
                outb = true
            elseif lancer.y >= world.height + 16 then
                outb = true
            elseif lancer.y <= -16 then
                outb = true
            end

            if outb then
                lancer.state = "recovering"
                lancer.speed = lancer.recover_speed
                lancer.recover_tgt_x = world.width/2
                lancer.recover_tgt_y = world.height/2
                lancer.rotation = math.atan2(lancer.recover_tgt_y - lancer.y, lancer.recover_tgt_x - lancer.x)
            end
        elseif lancer.state == "recovering" then
            if lancer.x > 32 and lancer.x < world.width - 32 and lancer.y > 32 and lancer.y < world.height - 32 then
                lancer.state = "preparing"
                lancer.speed = lancer.prep_speed
            end
        end
    end
end

return lancer
