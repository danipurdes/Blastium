world = require "world"
audio = require "audio"
player = require "player"
starfield = require "starfield"
hud = require "hud"

bullet_weapon = require "bullet_weapon"
shell_weapon = require "shell_weapon"
bullet_round = require "bullet_round"
shell_round = require "shell_round"

--menus
main_menu = require "main_menu"
controls_menu = require "controls_menu"
pause_menu = require "pause_menu"
credits_menu = require "credits_menu"

title_anim = {
    lifespan = 1.5,
    state0_color = 255,
    state1_color = 100,
    t = 0,
    direction = "f"
}

logo_anim = {
    lifespan = 4,
    start_y = -50,
    end_y = (600 / 2) - 64,
    t = 0,
    done = false
}

enemies = {}

enemy = {
    image = love.graphics.newImage("assets/images/enemy_ship.png"),
    x = 0,
    y = 0,
    rotation = 0,
    velX = 0,
    velY = 0,
    speed = 90,
    rotation_influence = 1,
    removal_flag = false
}

spawn_formation_1 = {
    x = 300,
    y = 300,
    start_rotation = 0,
    start_magnitude = 100,
    count = 6,
    mode = "rotate"
}

spawn_formation_2 = {
    x = 300,
    y = 0,
    start_rotation = 2*math.pi/3,
    start_magnitude = 0,
    count = 6,
    mode = "forward"
}

screenshake = {
    active = false,
    magnitude = 5,
    current_magnitude = 0,
    lifespan = 1,
    period = 0.01,
    age = 0
}

function love.load()
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
    player.active = true
    player.x = world.width / 2
    player.y = world.height / 2
    player.rotation = 3 * math.pi / 2
    player.xvel = 0
    player.yvel = 0
    world.score = 0

    --enemySpawnFormation(1)
    --enemySpawnFormation(2)

    screenshake.active = false
    screenshake.current_magnitude = 0
end

function enemySpawnFormation(id)
    if id == 1 then
        for i=1,spawn_formation_1.count,1 do
            local v = {}
            v.image = enemy.image
            local angle = 2 * math.pi * i/spawn_formation_1.count
            v.x = spawn_formation_1.x + spawn_formation_1.start_magnitude * math.cos(angle)
            v.y = spawn_formation_1.y + spawn_formation_1.start_magnitude * math.sin(angle)
            v.rotation = angle
            v.velX = enemy.velX
            v.velY = enemy.velY
            v.speed = enemy.speed
            v.rotation_influence = enemy.rotation_influence
            v.removal_flag = enemy.removal_flag
            v.mode = spawn_formation_1.mode
            table.insert(enemies, v)
        end
    end

    if id == 2 then
        for i=1,spawn_formation_2.count,1 do
            local v = {}
            v.image = enemy.image
            --local angle = 2 * math.pi * i/spawn_formation_1.count
            --v.x = spawn_formation_1.x + spawn_formation_1.start_magnitude * math.cos(angle)
            --v.y = spawn_formation_1.y + spawn_formation_1.start_magnitude * math.sin(angle)
            v.x = spawn_formation_2.x + 50 * (i - 1)
            v.y = spawn_formation_2.y
            v.rotation = spawn_formation_2.start_rotation
            v.velX = enemy.velX
            v.velY = enemy.velY
            v.speed = enemy.speed
            v.rotation_influence = enemy.rotation_influence
            v.removal_flag = enemy.removal_flag
            v.mode = spawn_formation_2.mode
            table.insert(enemies, v)
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

      for i=#bullet_weapon.shots,1,-1 do
        local v = bullet_weapon.shots[i]
        v.x = v.x + dt * math.cos(v.rotation) * v.tvel
        v.y = v.y + dt * math.sin(v.rotation) * v.tvel

        v.lifespan = v.lifespan - dt

        if v.lifespan <= 0 then
          table.remove(bullet_weapon.shots, i)
        elseif v.x < -10 or v.x > world.width + 10 or v.y < -10 or v.y > world.height + 10 then
          table.remove(bullet_weapon.shots, i)
        end
      end

      for i=#shell_weapon.shots,1,-1 do
        local v = shell_weapon.shots[i]
        v.x = v.x + dt * math.cos(v.rotation) * v.tvel
        v.y = v.y + dt * math.sin(v.rotation) * v.tvel

        v.lifespan = v.lifespan - dt

        if v.lifespan <= 0 then
          table.remove(shell_weapon.shots, i)
        elseif v.x < -10 or v.x > world.width + 10 or v.y < -10 or v.y > world.height + 10 then
          table.remove(bullet_weapon.shots, i)
        end
      end

      if screenshake.active then
        screenshake.age = screenshake.age + dt
        screenshake.current_magnitude = screenshake.magnitude * math.exp(-(screenshake.age*2)) * math.sin((1/screenshake.period) * math.pi * (screenshake.age/screenshake.lifespan))
        if screenshake.age > screenshake.lifespan then
            screenshake.active = false
            screenshake.age = 0
            screenshake.current_magnitude = 0
        end
      end

      for i=1,#enemies,1 do
          local v = enemies[i]
          v.x = v.x + v.speed * dt * math.cos(v.rotation)
          v.y = v.y + v.speed * dt * math.sin(v.rotation)
          if v.mode == "rotate" then
            v.rotation = v.rotation + 2 * dt * v.rotation_influence
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
            onPlayerDeath()
            break
          end

          for j=#bullet_weapon.shots,1,-1 do
            local s = bullet_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
              v.removal_flag = true
              s.removal_flag = true
              world.score = world.score + 1
            end
          end

          for j=#shell_weapon.shots,1,-1 do
            local s = shell_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
              v.removal_flag = true
              s.removal_flag = true
              world.score = world.score + 1
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

      updateStarfield(dt)

  elseif world.state == "controls" then
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
      end

      if starfield.state == "initial" then
          if key == "p" then
            for i=1,#starfield.stars,1 do
                starfield.stars[i].velocity = starfield.stars[i].velocity * 200
                starfield.state = "transition"
                starfield.vel_multiplier = 200
            end
          end
      elseif starfield.state == "transition" then
          if key == "p" then
            worldStateChange("play")
            world.score = 0
          end
      end

  elseif world.state == "start/main" then
      keypressedMainMenu(key)

  elseif world.state == "play" then
      if key == "q" then
        player.weapon_index = (player.weapon_index + 1) % 2
      end

      --reload
      if key == "r" then
        if player.weapon_index == 0 then
          bullet_weapon.ammo_current = bullet_weapon.ammo_max;
        elseif player.weapon_index == 1 then
          shell_weapon.ammo_current = shell_weapon.ammo_max;
        end
      end

      if key == "\'" then
        fire_shell_weapon()
      end

      if key == "j" then
        world.score = world.score + 1
      end

      if key == "l" then
        worldStateChange("end")
      end

      if key == "p" then
        worldStateChange("pause")
      end

      if key == "b" then
        screenshake.active = true
      end

      if key == "v" then
        for i = 1,#enemies,1 do
            local v = enemies[i]
            v.rotation_influence = v.rotation_influence * -1
        end
      end

      if key == "c" then
        player.active = not player.active
      end

  elseif world.state == "pause" then
    keypressedPauseMenu(key)

  elseif world.state == "controls" then
    keypressedControlsMenu(key)

  elseif world.state == "options" then
      if key == "space" then
        worldStateChange(world.previous_state)
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

