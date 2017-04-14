play_state = {}

function updatePlayState(dt)
    if player.state == "dead" then
        player.death_fadeout_timer = player.death_fadeout_timer - dt
        if player.death_fadeout_timer <= 0 then
            worldStateChange("end")
        end
        return
    end

    if player.active then
      playerMovement(dt)
    end

    world.game_timer = world.game_timer - dt
    if world.game_timer <= 0 then
      worldStateChange("end")
    end

    updateBulletWeapon(dt)
    updateShellWeapon(dt)

    updateScreenshake(dt)
    updateSpawner(dt)

    local enemyRotate = false
    enemy.rotation_timer = enemy.rotation_timer - dt
    if enemy.rotation_timer <= 0 then
      enemy.rotation_influence = enemy.rotation_influence * -1
      enemyRotate = true
      enemy.rotation_timer = enemy.rotation_cooldown
    end

    for i=1,#enemies,1 do
        local v = enemies[i]
        v.x = v.x + v.speed * dt * math.cos(v.rotation)
        v.y = v.y + v.speed * dt * math.sin(v.rotation)

        if enemyRotate then
          v.rotation_influence = -1 * v.rotation_influence
        end

        if v.mode == "rotate" then
          v.rotation = v.rotation + 2 * dt * enemy.rotation_influence
        end

        if v.x > world.width then
          v.x = v.x - world.width
        elseif v.x < 0 then
          v.x = v.x + world.width
        end

        if v.y > world.height then
          v.y = v.y - world.height
        elseif v.y < 0 then
          v.y = v.y + world.height
        end

        if circle_overlap(player.x, player.y, 16, v.x, v.y, v.radius) then
          initiateScreenshake()
          love.audio.play(player.damage_sound)
          if onPlayerDamage(v.x, v.y) then
              return
          end
        end

        if not v.removal_flag then
            for j=#bullet_weapon.shots,1,-1 do
              local s = bullet_weapon.shots[j]
              if circle_overlap(s.x, s.y, 4, v.x, v.y, v.radius) then
                v.removal_flag = true
                s.removal_flag = true
                world.score = world.score + enemy.score
                spawner.enemy_total_count = spawner.enemy_total_count - 1

                local p = {}
                p.x = (s.x + v.x) / 2
                p.y = (s.y + v.y) / 2
                p.age = 0
                p.lifespan = explosion_particle.lifespan
                p.image = explosion_particle.image
                table.insert(particles, p)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
              end
            end

            for j=#shell_weapon.shots,1,-1 do
              local s = shell_weapon.shots[j]
              if circle_overlap(s.x, s.y, 4, v.x, v.y, v.radius) then
                v.removal_flag = true
                s.removal_flag = true
                world.score = world.score + enemy.score
                spawner.enemy_total_count = spawner.enemy_total_count - 1

                local p = {}
                p.x = (s.x + v.x) / 2
                p.y = (s.y + v.y) / 2
                p.age = 0
                p.lifespan = explosion_particle.lifespan
                p.image = explosion_particle.image
                table.insert(particles, p)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
              end
            end
        end
    end

    updateLancer(dt)
    for i,s in ipairs(salvos) do
        updateSalvo(s, dt)
    end

    for i,a in ipairs(particles) do
        a.age = a.age + dt
        if a.age >= a.lifespan then
            a.removal_flag = true
        end
    end

    for i,m in ipairs(salvo.missiles) do
        if circle_overlap(player.x, player.y, 16, m.x, m.y, m.radius) then
          initiateScreenshake()
          love.audio.play(player.damage_sound)
          m.removal_flag = true
          if onPlayerDamage(m.x, m.y) then
              return
          end
        end
    end

    for i,a in ipairs(asteroids) do
      a.x = a.x + dt * a.speed * math.cos(a.rotation)
      a.y = a.y + dt * a.speed * math.sin(a.rotation)
      a.spin = a.spin + dt * a.spin_speed
      a.spin = a.spin % (2 * math.pi)

      if a.x > world.width then
        a.x = a.x - world.width
      elseif a.x < 0 then
        a.x = a.x + world.width
      end

      if a.y > world.height then
        a.y = a.y - world.height
      elseif a.y < 0 then
        a.y = a.y + world.height
      end

      if not a.removal_flag then
          for j=#bullet_weapon.shots,1,-1 do
            local s = bullet_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, a.x, a.y, a.radius) then
              a.removal_flag = true
              s.removal_flag = true
              if a.type == 32 then
                  spawnAsteroid16(a.x, a.y, a.rotation)
                  spawner.asteroid_count = spawner.asteroid_count - asteroid_32.size + 2 * asteroid_16.size
                  world.score = world.score + asteroid_32.score
              elseif a.type == 16 then
                  spawnAsteroids8(a.x, a.y, a.rotation)
                  spawner.asteroid_count = spawner.asteroid_count - asteroid_16.size + 2 * asteroid_8.size
                  world.score = world.score + asteroid_16.score
              elseif a.type == 8 then
                  world.score = world.score + asteroid_8.score
                  spawner.asteroid_count = spawner.asteroid_count - asteroid_8.size
              end
              initiateScreenshake()
              love.audio.play(enemy.damage_sound)
            end
          end

          for j=#shell_weapon.shots,1,-1 do
            local s = shell_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, a.x, a.y, a.radius) then
              a.removal_flag = true
              s.removal_flag = true
              if a.type == 32 then
                  spawnAsteroid16(a.x, a.y, a.rotation)
                  spawner.asteroid_count = spawner.asteroid_count - asteroid_32.size + 2 * asteroid_16.size
                  world.score = world.score + asteroid_32.score
              elseif a.type == 16 then
                  spawnAsteroids8(a.x, a.y, a.rotation)
                  spawner.asteroid_count = spawner.asteroid_count - asteroid_16.size + 2 * asteroid_8.size
                  world.score = world.score + asteroid_16.score
              elseif a.type == 8 then
                  world.score = world.score + asteroid_8.score
                  spawner.asteroid_count = spawner.asteroid_count - asteroid_8.size
              end
              initiateScreenshake()
              love.audio.play(enemy.damage_sound)
            end
          end

          if circle_overlap(player.x, player.y, 16, a.x, a.y, a.radius) then
            initiateScreenshake()
            love.audio.play(player.damage_sound)
            a.rotation = math.atan2(a.y, player.y, a.x, player.x)
            if onPlayerDamage(a.x, a.y) then
                return
            end
          end
      end
    end

    for i=#enemies, 1, -1 do
      if enemies[i].removal_flag then
          table.remove(enemies, i)
      end
    end

    for i=#salvo.missiles, 1, -1 do
      if salvo.missiles[i].removal_flag then
          table.remove(salvo.missiles, i)
      end
    end

    for i=#bullet_weapon.shots, 1, -1 do
      if bullet_weapon.shots[i].removal_flag then
          table.remove(bullet_weapon.shots, i)
      end
    end

    for i=#shell_weapon.shots, 1, -1 do
      if shell_weapon.shots[i].removal_flag then
          table.remove(shell_weapon.shots, i)
      end
    end

    for i=#asteroids, 1, -1 do
      if asteroids[i].removal_flag then
          table.remove(asteroids, i)
      end
    end

    for i=#particles, 1, -1 do
        if particles[i].removal_flag then
            table.remove(particles, i)
        end
    end
