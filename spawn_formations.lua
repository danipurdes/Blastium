spawn_formations = {
    sf_1 = {},
    sf_2 = {}
}

spawn_formations.sf_1.x = 300
spawn_formations.sf_1.y = 300
spawn_formations.sf_1.start_rotation = 0
spawn_formations.sf_1.start_magnitude = 100
spawn_formations.sf_1.count = 6
spawn_formations.sf_1.mode = "rotate"

spawn_formations.sf_2.x = 300
spawn_formations.sf_2.y = 0
spawn_formations.sf_2.start_rotation = 2*math.pi/3
spawn_formations.sf_2.start_magnitude = 0
spawn_formations.sf_2.count = 6
spawn_formations.sf_2.mode = "forward"

function enemySpawnFormation(id)
    local s1 = spawn_formations.sf_1
    local s2 = spawn_formations.sf_2

    if id == 1 then
        for i=1,s1.count,1 do
            local v = {}
            v.image = enemy.image
            local angle = 2 * math.pi * i/s1.count
            v.x = s1.x + s1.start_magnitude * math.cos(angle)
            v.y = s1.y + s1.start_magnitude * math.sin(angle)
            v.rotation = angle
            v.velX = enemy.velX
            v.velY = enemy.velY
            v.speed = enemy.speed
            v.rotation_influence = enemy.rotation_influence
            v.removal_flag = enemy.removal_flag
            v.mode = s1.mode
            table.insert(enemies, v)
        end
    end

    if id == 2 then
        for i=1,s2.count,1 do
            local v = {}
            v.image = enemy.image
            v.x = s2.x + 50 * (i - 1)
            v.y = s2.y
            v.rotation = s2.start_rotation
            v.velX = enemy.velX
            v.velY = enemy.velY
            v.speed = enemy.speed
            v.rotation_influence = enemy.rotation_influence
            v.removal_flag = enemy.removal_flag
            v.mode = s2.mode
            table.insert(enemies, v)
        end
    end
end

return spawn_formations
