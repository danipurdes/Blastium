world = require "world"
audio = require "audio"
player = require "player"
starfield = require "starfield"

hud = require "hud"

bullet_weapon = require "bullet_weapon"
shell_weapon = require "shell_weapon"
bullet_round = require "bullet_round"
shell_round = require "shell_round"

main_menu = {
    index = 0,
    size = 5,
    option_0 = "Play",
    option_1 = "Controls",
    option_2 = "Options",
    option_3 = "Credits",
    option_4 = "Quit Game",
    indicator_left = love.graphics.newImage("assets/images/pause_indicator_left_new.png"),
    ind_left_x = 204,
    indicator_right = love.graphics.newImage("assets/images/pause_indicator_right_new.png"),
    ind_right_x = 381,
    ind_base_y = 300,
    ind_scale_y = 20
}

pause_menu = {
    index = 0,
    size = 4,
    option_0 = "Resume",
    option_1 = "Controls",
    option_2 = "Options",
    option_3 = "Quit to Menu",
    indicator_left = love.graphics.newImage("assets/images/pause_indicator_left_new.png"),
    ind_left_x = 204,
    indicator_right = love.graphics.newImage("assets/images/pause_indicator_right_new.png"),
    ind_right_x = 381,
    ind_base_y = 300,
    ind_scale_y = 20
}

credits = {
    love_logo = love.graphics.newImage("assets/images/love-logo-0.10-small-white.png")
}

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
    rotation_influence = 1
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
    player.x = world.width / 2
    player.y = world.height / 2
    world.score = 0

    for i=1,4,1 do
        local v = {}
        v.image = enemy.image
        v.x = enemy.x + 40 * i
        v.y = enemy.y
        v.rotation = enemy.rotation
        v.velX = enemy.velX
        v.velY = enemy.velY
        v.speed = enemy.speed
        v.rotation_influence = enemy.rotation_influence
        --table.insert(enemies, v)
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
          v.rotation = v.rotation + 2 * dt * v.rotation_influence

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
            player.active = false
          end

          for j=#bullet_weapon.shots,1,-1 do
            local s = bullet_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
              table.remove(enemies, i)
              table.remove(bullet_weapon.shots, j)
            end
          end

          for j=#shell_weapon.shots,1,-1 do
            local s = shell_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
              table.remove(enemies, i)
              table.remove(shell_weapon.shots, j)
            end
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
            world.state = "start/main"
            world.previous_state = "start/open"
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
            world.state = "play"
            world.previous_state = "start/main"
            world.score = 0
          end
      end

  elseif world.state == "start/main" then
      if key == "up" then
          main_menu.index = (main_menu.index - 1) % main_menu.size
      end

      if key == "down" then
          main_menu.index = (main_menu.index + 1) % main_menu.size
      end

      if key == "space" then
          if main_menu.index == 0 then
              loadGame()
              world.state = "play"
              world.previous_state = "start/main"
          elseif main_menu.index == 1 then
              world.state = "controls"
              world.previous_state = "start/main"
          elseif main_menu.index == 2 then
              world.state = "options"
              world.previous_state = "start/main"
          elseif main_menu.index == 3 then
              world.state = "credits"
              world.previous_state = "start/main"
          elseif main_menu.index == 4 then
              love.event.quit()
          end
      end

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
        world.state = "end"
        world.previous_state = "play"
      end

      if key == "p" then
        world.state = "pause"
        world.previous_state = "play"
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
    if key == "p" then
        world.state = "play"
        world.previous_state = "pause"
    end

    if key == "up" then
        pause_menu.index = (pause_menu.index - 1) % pause_menu.size
    end

    if key == "down" then
        pause_menu.index = (pause_menu.index + 1) % pause_menu.size
    end

    if key == "space" then
        if pause_menu.index == 0 then
            world.state = "play"
            world.previous_state = "pause"
        elseif pause_menu.index == 1 then
            world.state = "controls"
            world.previous_state = "pause"
        elseif pause_menu.index == 2 then
            world.state = "options"
            world.previous_state = "pause"
        elseif pause_menu.index == 3 then
            world.state = "start/main"
            world.previous_state = "pause"
        end
    end

  elseif world.state == "controls" then
      if key == "space" then
        world.state = world.previous_state
        world.previous_state = "controls"
      end

  elseif world.state == "options" then
      if key == "space" then
        world.state = world.previous_state
        world.previous_state = "options"
      end

  elseif world.state == "credits" then
    if key == "space" then
        world.state = world.previous_state
        world.previous_state = "credits"
    end

  elseif world.state == "end" then
      if key == "space" then
        world.state = "start/main"
        world.previous_state = "end"
      end
  end
end

