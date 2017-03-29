play_state = {}

function updatePlayState(dt)
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

        if circle_overlap(player.x, player.y, 16, v.x, v.y, 16) then
          initiateScreenshake()
          love.audio.play(player.damage_sound)
          if onPlayerDamage(v.x, v.y) then
              return
          end
        end

        if not v.removal_flag then
            for j=#bullet_weapon.shots,1,-1 do
              local s = bullet_weapon.shots[j]
              if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
                v.removal_flag = true
                s.removal_flag = true
                world.score = world.score + enemy.score

                --enemy drops a coin
                --local co = {}
                --co.x = v.x
                --co.y = v.y
                --co.radius = coin.radius
                --co.removal_flag = false
                --table.insert(coins, co)

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
              end
            end

            for j=#shell_weapon.shots,1,-1 do
              local s = shell_weapon.shots[j]
              if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
                v.removal_flag = true
                s.removal_flag = true
                world.score = world.score + enemy.score

                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
              end
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
                  world.score = world.score + asteroid_32.score
              elseif a.type == 16 then
                  spawnAsteroids8(a.x, a.y, a.rotation)
                  world.score = world.score + asteroid_16.score
              elseif a.type == 8 then
                  world.score = world.score + asteroid_8.score
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
                  world.score = world.score + asteroid_32.score
              elseif a.type == 16 then
                  spawnAsteroids8(a.x, a.y, a.rotation)
                  world.score = world.score + asteroid_16.score
              elseif a.type == 8 then
                  world.score = world.score + asteroid_8.score
              end
              initiateScreenshake()
              love.audio.play(enemy.damage_sound)
            end
          end

          if circle_overlap(player.x, player.y, 16, a.x, a.y, a.radius) then
            initiateScreenshake()
            love.audio.play(player.damage_sound)
            local xVect = player.x - a.x
            local yVect = player.y - a.y
            local mVect = distance(player.x, player.y, a.x, a.y)
            local xMag = xVect / mVect
            local yMag = yVect / mVect
            local xImp = xMag * 50
            local yImp = yMag * 50
            local axv = a.speed * math.cos(a.rotation)
            local ayv = a.speed * math.sin(a.rotation)
            axv = axv - xImp
            ayv = ayv - yImp
            --a.speed = math.sqrt(axv*axv + ayv*ayv)
            a.rotation = math.atan2(axv, ayv)
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

    --for i=#coins, 1, -1 do
      --if coins[i].removal_flag then
          --table.remove(coins, i)
      --end
    --end
end

function keypressedPlayState(key)
    if key == "l" then
      fire_shell_weapon()
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

    for i,a in ipairs(asteroids) do
      love.graphics.draw(a.image, a.x, a.y, a.spin, 2, 2, a.image:getWidth()/2, a.image:getHeight()/2)
    end

    --love.graphics.setColor(coin.red, coin.green, coin.blue)
    --for i,c in ipairs(coins) do
      --love.graphics.ellipse("fill", c.x, c.y, c.radius, c.radius)
    --end

    --love.graphics.setColor(200,200,200)
    --love.graphics.ellipse("fill", shop.x, shop.y, shop.radius, shop.radius)

    love.graphics.setColor(255,255,255)
    drawShots()
    drawPlayer()
    drawHUD()
    love.graphics.setColor(255,255,255)
    love.graphics.printf(world.game_timer, 10, world.height - 15, world.width)
    --love.graphics.printf("fps " .. love.timer.getFPS(), 20, world.height - 40, world.width)
    love.graphics.pop()
end

return play_state
