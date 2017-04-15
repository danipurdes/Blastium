lancer = {}

lancer.image = love.graphics.newImage("assets/images/enemy_lancer.png")
lancer.image_charging = love.graphics.newImage("assets/images/enemy_lancer_charging.png")
lancer.draw_image = lancer.image
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
lancer.charge_speed = 500
lancer.recover_tgt_x = 0
lancer.recover_tgt_y = 0
lancer.recover_speed = 30

function updateLancer(la, dt)
    if not (la.state == "dead") then
        la.x = la.x + dt * la.speed * math.cos(la.rotation)
        la.y = la.y + dt * la.speed * math.sin(la.rotation)
        if la.state == "preparing" then
            la.prep_age = la.prep_age + dt
            la.rotation = math.atan2(player.y - la.y, player.x - la.x)
            if la.prep_age >= la.prep_duration then
                la.state = "charging"
                la.draw_image = la.image_charging
                la.speed = la.charge_speed
                la.prep_age = 0
            end
        elseif la.state == "charging" then
            local outb = false
            if la.x >= world.width + 16 then
                outb = true
            elseif la.x <= -16 then
                outb = true
            elseif la.y >= world.height + 16 then
                outb = true
            elseif la.y <= -16 then
                outb = true
            end

            if outb then
                la.state = "recovering"
                la.draw_image = la.image
                la.speed = la.recover_speed
                la.recover_tgt_x = world.width/2
                la.recover_tgt_y = world.height/2
                la.rotation = math.atan2(la.recover_tgt_y - la.y, la.recover_tgt_x - la.x)
            end
        elseif la.state == "recovering" then
            if la.x > 32 and la.x < world.width - 32 and la.y > 32 and la.y < world.height - 32 then
                la.state = "preparing"
                la.speed = la.prep_speed
            end
        end
    end
end

function spawnLancer(x, y)
    local l = {}
    l.image = lancer.image
    l.image_charging = lancer.image_charging
    l.draw_image = lancer.image
    l.x = x
    l.y = y
    l.rotation = lancer.rotation
    l.radius = lancer.radius
    l.speed = lancer.speed
    l.removal_flag = lancer.removal_flag
    l.score = lancer.score
    l.state = lancer.state
    l.prep_age = lancer.prep_age
    l.prep_duration = lancer.prep_duration
    l.prep_speed = lancer.prep_speed
    l.charge_speed = lancer.charge_speed
    l.recover_tgt_x = lancer.recover_tgt_x
    l.recover_tgt_y = lancer.recover_tgt_y
    l.recover_speed = lancer.recover_speed
    table.insert(lancers, l)
end

return lancer
