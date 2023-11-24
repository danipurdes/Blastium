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

    --world.game_timer = world.game_timer - dt
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
          --v.rotation = v.rotation + 2 * dt * enemy.rotation_influence
        end

        if v.x > world.width + 30 then
          v.x = -20
        elseif v.x < -30 then
          v.x = world.width + 20
        end

        if v.y > world.height + 30 then
          v.y = -20
        elseif v.y < -30 then
          v.y = world.height + 20
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

    for i,l in ipairs(lancers) do
        updateLancer(l, dt)
    end

    for i,s in ipairs(salvos) do
        updateSalvo(s, dt)
    end

    for i,a in ipairs(particles) do
        a.age = a.age + dt
        if a.age >= a.lifespan then
            a.removal_flag = true
        end
    end

    for i,l in ipairs(lancers) do
        if circle_overlap(player.x, player.y, player.radius, l.x, l.y, l.radius) then
            initiateScreenshake()
            love.audio.play(player.damage_sound)
            --l.removal_flag = true
            if onPlayerDamage(l.x, l.y) then
                return
            end
        end

        for i,b in ipairs(bullet_weapon.shots) do
            if circle_overlap(b.x, b.y, 4, l.x, l.y, l.radius) then
                b.removal_flag = true
                l.removal_flag = true
                world.score = world.score + lancer.score

                local p = {}
                p.x = (l.x + b.x) / 2
                p.y = (l.y + b.y) / 2
                p.age = 0
                p.lifespan = explosion_particle.lifespan
                p.image = explosion_particle.image
                table.insert(particles, p)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
            end
        end

        for i,s in ipairs(shell_weapon.shots) do
            if circle_overlap(s.x, s.y, 4, l.x, l.y, l.radius) then
                s.removal_flag = true
                l.removal_flag = true
                world.score = world.score + lancer.score

                local p = {}
                p.x = (l.x + s.x) / 2
                p.y = (l.y + s.y) / 2
                p.age = 0
                p.lifespan = explosion_particle.lifespan
                p.image = explosion_particle.image
                table.insert(particles, p)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
            end
        end
    end

    for i,l in ipairs(salvos) do
        if circle_overlap(player.x, player.y, player.radius, l.x, l.y, l.radius) then
            initiateScreenshake()
            love.audio.play(player.damage_sound)
            --l.removal_flag = true
            if onPlayerDamage(l.x, l.y) then
                return
            end
        end

        for i,b in ipairs(bullet_weapon.shots) do
            if circle_overlap(b.x, b.y, 4, l.x, l.y, l.radius) then
                b.removal_flag = true
                l.removal_flag = true
                world.score = world.score + salvo.score

                local p = {}
                p.x = (l.x + b.x) / 2
                p.y = (l.y + b.y) / 2
                p.age = 0
                p.lifespan = explosion_particle.lifespan
                p.image = explosion_particle.image
                table.insert(particles, p)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
            end
        end

        for i,s in ipairs(shell_weapon.shots) do
            if circle_overlap(s.x, s.y, 4, l.x, l.y, l.radius) then
                s.removal_flag = true
                l.removal_flag = true
                world.score = world.score + salvo.score

                local p = {}
                p.x = (l.x + s.x) / 2
                p.y = (l.y + s.y) / 2
                p.age = 0
                p.lifespan = explosion_particle.lifespan
                p.image = explosion_particle.image
                table.insert(particles, p)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
            end
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

        for i,b in ipairs(bullet_weapon.shots) do
            if circle_overlap(b.x, b.y, 4, m.x, m.y, m.radius) then
                b.removal_flag = true
                m.removal_flag = true
                world.score = world.score + m.score
            end
        end

        for i,s in ipairs(shell_weapon.shots) do
            if circle_overlap(s.x, s.y, 4, m.x, m.y, m.radius) then
                s.removal_flag = true
                m.removal_flag = true
                world.score = world.score + m.score
            end
        end
    end

    for i,a in ipairs(asteroids) do
      a.x = a.x + dt * a.speed * math.cos(a.rotation)
      a.y = a.y + dt * a.speed * math.sin(a.rotation)
      a.spin = a.spin + dt * a.spin_speed
      a.spin = a.spin % (2 * math.pi)

      if a.x > world.width + 40 then
        a.x = -30
      elseif a.x < -40 then
        a.x = world.width + 30
      end

      if a.y > world.height + 40 then
        a.y = -30
      elseif a.y < -40 then
        a.y = world.height + 30
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

    for i=#lancers, 1, -1 do
      if lancers[i].removal_flag then
          table.remove(lancers, i)
      end
    end

    for i=#salvos, 1, -1 do
      if salvos[i].removal_flag then
          table.remove(salvos, i)
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
    if key == "x" then
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

function drawPlayState(origin_x, origin_y)
    love.graphics.push()
    love.graphics.translate(screenshake.current_magnitude, 0)
    drawStarfield(origin_x, origin_y)

    love.graphics.setColor(255,255,255)

    for i=1,#enemies,1 do
      local v = enemies[i]
      love.graphics.draw(v.image, origin_x + v.x, origin_y + v.y, v.rotation, 2, 2, v.image:getWidth()/2, v.image:getHeight()/2)
    end

    for i,l in ipairs(lancers) do
        love.graphics.draw(l.draw_image, origin_x + l.x, origin_y + l.y, l.rotation, 2, 2, l.draw_image:getWidth()/2, l.draw_image:getWidth()/2)
    end

    for i,s in ipairs(salvos) do
        love.graphics.draw(s.draw_image, origin_x + s.x, origin_y + s.y, s.rotation, 2, 2, s.draw_image:getWidth()/2, s.draw_image:getWidth()/2)
    end

    for i,m in ipairs(salvo.missiles) do
        love.graphics.draw(salvo.missile_image, origin_x + m.x, origin_y + m.y, m.rotation, 1, 1, salvo.missile_image:getWidth()/2, salvo.missile_image:getHeight()/2)
    end

    for i,a in ipairs(asteroids) do
      love.graphics.draw(a.image, origin_x + a.x, origin_y + a.y, a.spin, 2, 2, a.image:getWidth()/2, a.image:getHeight()/2)
    end

    for i,p in ipairs(particles) do
        love.graphics.draw(p.image, origin_x + p.x, origin_y + p.y, 0, 2, 2, p.image:getWidth()/2, p.image:getHeight()/2)
    end

    love.graphics.setColor(255,255,255)
    drawShots(origin_x, origin_y)
    drawPlayer(origin_x, origin_y)

    if player.state == "dead" then
        love.graphics.setColor(100,100,100,100)
        love.graphics.rectangle("fill", origin_x, origin_y, world.width, world.height)
    end

    drawHUD(origin_x, origin_y)
    --love.graphics.setColor(255,255,255)
    --love.graphics.printf(world.game_timer, 10, world.height - 15, world.width)
    --love.graphics.printf(#lancers, 10, world.height - 35, world.width)
    --love.graphics.printf(spawner.enemy_total_count, 10, world.height - 55, world.width)
    --love.graphics.printf("fps " .. love.timer.getFPS(), 20, world.height - 40, world.width)

    love.graphics.pop()
end

return play_state
