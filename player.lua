player = {}
player.active = true
player.x = 0
player.y = 0
player.xvel = 0
player.yvel = 0
player.rotation = 0
player.ANGACCEL = 0
player.image = love.graphics.newImage("assets/images/ship_bosco.png")
player.weapon_index = 0
player.rotation_speed = 180
player.acceleration = 400
player.drag = 100
player.max_speed = 400

function playerMovement(dt)
    vel_total = math.sqrt(math.pow(player.xvel,2) + math.pow(player.yvel,2))

    if love.keyboard.isDown("d") then
        --player.ANGACCEL = ANGACCEL * dt / vel_total
        player.rotation = player.rotation + (vel_total/player.max_speed + 1) * (player.rotation_speed * math.pi / 180) * dt;
    elseif love.keyboard.isDown("a") then
        --player.ANGACCEL = -ANGACCEL * dt / vel_total
        player.rotation = player.rotation - (vel_total/player.max_speed + 1) * (player.rotation_speed * math.pi / 180) * dt;
    end

    --player.ANGACCEL = player.ANGACCEL * ANG_RESISTANCE
    --player.rotation = player.rotation + player.ROTATION_S * dt

    if love.keyboard.isDown("s") then
        -- decelerate / accelerate backwards
        player.xvel = player.xvel * .9
        player.yvel = player.yvel * .9
    end

    if love.keyboard.isDown("w") then
        -- accelerate
        player.xvel = player.xvel + player.acceleration * dt * math.cos(player.rotation)
        player.yvel = player.yvel + player.acceleration * dt * math.sin(player.rotation)
    end

    player.xvel = player.xvel - (player.xvel / player.drag)
    player.yvel = player.yvel - (player.yvel / player.drag)

    if vel_total > player.max_speed then
        player.xvel = player.xvel / vel_total * player.max_speed
        player.yvel = player.yvel / vel_total * player.max_speed
    end

    player.x = player.x + player.xvel * dt
    player.y = player.y + player.yvel * dt

    if player.x > world.width then
        player.x = player.x - world.width
    elseif player.x < 0 then
        player.x = player.x + world.width
    end

    if player.y > world.height then
        player.y = player.y - world.height
    elseif player.y < 0 then
        player.y = player.y + world.height
    end

    bullet_weapon.firing_rate_current = math.max(0, bullet_weapon.firing_rate_current - dt)
    shell_weapon.firing_rate_current = math.max(0, shell_weapon.firing_rate_current - dt)

    if love.keyboard.isDown(";") then
        fire_bullet_weapon()
    end
end

function drawPlayer()
    if player.active then
        love.graphics.setColor(255,255,255)
        love.graphics.draw(player.image, player.x, player.y, player.rotation, 1, 1, player.image:getWidth()/2, player.image:getHeight()/2)
        local px = player.x
        local py = player.y
        local hx = world.width/2
        local hy = world.height/2
        if ((hx-px)^2+(hy-py)^2)^0.5 > 250 then
            love.graphics.draw(player.image, player.x - world.width, player.y - world.height, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, player.x - world.width, player.y, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, player.x - world.width, player.y + world.height, player.rotation, 1, 1, 16, 16)

            love.graphics.draw(player.image, player.x, player.y - world.height, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, player.x, player.y + world.height, player.rotation, 1, 1, 16, 16)

            love.graphics.draw(player.image, player.x + world.width, player.y - world.height, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, player.x + world.width, player.y, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, player.x + world.width, player.y + world.height, player.rotation, 1, 1, 16, 16)
        end
    end
end

function onPlayerDeath()
    player.active = false
    worldStateChange("end")
    despawnEnemies()
    despawnBullets()
    despawnShells()
end

return player