function love.draw()
  love.graphics.clear(20,20,20)
  love.graphics.setColor(255, 255, 255)

  if world.state == "start/open" then
      drawStarfield()

      love.graphics.setColor(255, 255, 255)
      love.graphics.setFont(world.title_font)
      love.graphics.printf(world.name, 0, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), world.width, "center")
      love.graphics.setFont(world.text_font)

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

      for i=1,#enemies,1 do
        local v = enemies[i]
        love.graphics.draw(v.image, v.x, v.y, v.rotation, 2, 2, v.image:getWidth()/2, v.image:getHeight()/2)
      end

      love.graphics.setColor(255,0,0)

      drawShots()
      drawPlayer()
      drawHUD()
      love.graphics.printf(love.timer.getFPS(), 20, world.height - 40, world.width);
      love.graphics.pop()

  elseif world.state == "pause" then
      drawPauseMenu()

  elseif world.state == "controls" then
      drawControlsMenu()

  elseif world.state == "credits" then
      drawCreditsMenu()

  elseif world.state == "end" then
      drawStarfield()

      local end_text = "- GAME OVER -"
      local score_text = "SCORE : " .. world.score
      love.graphics.setFont(world.text_font)
      love.graphics.printf(end_text, 0, world.height / 2 - 10, world.width, "center")
      love.graphics.printf(score_text, 0, world.height / 2 + 10, world.width, "center")
  end
end

function drawShots()
    for i,v in ipairs(bullet_weapon.shots) do
      love.graphics.draw(bullet_round.image, v.x, v.y, v.rotation)
    end

    for i,v in ipairs(shell_weapon.shots) do
      love.graphics.draw(shell_round.image, v.x, v.y, v.rotation)
    end
end

function distance(x1, y1, x2, y2)
    local xdist = math.pow(x1-x2, 2)
    local ydist = math.pow(y1-y2, 2)
    local dist = math.sqrt(xdist + ydist)
    return dist
end

function circle_overlap(x1,y1,r1,x2,y2,r2)
    local rdist = r1 + r2
    local tdist = distance(x1, y1, x2, y2)
    --return tdist - rdist
    return tdist < rdist
end

function lerp(a, t, b, m)
    local value = math.abs(b - a) * (t / m) + math.min(a, b)
    return value
end
