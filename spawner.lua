spawner = {}

spawner.asteroid_spawn_timer = 5
spawner.asteroid_spawn_cooldown = 5
spawner.asteroid_count = 0

spawner.enemy_fleet_timer = 8
spawner.enemy_fleet_cooldown = 8

spawner.enemy_timer = .5
spawner.enemy_cooldown = .5

spawner.enemy_total_count = 0
spawner.enemy_total_cap = 15

spawner.enemy_count = 6
spawner.enemy_total = 6

spawner.fleet_mag = 0
spawner.fleet_side = 0
spawner.fleet_angle = 0

function loadSpawner()
    spawner.asteroid_spawn_timer = 5
    spawner.asteroid_count = 0

    spawner.enemy_fleet_timer = 8
    spawner.enemy_timer = .5
    spawner.enemy_count = 0
end

function updateSpawner(dt)
    spawner.asteroid_spawn_timer = spawner.asteroid_spawn_timer - dt

    if spawner.asteroid_spawn_timer <= 0 then
        if spawner.asteroid_count + asteroid_32.size <= 6 then
            spawnAsteroid32()
            spawner.asteroid_count = spawner.asteroid_count + asteroid_32.size
        end
        spawner.asteroid_spawn_timer = spawner.asteroid_spawn_cooldown
    end

    if spawner.enemy_count <= 0 then
        spawner.enemy_fleet_timer = spawner.enemy_fleet_timer - dt
        if spawner.enemy_fleet_timer <= 0 then
            spawner.fleet_mag = love.math.random(50,550)
            spawner.fleet_side = love.math.random(0,3)
            spawner.fleet_angle = love.math.random()
            spawner.enemy_count = spawner.enemy_total
            spawner.enemy_fleet_timer = spawner.enemy_fleet_cooldown
        end
    else
        spawner.enemy_timer = spawner.enemy_timer - dt
        if spawner.enemy_timer <= 0 then
            if spawner.enemy_total_count < spawner.enemy_total_cap then
                spawnEnemy(spawner.fleet_mag, spawner.fleet_side, spawner.fleet_angle)
                spawner.enemy_count = spawner.enemy_count - 1
                spawner.enemy_total_count = spawner.enemy_total_count + 1
            end
            spawner.enemy_timer = spawner.enemy_cooldown
        end
    end
end

function spawnEnemy(fMag, fSide, fAngle)
    local mag = fMag
    local side = fSide
    local x = 0
    local y = 0
    local ang = fAngle

    local e = {}
    e.x = x
    e.y = y
    e.speed = enemy.speed
    e.image = enemy.image
    e.radius = enemy.radius
    e.mode = "rotate"
    e.rotation_influence = 1
    e.removal_flag = false

    if side == 0 then
        x = mag
        y = -20
        ang = ang * math.pi / 2 + math.pi / 4
    elseif side == 1 then
        x = mag
        y = world.height + 20
        ang = ang * math.pi / 2 + 5 * math.pi / 4
    elseif side == 2 then
        x = -20
        y = mag
        ang = ang * math.pi / 2 + 3 * math.pi / 4
    elseif side == 3 then
        x = world.width + 20
        y = mag
        ang = ang * math.pi / 2 + 7 * math.pi / 4
    end

    e.rotation = ang
    table.insert(enemies, e)
end

function spawnAsteroid32()
    local side = 0 --love.math.random(0,3)
    local mag = love.math.random(50,550)
    local x = 0
    local y = 0
    local ang = love.math.random()

    local e = {}
    e.image = asteroid_32.image
    e.radius = asteroid_32.radius
    e.speed = 23
    e.spin = math.pi/8
    e.spin_speed = math.pi/16
    e.type = 32
    e.removal_flag = false

    if side == 0 then
        x = mag
        y = -20
        ang = ang * math.pi / 2 + math.pi / 4
    elseif side == 1 then
        x = mag
        y = world.height + 20
        ang = ang * math.pi / 2 + 5 * math.pi / 4
    elseif side == 2 then
        x = -20
        y = mag
        ang = ang * math.pi / 2 + 3 * math.pi / 4
    elseif side == 3 then
        x = world.width + 20
        y = mag
        ang = ang * math.pi / 2 + 7 * math.pi / 4
    end

    e.x = x
    e.y = y
    e.rotation = ang
    table.insert(asteroids, e)
end

function spawnAsteroid16(x, y, p_rot)
    for i=1,2 do
        local ast = {}
        ast.image = asteroid_16.image
        ast.x = x
        ast.y = y
        ast.rotation = p_rot + (math.pi / 2) + (i-1) * math.pi
        ast.speed = 45
        ast.radius = 16
        ast.spin = math.pi/8
        ast.spin_speed = math.pi/8
        ast.removal_flag = false
        ast.type = 16
        table.insert(asteroids, ast)
    end
end

function spawnAsteroids8(x, y, p_rot)
    for i=1,2 do
        local ast = {}
        ast.image = asteroid_8.image
        ast.x = x
        ast.y = y
        ast.rotation = p_rot + (math.pi / 2) + (i-1) * math.pi
        ast.speed = 120
        ast.radius = 8
        ast.spin = math.pi/8
        ast.spin_speed = math.pi/4
        ast.removal_flag = false
        ast.type = 8
        table.insert(asteroids, ast)
    end
end

return spawner