end

function keypressedPlayState(key)
    if key == "left" then
      fire_shell_weapon()
    end

    if key == "space" then
        world.game_timer = world.game_timer * .95
    end

    if key == "p" then
      worldStateChange("pause")
      menuIndexSelect()
    end
end

function drawPlayState()
    love.graphics.push()
    love.graphics.translate(screenshake.current_magnitude, 0)
    drawStarfield()

    love.graphics.setColor(255,255,255)

    for i=1,#enemies,1 do
      local v = enemies[i]
      love.graphics.draw(v.image, v.x, v.y, v.rotation, 2, 2, v.image:getWidth()/2, v.image:getHeight()/2)
    end

    love.graphics.draw(lancer.image, lancer.x, lancer.y, lancer.rotation, 2, 2, lancer.image:getWidth()/2, lancer.image:getWidth()/2)

    for i,s in ipairs(salvos) do
        love.graphics.draw(s.draw_image, s.x, s.y, s.rotation, 2, 2, s.image:getWidth()/2, s.image:getWidth()/2)
    end

    for i,m in ipairs(salvo.missiles) do
        love.graphics.draw(salvo.missile_image, m.x, m.y, m.rotation, 1, 1, salvo.missile_image:getWidth()/2, salvo.missile_image:getHeight()/2)
    end

    for i,a in ipairs(asteroids) do
      love.graphics.draw(a.image, a.x, a.y, a.spin, 2, 2, a.image:getWidth()/2, a.image:getHeight()/2)
    end

    for i,p in ipairs(particles) do
        love.graphics.draw(p.image, p.x, p.y, 0, 2, 2, p.image:getWidth()/2, p.image:getHeight()/2)
    end

    love.graphics.setColor(255,255,255)
    drawShots()
    drawPlayer()

    if player.state == "dead" then
        love.graphics.setColor(100,100,100,100)
        love.graphics.rectangle("fill", 0, 0, world.width, world.height)
    end

    drawHUD()
    love.graphics.setColor(255,255,255)
    love.graphics.printf(world.game_timer, 10, world.height - 15, world.width)
    love.graphics.printf(spawner.asteroid_count, 10, world.height - 35, world.width)
    love.graphics.printf(spawner.enemy_total_count, 10, world.height - 55, world.width)
    --love.graphics.printf("fps " .. love.timer.getFPS(), 20, world.height - 40, world.width)

    love.graphics.pop()
end

return play_state
