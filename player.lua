player = {}

player.active = true
player.state = "alive"
player.x = 0
player.y = 0
player.xvel = 0
player.yvel = 0
player.rotation = 0
player.ANGACCEL = 0
player.radius = 8

player.image = love.graphics.newImage("assets/images/ship_bosco.png")
player.thrust_sound = love.audio.newSource("assets/audio/ship_thruster3.wav")
player.damage_sound = love.audio.newSource("assets/audio/player_damage.wav","static")
player.death_sound = love.audio.newSource("assets/audio/player_death.wav","static")

player.rotation_speed = 180
player.acceleration = 400
player.drag = 399
player.max_speed = 400

player.health = 5
player.health_max = 5

player.isHurt = false
player.hurtCooldown = 1
player.hurtTimer = 1
player.death_fadeout_timer = 2
player.death_fadeout_cooldown = 2

function loadPlayer()
    player.active = true
    player.state = "alive"

    player.x = world.width / 2
    player.y = world.height / 2
    player.rotation = 3 * math.pi / 2
    player.xvel = 0
    player.yvel = 0
    player.health = 5
    player.hurt = false

    player.hurtTimer = player.hurtCooldown
    player.death_fadeout_timer = player.death_fadeout_cooldown

    world.score = 0
    world.high_score_flag = false
end

function playerMovement(dt)
    vel_total = math.sqrt(math.pow(player.xvel,2) + math.pow(player.yvel,2))

    if love.keyboard.isDown("right") then
        --player.ANGACCEL = ANGACCEL * dt / vel_total
        player.rotation = player.rotation + (vel_total/player.max_speed + 1) * (player.rotation_speed * math.pi / 180) * dt;
    elseif love.keyboard.isDown("left") then
        --player.ANGACCEL = -ANGACCEL * dt / vel_total
        player.rotation = player.rotation - (vel_total/player.max_speed + 1) * (player.rotation_speed * math.pi / 180) * dt;
    end

    --player.ANGACCEL = player.ANGACCEL * ANG_RESISTANCE
    --player.rotation = player.rotation + player.ROTATION_S * dt

        -- forward backward
        if love.keyboard.isDown("down") then
            -- decelerate / accelerate backwards
            player.xvel = player.xvel * .9
            player.yvel = player.yvel * .9
        end

        if love.keyboard.isDown("up") then
            -- accelerate
            player.xvel = player.xvel + player.acceleration * dt * math.cos(player.rotation)
            player.yvel = player.yvel + player.acceleration * dt * math.sin(player.rotation)
            love.audio.stop(player.thrust_sound)
            love.audio.play(player.thrust_sound)
        end

        --dragrate = player.drag * dt
        --love.graphics.printf(dragrate, 40, 100, world.width);
        player.xvel = (player.xvel * .9975)--player.drag * dt)
        player.yvel = (player.yvel * .9975)--player.drag * dt)

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

    if love.keyboard.isDown("z") then
        fire_bullet_weapon()
    end

    if player.hurt then
        player.hurtTimer = player.hurtTimer - dt

        if player.hurtTimer <= 0 then
            player.hurtTimer = player.hurtCooldown
            player.hurt = false
        end
    end
end

function drawPlayer(origin_x, origin_y)
    if player.active then
        if not player.hurt then
            love.graphics.setColor(255,255,255)
        else
            love.graphics.setColor(200 + 55 * (1 - player.hurtTimer), 50 + 100 * (1 - player.hurtTimer), 50 + 100 * (1 - player.hurtTimer))
        end

        love.graphics.draw(player.image, origin_x + player.x, origin_y + player.y, player.rotation, 1, 1, player.image:getWidth()/2, player.image:getHeight()/2)
        local px = player.x
        local py = player.y
        local hx = world.width/2
        local hy = world.height/2
        if ((hx-px)^2+(hy-py)^2)^0.5 > 250 then
            love.graphics.draw(player.image, origin_x + player.x - world.width, origin_y + player.y - world.height, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, origin_x + player.x - world.width, origin_y + player.y, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, origin_x + player.x - world.width, origin_y + player.y + world.height, player.rotation, 1, 1, 16, 16)

            love.graphics.draw(player.image, origin_x + player.x, origin_y + player.y - world.height, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, origin_x + player.x, origin_y + player.y + world.height, player.rotation, 1, 1, 16, 16)

            love.graphics.draw(player.image, origin_x + player.x + world.width, origin_y + player.y - world.height, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, origin_x + player.x + world.width, origin_y + player.y, player.rotation, 1, 1, 16, 16)
            love.graphics.draw(player.image, origin_x + player.x + world.width, origin_y + player.y + world.height, player.rotation, 1, 1, 16, 16)
        end

        --love.graphics.points(player.x + 60 * math.cos(player.rotation), player.y + 60 * math.sin(player.rotation))
        --local speedText = player.xvel .. ", " .. player.yvel
        --love.graphics.setColor(255,255,255)
        --love.graphics.printf(speedText, 20, 200, world.width)
    end
end

function onPlayerDamage(x, y)
    local xVect = player.x - x
    local yVect = player.y - y
    local mVect = distance(player.x, player.y, x, y)
    local xMag = xVect / mVect
    local yMag = yVect / mVect
    local xImp = xMag * 50
    local yImp = yMag * 50
    player.xvel = player.xvel + xImp
    player.yvel = player.yvel + yImp

    if not player.hurt then
        player.hurt = true

        player.health = player.health - 1
        if player.health <= 0 then
            onPlayerDeath()
            return true
        end
    end

    return false
end

function onPlayerDeath()
    --player.active = false
    player.state = "dead"

    if highscore.score < world.score then
        highscore.score = world.score
        world.high_score_flag = true
        writeHighscore()
    end

    --worldStateChange("end")
    player.death_fadeout_timer = player.death_fadeout_cooldown
    love.audio.play(player.death_sound)
end

return player
