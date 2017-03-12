love.graphics.setDefaultFilter("nearest", "nearest")

utilities = require "utilities"

world = require "world"
fonts = require "fonts"
audio = require "audio"
player = require "player"
starfield = require "starfield"
hud = require "hud"
screenshake = require "screenshake"
spawn_formations = require "spawn_formations"

--weapons
bullet_weapon = require "bullet_weapon"
shell_weapon = require "shell_weapon"
bullet_round = require "bullet_round"
shell_round = require "shell_round"

--menus
main_menu = require "main_menu"
controls_menu = require "controls_menu"
pause_menu = require "pause_menu"
options_menu = require "options_menu"
credits_menu = require "credits_menu"

title_anim = {
    lifespan = 1.5,
    state0_color = 255,
    state1_color = 100,
    t = 0,
    direction = "f"
}

logo_anim = {
    lifespan = 3,
    start_y = -50,
    end_y = 300 - 48,
    t = 0,
    done = false
}

spawner = {
    asteroid_spawn_timer = 5,
    asteroid_spawn_cooldown = 5,
    enemy_fleet_timer = 8,
    enemy_fleet_cooldown = 8,
    enemy_timer = .5,
    enemy_cooldown = .5,
    enemy_count = 6,
    enemy_total = 6,
    fleet_mag = 0,
    fleet_side = 0,
    fleet_angle = 0
}

coins = {}

coin = {
    x = 100,
    y = 100,
    radius = 5,
    removal_flag = false,
    pickup_sound = love.audio.newSource("assets/audio/coin_pickup.wav","static"),
    red = 200,
    green = 200,
    blue = 20
}

enemies = {}

enemy = {
    image = love.graphics.newImage("assets/images/enemy_ship.png"),
    damage_sound = love.audio.newSource("assets/audio/enemy_damage.wav","static"),
    x = 0,
    y = 0,
    rotation = 0,
    velX = 0,
    velY = 0,
    speed = 90,
    rotation_influence = 1,
    removal_flag = false,
    score = 200,
    rotation_timer = 1,
    rotation_cooldown = 1
}

asteroids = {}

asteroid_16 = {
    image = love.graphics.newImage("assets/images/asteroid_16.png"),
    x = 0,
    y = 0,
    rotation = 0,
    speed = 10,
    radius = 16,
    removal_flag = false,
    type = 16,
    score = 50
}

asteroid_8 = {
    image = love.graphics.newImage("assets/images/asteroid_8.png"),
    x = 0,
    y = 0,
    rotation = 0,
    speed = 10,
    radius = 8,
    removal_flag = false,
    type = 8,
    score = 100
}

shop = {
    x = 200,
    y = 200,
    radius = 10
}

function toMainMenu()
    main_menu.index = 0
end

function toPauseMenu()
    pause_menu.index = 0
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    audio.music:setLooping(true)
    audio.music:setVolume(.25)
    love.audio.setVolume(audio.volume_max)
    audio.volume_current = audio.volume_max
    audio.music:play()

    while #starfield.stars < starfield.count do
        local star = {}
        resetStar(star)
        star.y = math.random(600)
        table.insert(starfield.stars, star)
    end
end

function loadGame()
    despawnEnemies()
    despawnBullets()
    despawnShells()
    despawnCoins()
    despawnAsteroids()

    player.active = true
    player.x = world.width / 2
    player.y = world.height / 2
    player.rotation = 3 * math.pi / 2
    player.xvel = 0
    player.yvel = 0
    player.health = 5
    player.coins = 0
    player.hurt = false
    player.hurtTimer = 1
    player.hurtCooldown = 1
    world.score = 0
    world.high_score_flag = false

    spawner.asteroid_spawn_timer = 5
    spawner.enemy_fleet_timer = 8
    spawner.enemy_timer = .5
    spawner.enemy_count = 0

    --enemySpawnFormation(1)
    --enemySpawnFormation(2)


    --for i=1,12 do
    --    local c = {}
    --    c.x = coin.x + i*40
    --    c.y = coin.y + i*20
    --    c.radius = coin.radius
    --    c.removal_flag = false
    --    table.insert(coins, c)
    --end

    screenshake.active = false
    screenshake.current_magnitude = 0
end

function updateSpawner(dt)
    spawner.asteroid_spawn_timer = spawner.asteroid_spawn_timer - dt
    if spawner.asteroid_spawn_timer <= 0 then
        spawnAsteroid16()
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
            spawnEnemy(spawner.fleet_mag, spawner.fleet_side, spawner.fleet_angle)
            spawner.enemy_timer = spawner.enemy_cooldown
            spawner.enemy_count = spawner.enemy_count - 1
        end
    end
end

