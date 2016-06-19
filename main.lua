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
  score = 0
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
  firing_rate_total = .4,
  firing_rate_current = .4,
  sound = love.audio.newSource("assets/audio/shoot_bullet.wav","static")
}

shell_weapon = {
  name = "Flak Cannon",
  shots = {},
  ammo_max = 15,
  ammo_current = 15,
  firing_rate_total = 1.2,
  firing_rate_current = 1.2,
  sound = love.audio.newSource("assets/audio/shoot_shell.wav","static")
}

bullet_round = {
    velocity = 300,
    mass = 5,
    lifespan = 1.5,
    image = love.graphics.newImage("assets/images/bullet_twin.png")
}

shell_round = {
    velocity = 500,
    mass = 30,
    lifespan = .5,
    image = love.graphics.newImage("assets/images/shot.png")
}

local ROTATION_SPEED = 180
local ACCELERATION = 400
local DRAG = 100
local MAX_SPEED = 400

function love.update(dt)
  if world.state == "start" then
    --
  elseif world.state == "play" then
      vel_total = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel)
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


      bullet_weapon.firing_rate_current = bullet_weapon.firing_rate_current - dt
      shell_weapon.firing_rate_current = shell_weapon.firing_rate_current - dt

      bullet_weapon.firing_rate_current = math.max(0, bullet_weapon.firing_rate_current)
      shell_weapon.firing_rate_current = math.max(0, shell_weapon.firing_rate_current)

      --fire current weapon
      if love.keyboard.isDown("space") then
        if player.weapon_index == 0 then
          fire_bullet_weapon()
        elseif player.weapon_index == 1 then
          fire_shell_weapon()
        end
      end


      player.xvel = player.xvel - (player.xvel / DRAG)
      player.yvel = player.yvel - (player.yvel / DRAG)

      if vel_total > MAX_SPEED then
        player.xvel = player.xvel / vel_total * MAX_SPEED
        player.yvel = player.yvel / vel_total * MAX_SPEED
      end

      player.x = player.x + player.xvel*dt
      player.y = player.y + player.yvel*dt


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


      -- update the shots
      for i=#bullet_weapon.shots,1,-1 do
        -- move them up up up
        local v = bullet_weapon.shots[i]
        v.x = v.x + dt * math.cos(v.rotation) * v.tv
        v.y = v.y + dt * math.sin(v.rotation) * v.tv

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
        -- mark shots that are not visible for removal
        if v.lifespan <= 0 then
          table.remove(shell_weapon.shots, i)
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
  elseif world.state == "play" then
      if key == "q" then
        player.weapon_index = player.weapon_index + 1
        player.weapon_index = player.weapon_index % 2
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
      local start_text = "-PRESS SPACE TO PLAY-"
      love.graphics.setFont(world.title_font)
      love.graphics.printf(world.name, 0, world.height / 2 - 24, world.width, "center")
      love.graphics.setFont(world.text_font)
      love.graphics.printf(start_text, 0, world.height / 2 + 24, world.width, "center")
  elseif world.state == "play" then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(player.image, player.x, player.y, player.rotation, 1, 1, 16, 16)
      if player.x > world.width / 2 then
          love.graphics.draw(player.image, player.x - world.width, player.y, player.rotation, 1, 1, 16, 16)
      end
      if player.x < world.width / 2 then
          love.graphics.draw(player.image, player.x + world.width, player.y, player.rotation, 1, 1, 16, 16)
      end
      if player.y > world.height / 2 then
          love.graphics.draw(player.image, player.x, player.y - world.height, player.rotation, 1, 1, 16, 16)
      end
      if player.y < world.height / 2 then
          love.graphics.draw(player.image, player.x, player.y + world.height, player.rotation, 1, 1, 16, 16)
      end

      -- let's draw our heros shots
      for i,v in ipairs(bullet_weapon.shots) do
        love.graphics.draw(bullet_round.image, v.x, v.y, v.rotation)
      end

      for i,v in ipairs(shell_weapon.shots) do
        love.graphics.draw(shell_round.image, v.x, v.y, v.rotation)
      end

      local weapon_text = ""
      if player.weapon_index == 0 then
        weapon_text = weapon_text .. bullet_weapon.name .. "\n"
        --weapon_text = weapon_text .. "Active shots : " .. #bullet_weapon.shots .. "\n"
        weapon_text = weapon_text .. bullet_weapon.ammo_current .. "\n"
        --weapon_text = weapon_text .. "Time to reload : " .. bullet_weapon.firing_rate_current .. " / " .. bullet_weapon.firing_rate_total
        love.graphics.print(weapon_text, 10, 10)
      elseif player.weapon_index == 1 then
        weapon_text = weapon_text .. shell_weapon.name .. "\n"
        --weapon_text = weapon_text .. "Active shots : " .. #shell_weapon.shots .. "\n"
        weapon_text = weapon_text .. shell_weapon.ammo_current .. "\n"
        --weapon_text = weapon_text .. "Time to reload : " .. shell_weapon.firing_rate_current .. " / " .. shell_weapon.firing_rate_total
        love.graphics.print(weapon_text, 10, 10)
      end

      love.graphics.setFont(world.text_font)
      love.graphics.printf("Score : " .. world.score, 10, 10, world.width - 20, "right")


  elseif world.state == "end" then
      local end_text = "-GAME OVER-"
      local score_text = "Score : " .. world.score
      love.graphics.printf(end_text, 0, world.height / 2 - 10, world.width, "center")
      love.graphics.printf(score_text, 0, world.height / 2 + 10, world.width, "center")
  end
