world = {
  name = "Space Game",
  canvas = love.graphics.newCanvas(500,500),
  offset_x = 25,
  offset_y = 75,
  width = 500,
  height = 500,
  font = love.graphics.newImageFont("assets/example_font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\""),
  state = "start"
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
  image = love.graphics.newImage("assets/ship_bosco.png"),
  weapon_index = 0,
}

bullet_weapon = {
  name = "Blaster",
  shots = {},
  ammo_max = 25,
  ammo_current = 25,
  firing_rate_total = .4,
  firing_rate_current = .4
}

flame_weapon = {
  name = "Flamethrower",
  shots = {},
  ammo_max = 400,
  ammo_current = 400,
  firing_rate_total = .025,
  firing_rate_current = .025
}

shell_weapon = {
  name = "Flak Cannon",
  shots = {},
  ammo_max = 15,
  ammo_current = 15,
  firing_rate_total = .8,
  firing_rate_current = .8
}

bullet_round = {
    velocity = 300,
    mass = 5,
    lifespan = 1.5,
    image = love.graphics.newImage("assets/bullet.png")
}

flame_round = {
    velocity = 400,
    mass = 1,
    lifespan = .25,
    image = love.graphics.newImage("assets/flame.png")
}

shell_round = {
    velocity = 500,
    mass = 30,
    lifespan = .5,
    image = love.graphics.newImage("assets/shell.png")
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
      flame_weapon.firing_rate_current = flame_weapon.firing_rate_current - dt
      shell_weapon.firing_rate_current = shell_weapon.firing_rate_current - dt

      bullet_weapon.firing_rate_current = math.max(0, bullet_weapon.firing_rate_current)


      if flame_weapon.firing_rate_current <= 0 then
        flame_weapon.firing_rate_current = 0
      end

      if shell_weapon.firing_rate_current <= 0 then
        shell_weapon.firing_rate_current = 0
      end

      --fire current weapon
      if love.keyboard.isDown("space") then
        if player.weapon_index == 0 then
          fire_bullet_weapon()
        elseif player.weapon_index == 1 then
          fire_flame_weapon()
        elseif player.weapon_index == 2 then
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

      for i=#flame_weapon.shots,1,-1 do
        -- move them up up up
        local v = flame_weapon.shots[i]
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
          table.remove(flame_weapon.shots, i)
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
      end
  elseif world.state == "play" then
      if key == "q" then
        player.weapon_index = player.weapon_index + 1
        player.weapon_index = player.weapon_index % 3
      end

      --reload
      if key == "r" then
        if player.weapon_index == 0 then
          bullet_weapon.ammo_current = bullet_weapon.ammo_max;
        elseif player.weapon_index == 1 then
          flame_weapon.ammo_current = flame_weapon.ammo_max;
        elseif player.weapon_index == 2 then
          shell_weapon.ammo_current = shell_weapon.ammo_max;
        end
      end

      if key == "h" then
        world.offset_x = world.offset_x + 1
      end
      if key == "n" then
        world.offset_x = world.offset_x - 1
      end
      if key == "j" then
        world.offset_y = world.offset_y + 1
      end
      if key == "m" then
        world.offset_y = world.offset_y - 1
      end
  elseif world.state == "end" then
      if key == "space" then
        world.state = "start"
      end
  end
end

function draw()
    --love.graphics.setFont(world.font)
    love.graphics.setColor(255, 255, 255)

    if world.state == "start" then
      local start_text = "-PRESS START TO PLAY-"
      love.graphics.printf(start_text, 0, world.height / 2, world.width, "center")
    elseif world.state == "play" then
        local weapon_text = ""
        if player.weapon_index == 0 then
          weapon_text = weapon_text .. "Weapon : " .. bullet_weapon.name .. " [" .. player.weapon_index .. "]" .. "\n"
          weapon_text = weapon_text .. "Active shots : " .. #bullet_weapon.shots .. "\n"
          weapon_text = weapon_text .. "Ammo : " .. bullet_weapon.ammo_current .. "\n"
          weapon_text = weapon_text .. "Time to reload : " .. bullet_weapon.firing_rate_current .. " / " .. bullet_weapon.firing_rate_total
          love.graphics.print(weapon_text, 10, 10)
        elseif player.weapon_index == 1 then
          weapon_text = weapon_text .. "Weapon : " .. flame_weapon.name .. " [" .. player.weapon_index .. "]" .. "\n"
          weapon_text = weapon_text .. "Active shots : " .. #flame_weapon.shots .. "\n"
          weapon_text = weapon_text .. "Ammo : " .. flame_weapon.ammo_current .. "\n"
          weapon_text = weapon_text .. "Time to reload : " .. flame_weapon.firing_rate_current .. " / " .. flame_weapon.firing_rate_total
          love.graphics.print(weapon_text, 10, 10)
        elseif player.weapon_index == 2 then
          weapon_text = weapon_text .. "Weapon : " .. shell_weapon.name .. " [" .. player.weapon_index .. "]" .. "\n"
          weapon_text = weapon_text .. "Active shots : " .. #shell_weapon.shots .. "\n"
          weapon_text = weapon_text .. "Ammo : " .. shell_weapon.ammo_current .. "\n"
          weapon_text = weapon_text .. "Time to reload : " .. shell_weapon.firing_rate_current .. " / " .. shell_weapon.firing_rate_total
          love.graphics.print(weapon_text, 10, 10)
        end

        love.graphics.draw(player.image, player.x, player.y, player.rotation, 1, 1, 8, 8)
        if player.x > world.width / 2 then
            love.graphics.draw(player.image, player.x - world.width, player.y, player.rotation, 1, 1, 8, 8)
        end
        if player.x < world.width / 2 then
            love.graphics.draw(player.image, player.x + world.width, player.y, player.rotation, 1, 1, 8, 8)
        end
        if player.y > world.height / 2 then
            love.graphics.draw(player.image, player.x, player.y - world.height, player.rotation, 1, 1, 8, 8)
        end
        if player.y < world.height / 2 then
            love.graphics.draw(player.image, player.x, player.y + world.height, player.rotation, 1, 1, 8, 8)
        end

        -- let's draw our heros shots
        for i,v in ipairs(bullet_weapon.shots) do
          love.graphics.draw(bullet_round.image, v.x, v.y, v.rotation)
        end

        for i,v in ipairs(flame_weapon.shots) do
          love.graphics.draw(flame_round.image, v.x, v.y, v.rotation)
        end

        for i,v in ipairs(shell_weapon.shots) do
          love.graphics.draw(shell_round.image, v.x, v.y, v.rotation)
        end
    elseif world.state == "end" then
        --
    end
end

function love.draw()
  love.graphics.clear()

  --game canvas
  love.graphics.setCanvas(world.canvas)
  love.graphics.clear()
  world.canvas:renderTo(draw)

  --entire window
  love.graphics.setCanvas()

  love.graphics.draw(world.canvas, world.offset_x, world.offset_y)

  love.graphics.setFont(world.font)
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(world.name, 0, world.offset_y/2, love.graphics:getWidth(), "center")

  love.graphics.setColor(100, 255, 100)
  love.graphics.setLineWidth(1)
  love.graphics.line(world.offset_x - 1, world.offset_y - 1,
                        world.offset_x + world.width + 1, world.offset_y - 1,
                        world.offset_x + world.width + 1, world.offset_y + world.height + 1,
                        world.offset_x - 1, world.offset_y + world.height + 1,
                        world.offset_x - 1, world.offset_y - 1)
end

function fire_bullet_weapon()
    if bullet_weapon.ammo_current > 0 and bullet_weapon.firing_rate_current <= 0 then
        local times = bullet_weapon.firing_rate_current
        while times <= 0 and bullet_weapon.ammo_current > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + bullet_round.velocity

            player.xvel = player.xvel - bullet_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - bullet_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tv = tv
            shot1.rotation = player.rotation + math.random(-3,3) * math.pi / 180
            shot1.lifespan = bullet_round.lifespan
            table.insert(bullet_weapon.shots, shot1)

            bullet_weapon.ammo_current = bullet_weapon.ammo_current - 1
            times = times + bullet_weapon.firing_rate_total
        end

        bullet_weapon.firing_rate_current = times
    end
end

function fire_flame_weapon()
    if flame_weapon.ammo_current > 0 and flame_weapon.firing_rate_current <= 0 then
        local times = flame_weapon.firing_rate_current
        while times <= 0 and flame_weapon.ammo_current > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + flame_round.velocity

            player.xvel = player.xvel - flame_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - flame_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tvel = tv
            shot1.rotation = player.rotation + math.random(-20,20) * math.pi / 180
            shot1.lifespan = flame_round.lifespan
            table.insert(flame_weapon.shots, shot1)

            flame_weapon.ammo_current = flame_weapon.ammo_current - 1
            times = times + flame_weapon.firing_rate_total
        end

        flame_weapon.firing_rate_current = times
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
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tvel = tv
            shot1.rotation = player.rotation + math.random(-3,3) * math.pi / 180
            shot1.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot1)

            local shot2 = {}
            shot2.x = player.x
            shot2.y = player.y
            shot2.tvel = tv
            shot2.rotation = player.rotation - math.random(-7.5,-1.5) * math.pi / 180
            shot2.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot2)

            local shot3 = {}
            shot3.x = player.x
            shot3.y = player.y
            shot3.tvel = tv
            shot3.rotation = player.rotation + math.random(1.5,7.5) * math.pi / 180
            shot3.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot3)

            local shot4 = {}
            shot4.x = player.x
            shot4.y = player.y
            shot4.tvel = tv
            shot4.rotation = player.rotation - math.random(6,12) * math.pi / 180
            shot4.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot4)

            local shot5 = {}
            shot5.x = player.x
            shot5.y = player.y
            shot5.tvel = tv
            shot5.rotation = player.rotation + math.random(-12,-6) * math.pi / 180
            shot5.lifespan = shell_round.lifespan
            table.insert(shell_weapon.shots, shot5)

            shell_weapon.ammo_current = shell_weapon.ammo_current - 1
            times = times + shell_weapon.firing_rate_total
        end

        shell_weapon.firing_rate_current = times
    end
end