function love.update(dt)
  if world.state == "start/open" then
        if not logo_anim.done then
            logo_anim.t = logo_anim.t + dt
            if logo_anim.t >= logo_anim.lifespan then
                logo_anim.t = logo_anim.lifespan
                logo_anim.done = true
            end
        end

        if title_anim.direction == "f" then
            title_anim.t = math.min(title_anim.lifespan, title_anim.t + dt)
            if title_anim.t == title_anim.lifespan then
                title_anim.direction = "b"
            end
        elseif title_anim.direction == "b" then
            title_anim.t = math.max(0, title_anim.t - dt)
            if title_anim.t == 0 then
                title_anim.direction = "f"
            end
        end

        updateStarfield(dt)

  elseif world.state == "start/main" then
      updateStarfield(dt)

  elseif world.state == "play" then
      if player.active then
        playerMovement(dt)
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
                if a.type == 16 then
                    spawnAsteroids8(a.x, a.y)
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
                if a.type == 16 then
                    spawnAsteroids8(a.x, a.y)
                    world.score = world.score + asteroid_16.score
                elseif a.type == 8 then
                    world.score = world.score + asteroid_8.score
                end
                initiateScreenshake()
                love.audio.play(enemy.damage_sound)
              end
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

      --for i,c in ipairs(coins) do
        --if circle_overlap(player.x, player.y, 16, c.x, c.y, c.radius) then
        --    player.coins = player.coins + 1
        --    love.audio.play(coin.pickup_sound)
        --    c.removal_flag = true
        --end
      --end

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

      updateStarfield(dt)

  elseif world.state == "pause" then
    updatePauseMenu(dt)

  elseif world.state == "controls" then
    updateStarfield(dt)

  elseif world.state == "options" then
    updateStarfield(dt)

  elseif world.state == "credits" then
    updateStarfield(dt)

  elseif world.state == "end" then
    updateStarfield(dt)
  end
end

function love.keypressed(key)
  if key == "m" then
    toggleMute()
  end

  if world.state == "start/open" then
      if key == "space" then
        if not logo_anim.done then
            logo_anim.t = logo_anim.lifespan
            logo_anim.done = true
        else
            worldStateChange("start/main")
        end

        menuIndexSelect()
      end

      --if starfield.state == "initial" then
          --if key == "p" then
            --for i=1,#starfield.stars,1 do
            --    starfield.stars[i].velocity = starfield.stars[i].velocity * 200
            --    starfield.state = "transition"
            --    starfield.vel_multiplier = 200
            --end
          --end
      --elseif starfield.state == "transition" then
          --if key == "p" then
            --worldStateChange("play")
            --world.score = 0
          --end
      --end

  elseif world.state == "start/main" then
      keypressedMainMenu(key)

  elseif world.state == "play" then
      if key == "q" then
        player.weapon_index = (player.weapon_index + 1) % 2
      end

      --reload
      if key == "r" then
        if player.weapon_index == 0 then
          bullet_weapon.ammo_current = bullet_weapon.ammo_max
        elseif player.weapon_index == 1 then
          shell_weapon.ammo_current = shell_weapon.ammo_max
        end
      end

      if key == "l" then
        fire_shell_weapon()
      end

      if key == "p" then
        worldStateChange("pause")
        menuIndexSelect()
      end

      --if key == "v" then
        --for i = 1,#enemies,1 do
        --    local v = enemies[i]
        --    v.rotation_influence = v.rotation_influence * -1
        --end
      --end

      --if circle_overlap(player.x, player.y, 16, shop.x, shop.y, shop.radius) then
          --if key == "x" then
            --if player.coins >= 3 then
            --    player.health = player.health + 1
            --    player.coins = player.coins - 3
            --end
          --end

          --if key == "n" then
            --if player.coins >= 5 then
            --    shell_weapon.firing_rate_total = shell_weapon.firing_rate_total * .6
            --    player.coins = player.coins - 5
            --end
          --end

          --if key == "m" then
            --if player.coins >= 5 then
            --    bullet_weapon.firing_rate_total = bullet_weapon.firing_rate_total * .6
            --    player.coins = player.coins - 5
            --end
          --end
      --end

  elseif world.state == "pause" then
    keypressedPauseMenu(key)

  elseif world.state == "controls" then
    keypressedControlsMenu(key)

  elseif world.state == "options" then
      if key == "escape" then
        worldStateChange(world.previous_state)
      end

      if key == "down" then
        options_menu.index = (options_menu.index + 1) % options_menu.count
      end

      if key == "up" then
        options_menu.index = (options_menu.index + 1) % options_menu.count
      end

      if key == "right" then
        if options_menu.index == 1 then
          options_menu.option_1_value = options_menu.option_1_value + .1
          if options_menu.option_1_value > 1 then
            options_menu.option_1_value = 1
          end
        else
          options_menu.option_2_value = options_menu.option_2_value + .1
          if options_menu.option_2_value > 1 then
            options_menu.option_2_value = 1
          end
        end
      end

      if key == "left" then
        if options_menu.index == 1 then
          options_menu.option_1_value = options_menu.option_1_value - .1
          if options_menu.option_1_value < 0 then
            options_menu.option_1_value = 0
          end
        else
          options_menu.option_2_value = options_menu.option_2_value - .1
          if options_menu.option_2_value < 0 then
            options_menu.option_2_value = 0
          end
        end
      end

  elseif world.state == "credits" then
    keypressedCreditsMenu(key)

  elseif world.state == "end" then
      if key == "space" then
        worldStateChange("start/main")
      end
  end
