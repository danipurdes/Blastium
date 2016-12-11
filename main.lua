world = {
  name = "BLASTACULAR",
  width = 600,
  height = 600,
  title_font = love.graphics.newImageFont("assets/images/title_font.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    8),
  text_font = love.graphics.newImageFont("assets/images/example_font_inverted_monospace.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"",
    2),
  state = "start/open",
  previous_state = "start/open",
  score = 0,
  music = love.audio.newSource("assets/audio/Busy Signal - Beatwave.wav"),
  mute = false,
  audio = {
      volume_max = .5,
      volume_current = .5
  }
}

main_menu = {
    index = 0,
    size = 4,
    option_0 = "Play",
    option_1 = "Controls",
    option_2 = "Options",
    option_3 = "Quit Game",
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

starfield = {
    state = "initial",
    count = 128,
    stars = {},
    vel_multiplier = 1
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

player = {
  width = 16,
  height = 16,
  x = 150,
  y = 150,
  xvel = 0,
  yvel = 0,
  rotation = 0,
  ANGACCEL = 0,
  image = love.graphics.newImage("assets/images/ship_bosco.png"),
  weapon_index = 0
}

bullet_weapon = {
  name = "Blaster",
  shots = {},
  ammo_max = 25,
  ammo_current = 25,
  firing_rate_total = .3,
  firing_rate_current = .3,
  sound = love.audio.newSource("assets/audio/shoot_bullet.wav","static"),
  index = 0
}

shell_weapon = {
  name = "Moonshot",
  shots = {},
  ammo_max = 15,
  ammo_current = 15,
  firing_rate_total = 1.2,
  firing_rate_current = 1.2,
  sound = love.audio.newSource("assets/audio/shoot_shell.wav","static"),
  index = 1
}

bullet_round = {
    velocity = 300,
    mass = 5,
    lifespan = 2,
    damage = 1,
    image = love.graphics.newImage("assets/images/bullet_twin.png")
}

shell_round = {
    velocity = 500,
    mass = 30,
    lifespan = .16,
    damage = .34,
    image = love.graphics.newImage("assets/images/shot.png")
}

local ROTATION_SPEED = 180
local ACCELERATION = 400
local DRAG = 100
local MAX_SPEED = 400

function love.load()
  world.music:setLooping(true)
  world.music:setVolume(.25)
  love.audio.setVolume(world.audio.volume_max)
  world.audio.volume_current = world.audio.volume_max
  world.music:play()
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

        --title animation logic
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

        --starfield

        while #starfield.stars < starfield.count do
            local star = {}
            star.x = math.random(600)
            star.y = math.random(600)
            star.velocity = (math.random(10) + 1) * starfield.vel_multiplier
            star.radius = math.random(1.5)
            star.color_r = 200+math.random(55)
            star.color_g = 200+math.random(55)
            star.color_b = 200+math.random(55)
            table.insert(starfield.stars, star)
        end

        updateStarfield(dt)

  elseif world.state == "start/main" then
      --title animation logic
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

  elseif world.state == "play" then
      vel_total = math.sqrt(math.pow(player.xvel,2) + math.pow(player.yvel,2))

      if love.keyboard.isDown("d") then
        --player.ANGACCEL = ANGACCEL * dt / vel_total
        player.rotation = player.rotation + (vel_total/MAX_SPEED + 1) * (ROTATION_SPEED * math.pi / 180) * dt;
      elseif love.keyboard.isDown("a") then
        --player.ANGACCEL = -ANGACCEL * dt / vel_total
        player.rotation = player.rotation - (vel_total/MAX_SPEED + 1) * (ROTATION_SPEED * math.pi / 180) * dt;
      end

      --player.ANGACCEL = player.ANGACCEL * ANG_RESISTANCE
      --player.rotation = player.rotation + player.ROTATION_S * dt

      if love.keyboard.isDown("s") then
        -- decelerate / accelerate backwards
        player.xvel = player.xvel * .9
        player.yvel = player.yvel * .9
      end

      if love.keyboard.isDown("w") then
        -- accelerate
        player.xvel = player.xvel + ACCELERATION * dt * math.cos(player.rotation)
        player.yvel = player.yvel + ACCELERATION * dt * math.sin(player.rotation)
      end

      player.xvel = player.xvel - (player.xvel / DRAG)
      player.yvel = player.yvel - (player.yvel / DRAG)

      if vel_total > MAX_SPEED then
        player.xvel = player.xvel / vel_total * MAX_SPEED
        player.yvel = player.yvel / vel_total * MAX_SPEED
      end

      player.x = player.x + player.xvel * dt
      player.y = player.y + player.yvel * dt


      if player.x > world.width then
        player.x = player.x - world.width
      elseif player.x < 0 then
        player.x = player.x + world.width
      end

      if player.y > world.height then
        player.y = player.y - world.height
      elseif player.y < 0 then
        player.y = player.y + world.height
      end

      bullet_weapon.firing_rate_current = math.max(0, bullet_weapon.firing_rate_current - dt)
      shell_weapon.firing_rate_current = math.max(0, shell_weapon.firing_rate_current - dt)


      if love.keyboard.isDown(";") then
        fire_bullet_weapon()
      end

      -- update the shots
      for i=#bullet_weapon.shots,1,-1 do
        local v = bullet_weapon.shots[i]
        v.x = v.x + dt * math.cos(v.rotation) * v.tvel
        v.y = v.y + dt * math.sin(v.rotation) * v.tvel

        -- decrease lifespan
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

        -- decrease lifespan
        v.lifespan = v.lifespan - dt

        if v.lifespan <= 0 then
          table.remove(shell_weapon.shots, i)
        elseif v.x < -10 or v.x > world.width + 10 or v.y < -10 or v.y > world.height + 10 then
          table.remove(bullet_weapon.shots, i)
        end
      end

      updateStarfield(dt)

  elseif world.state == "end" then
    --
  end
end

function updateStarfield(dt)
    for i=1,#starfield.stars,1 do
        local v = starfield.stars[i]
        v.y = v.y + v.velocity*dt
        if v.y > 600 then
            v.y = -5
            v.x = math.random(600)
            v.velocity = (math.random(10) + 1) * starfield.vel_multiplier
            v.radius = math.random(3)
            v.color_r = 200+math.random(55)
            v.color_g = 200+math.random(55)
            v.color_b = 200+math.random(55)
        end
    end
end

function love.keypressed(key)

  if key == "m" then
    world.mute = not world.mute
    if world.mute then
        --world.music:setVolume(0)
        love.audio.setVolume(0)
        world.audio.volume_current = 0
    else
        --world.music:setVolume(.5)
        love.audio.setVolume(world.audio.volume_max)
        world.audio.volume_current = world.audio.volume_max
    end
  end

  if world.state == "start/open" then
      if key == "space" then
        if not logo_anim.done then
            logo_anim.t = logo_anim.lifespan
            logo_anim.done = true
            --world.state = "start/main"
            --world.previous_state = "start/open"
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
              world.state = "play"
              world.previous_state = "start/main"
          elseif main_menu.index == 1 then
              world.state = "controls"
              world.previous_state = "start/main"
          elseif main_menu.index == 2 then
              world.state = "options"
              world.previous_state = "start/main"
          elseif main_menu.index == 3 then
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
      end

  elseif world.state == "end" then
      if key == "space" then
        world.state = "start/main"
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
      --local pause_text = "- PAUSED -"
      --love.graphics.printf(main_text, 0, world.height / 2 - 40, world.width, "center")
      love.graphics.printf(main_menu.option_0, 0, world.height / 2, world.width, "center")
      love.graphics.printf(main_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
      love.graphics.printf(main_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
      love.graphics.printf(main_menu.option_3, 0, world.height / 2 + 60, world.width, "center")

      love.graphics.draw(main_menu.indicator_left, main_menu.ind_left_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)
      love.graphics.draw(main_menu.indicator_right, main_menu.ind_right_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)

  elseif world.state == "play" then
      drawStarfield()
      drawShots()
      drawPlayer()

      local weapon_text = ""

      weapon_text = bullet_weapon.name .. "\n"
      local hud_bullet_x = 10
      local hud_bullet_y = 10
      love.graphics.setColor(255,255,255)
      love.graphics.print(weapon_text, hud_bullet_x, hud_bullet_y)

      love.graphics.setColor(100,100,100)
      love.graphics.rectangle("fill",hud_bullet_x + 100,hud_bullet_y+5,100,10)

      local reload_width = (1 - bullet_weapon.firing_rate_current / bullet_weapon.firing_rate_total) * 100
      if reload_width > 99.99999 then
        love.graphics.setColor(50,250,250)
      else
        love.graphics.setColor(90,255,255)
      end

      love.graphics.rectangle("fill",hud_bullet_x + 100,hud_bullet_y+5,reload_width,10)

      weapon_text = shell_weapon.name .. "\n"
      local hud_shell_x = 10
      local hud_shell_y = 30
      love.graphics.setColor(255,255,255)
      love.graphics.print(weapon_text, hud_shell_x, hud_shell_y)

      love.graphics.setColor(100,100,100)
      love.graphics.rectangle("fill",hud_shell_x + 100, hud_shell_y+5,100,10)

      reload_width = (1 - shell_weapon.firing_rate_current / shell_weapon.firing_rate_total) * 100
      if reload_width > 99.99999 then
        love.graphics.setColor(250,50,50)
      else
        love.graphics.setColor(255,90,90)
      end

      love.graphics.rectangle("fill",hud_shell_x + 100,hud_shell_y+5,reload_width,10)

      love.graphics.setColor(255,255,255)
      love.graphics.setFont(world.text_font)
      love.graphics.printf("Score : " .. world.score, 10, 10, world.width - 20, "right")

  elseif world.state == "pause" then
      drawStarfield()
      drawShots()
      drawPlayer()

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
      --drawShots()
      --drawPlayer()

      love.graphics.setColor(100,100,100,100)
      love.graphics.rectangle("fill", 0, 0, world.width, world.height)

      love.graphics.setColor(255, 255, 255)
      love.graphics.printf("- Controls -", 0, world.height / 2 - 90, world.width, "center")
      love.graphics.printf("W - accelerate", world.width / 5, world.height / 2 - 50, world.width, "left")
      love.graphics.printf("A - turn left/counter-clockwise", world.width / 5, world.height / 2 - 30, world.width, "left")
      love.graphics.printf("D - turn right/clockwise", world.width / 5, world.height / 2 - 10, world.width, "left")
      love.graphics.printf("S - brake/decelerate", world.width / 5, world.height / 2 + 10, world.width, "left")
      love.graphics.printf("; - fire blaster", world.width / 5, world.height / 2 + 30, world.width, "left")
      love.graphics.printf("' - fire moonshot", world.width / 5, world.height / 2 + 50, world.width, "left")
      love.graphics.printf("P - pause game", world.width / 5, world.height / 2 + 70, world.width, "left")
      love.graphics.printf("M - mute", world.width / 5, world.height / 2 + 90, world.width, "left")

  elseif world.state == "end" then
      local end_text = "-GAME OVER-"
      local score_text = "Score : " .. world.score
      love.graphics.printf(end_text, 0, world.height / 2 - 10, world.width, "center")
      love.graphics.printf(score_text, 0, world.height / 2 + 10, world.width, "center")
  end
end

function drawPlayer()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(player.image, player.x, player.y, player.rotation, 1, 1, 16, 16)
    local px = player.x
    local py = player.y
    local hx = world.width/2
    local hy = world.height/2
    if ((hx-px)^2+(hy-py)^2)^0.5 > 250 then
        love.graphics.draw(player.image, player.x - world.width, player.y - world.height, player.rotation, 1, 1, 16, 16)
        love.graphics.draw(player.image, player.x - world.width, player.y, player.rotation, 1, 1, 16, 16)
        love.graphics.draw(player.image, player.x - world.width, player.y + world.height, player.rotation, 1, 1, 16, 16)

        love.graphics.draw(player.image, player.x, player.y - world.height, player.rotation, 1, 1, 16, 16)
        love.graphics.draw(player.image, player.x, player.y + world.height, player.rotation, 1, 1, 16, 16)

        love.graphics.draw(player.image, player.x + world.width, player.y - world.height, player.rotation, 1, 1, 16, 16)
        love.graphics.draw(player.image, player.x + world.width, player.y, player.rotation, 1, 1, 16, 16)
        love.graphics.draw(player.image, player.x + world.width, player.y + world.height, player.rotation, 1, 1, 16, 16)
    end
end

function drawShots()
    -- let's draw our heros shots
    for i,v in ipairs(bullet_weapon.shots) do
      love.graphics.draw(bullet_round.image, v.x, v.y, v.rotation)
    end

    for i,v in ipairs(shell_weapon.shots) do
      love.graphics.draw(shell_round.image, v.x, v.y, v.rotation)
    end
end

function drawStarfield()
    for i=1,#starfield.stars,1 do
        local v = starfield.stars[i]
        love.graphics.setColor(v.color_r, v.color_g, v.color_b);
        love.graphics.circle("fill",v.x,v.y,v.radius,6)
    end
end

function fire_bullet_weapon()
    if bullet_weapon.ammo_current > 0 and bullet_weapon.firing_rate_current <= 0 then
        local times = bullet_weapon.firing_rate_current
        while times <= 0 and bullet_weapon.ammo_current > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + bullet_round.velocity

            --player.xvel = player.xvel - bullet_round.mass * math.cos(player.rotation)
            --player.yvel = player.yvel - bullet_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 14 * math.cos(player.rotation - 90)
            shot1.y = player.y + 14 * math.sin(player.rotation - 90)
            shot1.tvel = tv
            shot1.rotation = player.rotation

            local txv = shell_round.velocity * math.cos(shot1.rotation) + math.abs(player.xvel) * math.cos(player.rotation)
            local tyv = shell_round.velocity * math.sin(shot1.rotation) + math.abs(player.yvel) * math.sin(player.rotation)
            shot1.tvel = math.sqrt(math.pow(txv,2) + math.pow(tyv,2))

            shot1.lifespan = bullet_round.lifespan
            table.insert(bullet_weapon.shots, shot1)

            local shot2 = {}
            shot2.x = player.x + 14 * math.cos(player.rotation + 90)
            shot2.y = player.y + 14 * math.sin(player.rotation + 90)
            shot2.rotation = player.rotation

            local txv = shell_round.velocity * math.cos(shot2.rotation) + math.abs(player.xvel) * math.cos(player.rotation)
            local tyv = shell_round.velocity * math.sin(shot2.rotation) + math.abs(player.yvel) * math.sin(player.rotation)
            shot2.tvel = math.sqrt(math.pow(txv,2) + math.pow(tyv,2))

            shot2.lifespan = bullet_round.lifespan
            table.insert(bullet_weapon.shots, shot2)

            --bullet_weapon.ammo_current = bullet_weapon.ammo_current - 1
            times = times + bullet_weapon.firing_rate_total
        end

        bullet_weapon.firing_rate_current = times

        love.audio.play(bullet_weapon.sound)
    end
end

function fire_shell_weapon()
    if shell_weapon.ammo_current > 0 and shell_weapon.firing_rate_current <= 0 then
        local times = shell_weapon.firing_rate_current
        while times <= 0 and shell_weapon.ammo_current > 0 do
            --player.xvel = player.xvel - shell_round.mass * math.cos(player.rotation)
            --player.yvel = player.yvel - shell_round.mass * math.sin(player.rotation)

            for i = 0, 9 do
                local shot = {}
                shot.x = player.x
                shot.y = player.y
                local spread = 200
                shot.rotation = player.rotation - spread/2 * (math.pi/180) + spread * (i/9) * (math.pi/180)

                local txv = shell_round.velocity * math.cos(shot.rotation) + math.abs(player.xvel) * math.cos(player.rotation)
                local tyv = shell_round.velocity * math.sin(shot.rotation) + math.abs(player.yvel) * math.sin(player.rotation)
                shot.tvel = math.sqrt(math.pow(txv,2) + math.pow(tyv,2))

                shot.lifespan = shell_round.lifespan
                --shell_weapon.shots[#shell_weapon.shots+1] = shot
                table.insert(shell_weapon.shots, shot)
            end

            --shell_weapon.shots[#shell_weapon.shots+1] = shot

            --shell_weapon.ammo_current = shell_weapon.ammo_current - 1
            times = times + shell_weapon.firing_rate_total
        end

        shell_weapon.firing_rate_current = times

        love.audio.play(shell_weapon.sound)
    end
end

function lerp(a, t, b, m)
    local value = math.abs(b - a) * (t / m) + math.min(a, b)
    return value
end
