spawner = {}

spawner.asteroid_spawn_timer = 17
spawner.asteroid_spawn_cooldown = 17
spawner.asteroid_count = 0

spawner.enemy_fleet_timer = 7
spawner.enemy_fleet_cooldown = 7

spawner.enemy_timer = .5
spawner.enemy_cooldown = .5

spawner.enemy_total_count = 0
spawner.enemy_total_cap = 12

spawner.enemy_count = 0
spawner.enemy_total = 3

spawner.fleet_mag = 300
spawner.fleet_side = 0
spawner.fleet_angle = 0

spawner.lancer_spawn_timer = 19
spawner.lancer_spawn_cooldown = 19
spawner.lancer_cap = 2

spawner.salvo_spawn_timer = 23
spawner.salvo_spawn_cooldown = 23
spawner.salvo_cap = 2

function loadSpawner()
    spawner.asteroid_spawn_timer = 5
    spawner.asteroid_count = 0

    spawner.enemy_fleet_timer = 8
    spawner.enemy_timer = .5
    spawner.enemy_count = 0

    spawner.enemy_total_count = 0

    spawner.lancer_spawn_timer = spawner.lancer_spawn_cooldown
    spawner.salvo_spawn_timer = spawner.salvo_spawn_cooldown
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

    spawner.lancer_spawn_timer = spawner.lancer_spawn_timer - dt
    if spawner.lancer_spawn_timer <= 0 then
        if #lancers < spawner.lancer_cap then
            local ang = math.pi * 2 * love.math.random()
            spawnLancer(world.width/2 + 440 * math.cos(ang), world.height/2 + 440 * math.sin(ang))
        end
        spawner.lancer_spawn_timer = spawner.lancer_spawn_cooldown
    end

    spawner.salvo_spawn_timer = spawner.salvo_spawn_timer - dt
    if spawner.salvo_spawn_timer <= 0 then
        if #salvos < spawner.salvo_cap then
            local ang = math.pi * 2 * love.math.random()
            spawnSalvo(world.width/2 + 440 * math.cos(ang), world.height/2 + 440 * math.sin(ang))
        end
        spawner.salvo_spawn_timer = spawner.salvo_spawn_cooldown
    end
end

function spawnEnemy(fMag, fSide, fAngle)
    local mag = fMag
    local side = fSide
    local ang = fAngle

    local e = {}
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

    e.x = x
    e.y = y
    e.rotation = ang
    table.insert(enemies, e)
end

function spawnAsteroid32()
    local side = love.math.random(0,3)
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
        y = -40
        ang = ang * math.pi / 2 + math.pi / 4
    elseif side == 1 then
        x = mag
        y = world.height + 40
        ang = ang * math.pi / 2 + 5 * math.pi / 4
    elseif side == 2 then
        x = -40
        y = mag
        ang = ang * math.pi / 2 + 3 * math.pi / 4
    elseif side == 3 then
        x = world.width + 40
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

function despawnEnemies()
    enemies = {}
end

function despawnLancers()
    lancers = {}
end

function despawnSalvos()
    salvos = {}
end

function despawnMissiles()
    salvo.missiles = {}
end

function despawnBullets()
    bullet_weapon.shots = {}
end

function despawnShells()
    shell_weapon.shots = {}
end

function despawnAsteroids()
    asteroids = {}
end

return spawner
