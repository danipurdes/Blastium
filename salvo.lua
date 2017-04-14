salvo = {}

salvo.image = love.graphics.newImage("assets/images/enemy_salvo.png")
salvo.x = 150
salvo.y = 50
salvo.rotation = 0
salvo.radius = 8
salvo.speed = 60
salvo.removal_flag = false
salvo.score = 500
salvo.state = "recovering"
salvo.recover_speed = 60
salvo.recover_tgt_x = 200
salvo.recover_tgt_y = 200
salvo.load_age = 0
salvo.load_duration = 8
salvo.load_aim_speed = 1
salvo.load_speed = 0
salvo.firing_count = 0
salvo.firing_cap = 4
salvo.firing_age = 0
salvo.firing_duration = .5
salvo.firing_speed = -6

salvo.missiles = {}
salvo.missile_image = love.graphics.newImage("assets/images/salvo_missile.png")

function updateSalvo(sa, dt)
    if not (sa.state == "dead") then
        sa.x = sa.x + dt * sa.speed * math.cos(sa.rotation)
        sa.y = sa.y + dt * sa.speed * math.sin(sa.rotation)
        if sa.state == "recovering" then
            --sa.prep_age = sa.prep_age + dt
            sa.rotation = (sa.rotation + math.atan2(player.y - sa.y, player.x - sa.x))/2
            if distance(sa.x, sa.y, player.x, player.y) <= 300 then
                sa.state = "loading"
                sa.speed = sa.load_speed
                sa.prep_age = 0
            end
        elseif sa.state == "loading" then
            sa.rotation = (sa.rotation + math.atan2(player.y - sa.y, player.x - sa.x))/2
            sa.load_age = sa.load_age + dt
            if sa.load_age >= sa.load_duration then
                sa.state = "firing"
                sa.draw_image = sa.image_firing
                sa.load_age = 0
                sa.speed = sa.firing_speed
            end
        elseif sa.state == "firing" then
            sa.rotation = (sa.rotation + math.atan2(player.y - sa.y, player.x - sa.x))/2
            sa.firing_age = sa.firing_age + dt
            if sa.firing_age >= sa.firing_duration then
                sa.firing_age = 0
                if sa.firing_count >= sa.firing_cap then
                    sa.state = "recovering"
                    sa.speed = sa.recover_speed
                    sa.draw_image = sa.image
                    sa.firing_count = 0
                else
                    local m = {}
                    m.x = sa.x + 4 * sa.firing_count
                    m.y = sa.y
                    m.age = 0
                    m.speed = 50
                    m.radius = 8
                    m.rotation = sa.rotation
                    m.removal_flag = false
                    table.insert(salvo.missiles, m)
                    sa.firing_count = sa.firing_count + 1
                end
            end
        end
    end

    for i,m in ipairs(salvo.missiles) do
        m.x = m.x + dt * m.speed * math.cos(m.rotation)
        m.y = m.y + dt * m.speed * math.sin(m.rotation)
        m.age = m.age + dt
        m.speed = math.exp(1.75*(m.age+2))-100
        if m.x < 0 or m.x > world.width or m.y < 0 or m.y > world.height then
            m.removal_flag = true
        end
    end
end

function spawnSalvo(x, y)
    local s = {}
    s.image = love.graphics.newImage("assets/images/enemy_salvo.png")
    s.image_firing = love.graphics.newImage("assets/images/enemy_salvo_firing.png")
    s.draw_image = s.image
    s.x = x
    s.y = y
    s.rotation = 0
    s.radius = 8
    s.speed = 60
    s.removal_flag = false
    s.score = 500
    s.state = "recovering"
    s.recover_speed = 60
    s.recover_tgt_x = 200
    s.recover_tgt_y = 200
    s.load_age = 0
    s.load_duration = 8
    s.load_aim_speed = 1
    s.load_speed = 0
    s.firing_count = 0
    s.firing_cap = 4
    s.firing_age = 0
    s.firing_duration = .5
    s.firing_speed = -6
    table.insert(salvos, s)
end

return salvo