end

function fire_bullet_weapon()
    if bullet_weapon.ammo_current > 0 and bullet_weapon.firing_rate_current <= 0 then
        local times = bullet_weapon.firing_rate_current
        while times <= 0 and bullet_weapon.ammo_current > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + bullet_round.velocity

            player.xvel = player.xvel - bullet_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - bullet_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 14 * math.cos(player.rotation - 90)
            shot1.y = player.y + 14 * math.sin(player.rotation - 90)
            shot1.tv = tv
            shot1.rotation = player.rotation
            shot1.lifespan = bullet_round.lifespan
            table.insert(bullet_weapon.shots, shot1)

            local shot2 = {}
            shot2.x = player.x + 14 * math.cos(player.rotation + 90)
            shot2.y = player.y + 14 * math.sin(player.rotation + 90)
            shot2.tv = tv
            shot2.rotation = player.rotation
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
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + shell_round.velocity

            player.xvel = player.xvel - shell_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - shell_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x
            shot1.y = player.y
            shot1.tvel = tv
            shot1.rotation = player.rotation + 0 * math.pi / 180
            shot1.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot1)

            local shot2 = {}
            shot2.x = player.x
            shot2.y = player.y
            shot2.tvel = tv
            shot2.rotation = player.rotation - 4 * math.pi / 180
            shot2.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot2)

            local shot3 = {}
            shot3.x = player.x
            shot3.y = player.y
            shot3.tvel = tv
            shot3.rotation = player.rotation + 4 * math.pi / 180
            shot3.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot3)

            local shot4 = {}
            shot4.x = player.x
            shot4.y = player.y
            shot4.tvel = tv
            shot4.rotation = player.rotation - 8 * math.pi / 180
            shot4.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot4)

            local shot5 = {}
            shot5.x = player.x
            shot5.y = player.y
            shot5.tvel = tv
            shot5.rotation = player.rotation + 8 * math.pi / 180
            shot5.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot5)

            local shot6 = {}
            shot6.x = player.x
            shot6.y = player.y
            shot6.tvel = tv
            shot6.rotation = player.rotation - 12 * math.pi / 180
            shot6.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot6)

            local shot7 = {}
            shot7.x = player.x
            shot7.y = player.y
            shot7.tvel = tv
            shot7.rotation = player.rotation + 12 * math.pi / 180
            shot7.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot7)

            --shell_weapon.ammo_current = shell_weapon.ammo_current - 1
            times = times + shell_weapon.firing_rate_total
        end

        shell_weapon.firing_rate_current = times

        love.audio.play(shell_weapon.sound)
    end
end
