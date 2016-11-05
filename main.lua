world = {
  name = "BLASTIUM",
  width = 600,
  height = 600,
  title_font = love.graphics.newImageFont("assets/images/title_font.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    8),
  text_font = love.graphics.newImageFont("assets/images/example_font_inverted.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"",
    2),
  state = "start",
  score = 0,
  music = love.audio.newSource("assets/audio/Busy Signal - Beatwave.wav")
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
    lifespan = 1.5,
    damage = 1,
    image = love.graphics.newImage("assets/images/bullet_twin.png")
}

shell_round = {
    velocity = 500,
    mass = 30,
    lifespan = .25,
    damage = .34,
    image = love.graphics.newImage("assets/images/shot.png")
}

local ROTATION_SPEED = 180
local ACCELERATION = 400
local DRAG = 100
local MAX_SPEED = 400

function love.load()
  world.music:setLooping(true)
  world.music:setVolume(.5)
  world.music:play()
end

function love.update(dt)
  if world.state == "start" then
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
            star.radius = math.random(3)
            star.color_r = 200+math.random(55)
            star.color_g = 200+math.random(55)
            star.color_b = 200+math.random(55)
            table.insert(starfield.stars, star)
        end

        for i=1,#starfield.stars,1 do
            local v = starfield.stars[i]
            v.y = v.y + v.velocity*dt
            if v.y > 600 then
                v.y = -5
                v.x = math.random(600)
                v.velocity = (math.random(10) + 1) * starfield.vel_multiplier
                v.radius = math.random(3)
            end
        end

  elseif world.state == "play" then
      vel_total = math.sqrt(math.pow(player.xvel,2) + math.pow(player.yvel,2))

      if love.keyboard.isDown("d") then
        -- rotate clockwise
        --player.ANGACCEL = ANGACCEL * dt / vel_total
        player.rotation = player.rotation + (vel_total/MAX_SPEED + 1) * (ROTATION_SPEED * math.pi / 180) * dt;
      elseif love.keyboard.isDown("a") then
        -- rotate counter-clockwise
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

      if player.weapon_index == bullet_weapon.index then
        bullet_weapon.firing_rate_current = math.max(0, bullet_weapon.firing_rate_current - dt)
      end
      if player.weapon_index == shell_weapon.index then
        shell_weapon.firing_rate_current = math.max(0, shell_weapon.firing_rate_current - dt)
      end

      --fire current weapon
      if love.keyboard.isDown("space") then
        if player.weapon_index == bullet_weapon.index then
          fire_bullet_weapon()
        elseif player.weapon_index == shell_weapon.index then
          fire_shell_weapon()
        end
      end

      -- update the shots
      for i=#bullet_weapon.shots,1,-1 do
        -- move them up up up
        local v = bullet_weapon.shots[i]
        v.x = v.x + dt * math.cos(v.rotation) * v.tvel
        v.y = v.y + dt * math.sin(v.rotation) * v.tvel

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

        -- decrease lifespan
        v.lifespan = v.lifespan - dt
        -- mark shots that are not visible for removal
        if v.lifespan <= 0 then
          table.remove(bullet_weapon.shots, i)
        end
      end

      for i=#shell_weapon.shots,1,-1 do
        -- move them up up up
        local v = shell_weapon.shots[i]
        v.x = v.x + dt * math.cos(v.rotation) * v.tvel
        v.y = v.y + dt * math.sin(v.rotation) * v.tvel

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

        -- decrease lifespan
        v.lifespan = v.lifespan - dt

        if v.lifespan <= 0 then
          table.remove(shell_weapon.shots, i)
        end
      end

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
  elseif world.state == "end" then
    --
  end
end

function love.keypressed(key)
  if world.state == "start" then
      if key == "space" then
        world.state = "play"
        world.score = 0
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
            world.score = 0
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

      if key == "j" then
        world.score = world.score + 1
      end

      if key == "l" then
        world.state = "end"
      end

  elseif world.state == "end" then
      if key == "space" then
        world.state = "start"
      end
  end
end

function love.draw()
  love.graphics.clear(0,0,0)

  love.graphics.setColor(255, 255, 255)

  if world.state == "start" then
      for i=1,#starfield.stars,1 do
          local v = starfield.stars[i]
          love.graphics.setColor(v.color_r,v.color_g,v.color_b)
          love.graphics.rectangle("fill",v.x,v.y,v.radius,v.radius)
      end

      love.graphics.setColor(255, 255, 255);

      local start_text = "-PRESS SPACE TO PLAY-"
      love.graphics.setFont(world.title_font)
      local text_color = title_anim.state0_color + (title_anim.t - 0)*((title_anim.state1_color-title_anim.state0_color)/(title_anim.lifespan-0))

      love.graphics.printf(world.name, 0, world.height / 2 - 24, world.width, "center")
      love.graphics.setFont(world.text_font)
      love.graphics.setColor(text_color, text_color, text_color)
      love.graphics.printf(start_text, 0, world.height / 2 + 24, world.width, "center")

  elseif world.state == "play" then
      love.graphics.setColor(255, 255, 255)

      for i=1,#starfield.stars,1 do
          local v = starfield.stars[i]
          love.graphics.setColor(v.color_r, v.color_g, v.color_b);
          love.graphics.rectangle("fill",v.x,v.y,v.radius,v.radius)
      end

      love.graphics.setColor(255, 255, 255)

      drawShots()
      drawPlayer()

      local weapon_text = ""
      love.graphics.setColor(100,100,100)
      love.graphics.rectangle("fill",10,30,100,10)
      if player.weapon_index == 0 then
        weapon_text = weapon_text .. bullet_weapon.name .. "\n"
        love.graphics.setColor(255,255,255)
        love.graphics.print(weapon_text, 10, 10)
        local reload_width = (1 - bullet_weapon.firing_rate_current / bullet_weapon.firing_rate_total) * 100
        if reload_width > 99.99999 then
            love.graphics.setColor(70,250,250)
        end
        love.graphics.rectangle("fill",10,30,reload_width,10)
      elseif player.weapon_index == 1 then
        weapon_text = weapon_text .. shell_weapon.name .. "\n"
        love.graphics.setColor(255,255,255)
        love.graphics.print(weapon_text, 10, 10)
        local reload_width = (1 - shell_weapon.firing_rate_current / shell_weapon.firing_rate_total) * 100
        if reload_width > 99.99999 then
            love.graphics.setColor(70,250,250)
        end
        love.graphics.rectangle("fill",10,30,reload_width,10)
      end

      love.graphics.setColor(255,255,255)
      love.graphics.setFont(world.text_font)
      love.graphics.printf("Score : " .. world.score, 10, 10, world.width - 20, "right")


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
    if player.x > world.width * (.875) then
        love.graphics.draw(player.image, player.x - world.width, player.y, player.rotation, 1, 1, 16, 16)
    end
    if player.x < world.width / 8 then
        love.graphics.draw(player.image, player.x + world.width, player.y, player.rotation, 1, 1, 16, 16)
    end
    if player.y > world.height * (.875) then
        love.graphics.draw(player.image, player.x, player.y - world.height, player.rotation, 1, 1, 16, 16)
    end
    if player.y < world.height / 8 then
        love.graphics.draw(player.image, player.x, player.y + world.height, player.rotation, 1, 1, 16, 16)
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