function love.draw()
  love.graphics.clear(0,0,0)

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
      drawStarfield()

      love.graphics.setColor(255, 255, 255)
      love.graphics.setFont(world.title_font)
      love.graphics.printf(world.name, 0, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), world.width, "center")
      love.graphics.setFont(world.text_font)

      love.graphics.setColor(255, 255, 255);
      love.graphics.printf(main_menu.option_0, 0, world.height / 2, world.width, "center")
      love.graphics.printf(main_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
      love.graphics.printf(main_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
      love.graphics.printf(main_menu.option_3, 0, world.height / 2 + 60, world.width, "center")
      love.graphics.printf(main_menu.option_4, 0, world.height / 2 + 80, world.width, "center")

      love.graphics.draw(main_menu.indicator_left, main_menu.ind_left_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)
      love.graphics.draw(main_menu.indicator_right, main_menu.ind_right_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)

  elseif world.state == "play" then
      love.graphics.push()
      love.graphics.translate(screenshake.current_magnitude, 0)
      drawStarfield()

      for i=1,#enemies,1 do
        local v = enemies[i]
        love.graphics.draw(v.image, v.x, v.y, v.rotation, 2, 2, v.image:getWidth()/2, v.image:getHeight()/2)
      end

      love.graphics.setColor(255,0,0)
      --love.graphics.points(enemy.x, enemy.y)
      --love.graphics.line(enemy.x + 10 * math.cos(enemy.rotation), enemy.y + 10 * math.sin(enemy.rotation), enemy.x + 20 * math.cos(enemy.rotation), enemy.y + 20 * math.sin(enemy.rotation))

      drawShots()
      drawPlayer()
      drawHUD()
      love.graphics.pop()

  elseif world.state == "pause" then
      drawStarfield()
      drawShots()
      drawPlayer()
      drawHUD()

      love.graphics.setColor(100,100,100,100)
      love.graphics.rectangle("fill", 0, 0, world.width, world.height)

      love.graphics.setColor(255, 255, 255);
      local pause_text = "- PAUSED -"
      love.graphics.printf(pause_text, 0, world.height / 2 - 40, world.width, "center")
      love.graphics.printf(pause_menu.option_0, 0, world.height / 2, world.width, "center")
      love.graphics.printf(pause_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
      love.graphics.printf(pause_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
      love.graphics.printf(pause_menu.option_3, 0, world.height / 2 + 60, world.width, "center")

      love.graphics.draw(pause_menu.indicator_left, pause_menu.ind_left_x, pause_menu.ind_base_y + (pause_menu.ind_scale_y * pause_menu.index), 0)
      love.graphics.draw(pause_menu.indicator_right, pause_menu.ind_right_x, pause_menu.ind_base_y + (pause_menu.ind_scale_y * pause_menu.index), 0)

  elseif world.state == "controls" then
      drawStarfield()

      love.graphics.setColor(100,100,100,100)
      love.graphics.rectangle("fill", 0, 0, world.width, world.height)

      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle("fill", 50, 50, 500, 500)

      love.graphics.setColor(255, 255, 255)
      love.graphics.setFont(world.text_font)
      love.graphics.printf("- Controls -", 0, world.height / 2 - 90, world.width, "center")
      love.graphics.printf("W - accelerate", world.width / 5, world.height / 2 - 50, world.width, "left")
      love.graphics.printf("A - turn left/counter-clockwise", world.width / 5, world.height / 2 - 30, world.width, "left")
      love.graphics.printf("D - turn right/clockwise", world.width / 5, world.height / 2 - 10, world.width, "left")
      love.graphics.printf("S - brake/decelerate", world.width / 5, world.height / 2 + 10, world.width, "left")
      love.graphics.printf("; - fire blaster", world.width / 5, world.height / 2 + 30, world.width, "left")
      love.graphics.printf("' - fire moonshot", world.width / 5, world.height / 2 + 50, world.width, "left")
      love.graphics.printf("P - pause game", world.width / 5, world.height / 2 + 70, world.width, "left")
      love.graphics.printf("M - mute", world.width / 5, world.height / 2 + 90, world.width, "left")

  elseif world.state == "credits" then
      drawStarfield()

      love.graphics.setColor(100,100,100,100)
      love.graphics.rectangle("fill", 0, 0, world.width, world.height)

      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle("fill", 50, 50, 500, 500)

      love.graphics.setColor(255,255,255)
      love.graphics.setFont(world.title_font)
      love.graphics.printf(world.name, 0, 85, world.width, "center");
      love.graphics.setFont(world.text_font)
      love.graphics.printf("- DEVELOPER -", 0, 190, world.width, "center");
      love.graphics.printf("Daniel Purdes", 0, 210, world.width, "center");
      love.graphics.printf("- LOGO FONT -", 0, 250, world.width, "center");
      love.graphics.printf("Chris Early", 0, 270, world.width, "center");
      love.graphics.printf("Made with", 0, 420, world.width, "center")
      love.graphics.draw(credits.love_logo, world.width/2 - credits.love_logo:getWidth()/2, 440)

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