end

function despawnEnemies()
    enemies = {}
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

function despawnCoins()
    coins = {}
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

function spawnAsteroid16()
    local side = love.math.random(0,3)
    local mag = love.math.random(50,550)
    local x = 0
    local y = 0
    local ang = love.math.random()

    local e = {}
    e.image = asteroid_16.image
    e.radius = asteroid_16.radius
    e.speed = 45
    e.spin = math.pi/8
    e.spin_speed = math.pi/8
    e.type = 16
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

function spawnAsteroids8(x, y)
    for i=1,2 do
        local ast = {}
        ast.image = asteroid_8.image
        ast.x = x
        ast.y = y
        ast.rotation = i * math.pi
        ast.speed = 120
        ast.radius = 8
        ast.spin = math.pi/8
        ast.spin_speed = math.pi/4
        ast.removal_flag = false
        ast.type = 8
        table.insert(asteroids, ast)
    end
end

function love.draw()
  love.graphics.clear(20,20,20)
  love.graphics.setColor(255, 255, 255)

  if world.state == "start/open" then
      drawStarfield()

      love.graphics.setColor(255, 255, 255)
      --love.graphics.setFont(fonts.title_font)
      --love.graphics.printf(world.name, 0, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), world.width, "center")
      love.graphics.draw(world.logo, 300, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), 0, 4, 4, world.logo:getWidth()/2, world.logo:getHeight()/2)
      love.graphics.setFont(fonts.font_text)

      if logo_anim.done then
          local start_text = "- PRESS SPACE TO PLAY -"
          local text_color = lerp(title_anim.state0_color, title_anim.t, title_anim.state1_color, title_anim.lifespan)
          love.graphics.setColor(text_color, text_color, text_color)
          love.graphics.printf(start_text, 0, main_menu.ind_base_y, world.width, "center")
      end

  elseif world.state == "start/main" then
      drawMainMenu()

  elseif world.state == "play" then
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
      --love.graphics.printf("fps " .. love.timer.getFPS(), 20, world.height - 40, world.width);
      love.graphics.pop()

  elseif world.state == "pause" then
      drawPauseMenu()

  elseif world.state == "controls" then
      drawControlsMenu()

  elseif world.state == "options" then
      drawStarfield()
      love.graphics.setFont(fonts.text_font)
      love.graphics.setColor(255,255,255)
      love.graphics.printf(options_menu.option_1_title, 40, world.height / 2 - 50, world.width - 40, "left")
      love.graphics.rectangle("fill", 40, world.height / 2 - 20, 104, 4)
      love.graphics.rectangle("fill", 40 + options_menu.option_1_value * 100, world.height / 2 - 28, 4, 16)
      love.graphics.printf(options_menu.option_2_title, 40, world.height / 2 + 10, world.width - 40, "left")
      love.graphics.rectangle("fill", 40, world.height / 2 + 40, 104, 4)
      love.graphics.rectangle("fill", 40 + options_menu.option_2_value * 100, world.height / 2 + 32, 4, 16)

  elseif world.state == "credits" then
      drawCreditsMenu()

  elseif world.state == "end" then
      drawStarfield()

      love.graphics.setColor(255,255,255)

      local end_text = ""
      if world.high_score_flag then
        end_text = "- NEW HIGH SCORE -"
      else
        end_text = "- GAME OVER -"
      end

      local score_text = "SCORE : " .. world.score
      local high_score_text = "HIGH SCORE : " .. world.high_score
      love.graphics.setFont(fonts.font_text)
      love.graphics.printf(end_text, 0, world.height / 2 - 20, world.width, "center")
      love.graphics.printf(score_text, 0, world.height / 2 , world.width, "center")
      love.graphics.printf(high_score_text, 0, world.height / 2 + 20, world.width, "center");
  end
end

function drawShots()
    drawBulletRounds()
    drawShellRounds()
end
