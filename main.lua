player = {
  x = 150,
  y = 150,
  xvel = 0,
  yvel = 0,
  rotation = 0,
  ANGACCEL = 0,
  image = love.graphics.newImage("assets/ship_bosco.png"),
  weapon_index = 0,

  bullet_shots = {},
  bullet_ammo = 25,
  bullet_ammo_max = 25,
  bullet_firing_rate_tot = .4,
  bullet_firing_rate_cur = 0,

  flame_shots = {},
  flame_ammo = 400,
  flame_ammo_max = 400,
  flame_firing_rate_tot = .025,
  flame_firing_rate_cur = 0,

  shell_shots = {},
  shell_ammo = 15,
  shell_ammo_max = 15,
  shell_firing_rate_tot = .8,
  shell_firing_rate_cur = 0
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
    image = love.graphics.newImage("assets/bullet.png")
}

shell_round = {
    velocity = 500,
    mass = 30,
    lifespan = .5,
    image = love.graphics.newImage("assets/bullet.png")
}

local ROTATION_SPEED = 180
local ACCELERATION = 400
local DRAG = 100
local MAX_SPEED = 400

function love.update(dt)
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


  player.bullet_firing_rate_cur = player.bullet_firing_rate_cur - dt
  player.flame_firing_rate_cur  = player.flame_firing_rate_cur - dt
  player.shell_firing_rate_cur  = player.shell_firing_rate_cur - dt


  if love.keyboard.isDown("lshift") then
    --player.weapon_index = player.weapon_index + 1
  end

  if love.keyboard.isDown("space") then
    if player.weapon_index == 0 then
      shoot()
    elseif player.weapon_index == 1 then
      flamethrower()
    elseif player.weapon_index == 2 then
      shell()
    end
  end


  if love.keyboard.isDown("h") then
    shoot()
  elseif love.keyboard.isDown("j") then
    flamethrower()
  elseif love.keyboard.isDown("k") then
    shell()
  end

  if love.keyboard.isDown("r") then
    player.bullet_ammo = player.bullet_ammo_max;
    player.flame_ammo  = player.flame_ammo_max;
    player.shell_ammo  = player.shell_ammo_max;
  end

  if player.bullet_firing_rate_cur <= 0 then
    player.bullet_firing_rate_cur = 0
  end

  if player.flame_firing_rate_cur <= 0 then
    player.flame_firing_rate_cur = 0
  end

  if player.shell_firing_rate_cur <= 0 then
    player.shell_firing_rate_cur = 0
  end


  player.xvel = player.xvel - (player.xvel / DRAG)
  player.yvel = player.yvel - (player.yvel / DRAG)

  if vel_total > MAX_SPEED then
    player.xvel = player.xvel / vel_total * MAX_SPEED
    player.yvel = player.yvel / vel_total * MAX_SPEED
  end

  player.x = player.x + player.xvel*dt
  player.y = player.y + player.yvel*dt


  if player.x > love.graphics.getWidth() then
    player.x = 0
  elseif player.x < 0 then
    player.x = love.graphics.getWidth()
  end

  if player.y > love.graphics.getHeight() then
    player.y = 0
  elseif player.y < 0 then
    player.y = love.graphics.getHeight()
  end


  -- update the shots
  for i=#player.bullet_shots,1,-1 do
    -- move them up up up
    local v = player.bullet_shots[i]
    v.x = v.x + dt * math.cos(v.rotation) * v.tv
    v.y = v.y + dt * math.sin(v.rotation) * v.tv

    if v.x > love.graphics.getWidth() then
      v.x = v.x - love.graphics.getWidth()
    elseif v.x < 0 then
      v.x = v.x + love.graphics.getWidth()
    end

    if v.y > love.graphics.getHeight() then
      v.y = v.y - love.graphics.getHeight()
    elseif v.y < 0 then
      v.y = v.y + love.graphics.getHeight()
    end

    -- decrease lifespan
    v.lifespan = v.lifespan - dt
    -- mark shots that are not visible for removal
    if v.lifespan <= 0 or v.y < 0 or v.y > love.graphics.getHeight() or v.x < 0 or v.x > love.graphics.getWidth() then
      table.remove(player.bullet_shots, i)
    end
  end

  for i=#player.flame_shots,1,-1 do
    -- move them up up up
    local v = player.flame_shots[i]
    v.x = v.x + dt * math.cos(v.rotation) * v.tvel
    v.y = v.y + dt * math.sin(v.rotation) * v.tvel

    if v.x > love.graphics.getWidth() then
      v.x = v.x - love.graphics.getWidth()
    elseif v.x < 0 then
      v.x = v.x + love.graphics.getWidth()
    end

    if v.y > love.graphics.getHeight() then
      v.y = v.y - love.graphics.getHeight()
    elseif v.y < 0 then
      v.y = v.y + love.graphics.getHeight()
    end

    -- decrease lifespan
    v.lifespan = v.lifespan - dt
    -- mark shots that are not visible for removal
    if v.lifespan <= 0 or v.y < 0 or v.y > love.graphics.getHeight() or v.x < 0 or v.x > love.graphics.getWidth() then
      table.remove(player.flame_shots, i)
    end
  end

  for i=#player.shell_shots,1,-1 do
    -- move them up up up
    local v = player.shell_shots[i]
    v.x = v.x + dt * math.cos(v.rotation) * v.tvel
    v.y = v.y + dt * math.sin(v.rotation) * v.tvel

    if v.x > love.graphics.getWidth() then
      v.x = v.x - love.graphics.getWidth()
    elseif v.x < 0 then
      v.x = v.x + love.graphics.getWidth()
    end

    if v.y > love.graphics.getHeight() then
      v.y = v.y - love.graphics.getHeight()
    elseif v.y < 0 then
      v.y = v.y + love.graphics.getHeight()
    end

    -- decrease lifespan
    v.lifespan = v.lifespan - dt
    -- mark shots that are not visible for removal
    if v.lifespan <= 0 or v.y > love.graphics.getHeight() or v.x < 0 or v.x > love.graphics.getWidth() then
      table.remove(player.shell_shots, i)
    end
  end
end

function love.keypressed(key)
  if key == "lshift" then
    player.weapon_index = player.weapon_index + 1
    player.weapon_index = player.weapon_index % 3
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("(" .. math.floor(player.x) .. ", " .. math.floor(player.y) .. ") : " .. math.floor(vel_total), 10, 10)
  love.graphics.print("Number of bullets : " .. #player.bullet_shots, 10, 20)
  love.graphics.print("Ammo : " .. player.bullet_ammo, 10, 30)
  love.graphics.print("Time to reload : " .. player.bullet_firing_rate_cur .. " / " .. player.bullet_firing_rate_tot, 10, 40)
  love.graphics.print("Number of flame bullets : " .. #player.flame_shots, 10, 60)
  love.graphics.print("Flame Ammo : " .. player.flame_ammo, 10, 70)
  love.graphics.print("Time to reload flame shot : " .. player.flame_firing_rate_cur .. " / " .. player.flame_firing_rate_tot, 10, 80)
  love.graphics.print("Number of shell bullets : " .. #player.shell_shots, 10, 100)
  love.graphics.print("shell Ammo : " .. player.shell_ammo, 10, 110)
  love.graphics.print("Time to reload shell shot : " .. player.shell_firing_rate_cur .. " / " .. player.shell_firing_rate_tot, 10, 120)
  love.graphics.print("Weapon index: " .. player.weapon_index, 10, 140)

  --vlambeer mode
  if (love.keyboard.isDown("space")) then
    love.graphics.translate(2*math.random(), 2*math.random())
  end

  --love.graphics.translate(player.x, player.y)
  --love.graphics.rectangle("fill", -6, -4, 12, 8)
  --love.graphics.setColor(200, 200, 200)
  --love.graphics.line(0, 0, 6, 0)
  --love.graphics.rotate(-player.rotation)
  --love.graphics.translate(-player.x, -player.y)
  love.graphics.draw(player.image, player.x, player.y, player.rotation, 1, 1, 8, 8)

  -- let's draw our heros shots
  love.graphics.setColor(34,171,199)
  for i,v in ipairs(player.bullet_shots) do
    love.graphics.draw(bullet_round.image, v.x, v.y, v.rotation)
  end

  love.graphics.setColor(237,20,90)
  for i,v in ipairs(player.flame_shots) do
    love.graphics.draw(flame_round.image, v.x, v.y, v.rotation)
  end

  love.graphics.setColor(240,216,24)
  for i,v in ipairs(player.shell_shots) do
    love.graphics.draw(shell_round.image, v.x, v.y, v.rotation)
  end
end

function shoot()
    if player.bullet_ammo > 0 and player.bullet_firing_rate_cur <= 0 then
        local times = player.bullet_firing_rate_cur
        while times <= 0 and player.bullet_ammo > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + bullet_round.velocity

            player.xvel = player.xvel - bullet_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - bullet_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tv = tv
            shot1.rotation = player.rotation + math.random(-3,3) * math.pi / 180
            shot1.lifespan = bullet_round.lifespan
            table.insert(player.bullet_shots, shot1)

            player.bullet_ammo = player.bullet_ammo - 1
            times = times + player.bullet_firing_rate_tot
        end

        player.bullet_firing_rate_cur = times
    end
end

function flamethrower()
    if player.flame_ammo > 0 and player.flame_firing_rate_cur <= 0 then
        local times = player.flame_firing_rate_cur
        while times <= 0 and player.flame_ammo > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + flame_round.velocity

            player.xvel = player.xvel - flame_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - flame_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tvel = tv
            shot1.rotation = player.rotation + math.random(-20,20) * math.pi / 180
            shot1.lifespan = flame_round.lifespan
            table.insert(player.flame_shots, shot1)

            player.flame_ammo = player.flame_ammo - 1
            times = times + player.flame_firing_rate_tot
        end

        player.flame_firing_rate_cur = times
    end
end

function shell()
    if player.shell_ammo > 0 and player.shell_firing_rate_cur <= 0 then
        local times = player.shell_firing_rate_cur
        while times <= 0 and player.shell_ammo > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + shell_round.velocity

            player.xvel = player.xvel - shell_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - shell_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tvel = tv
            shot1.rotation = player.rotation + math.random(-3,3) * math.pi / 180
            shot1.lifespan = shell_round.lifespan
            table.insert(player.shell_shots, shot1)

            local shot2 = {}
            shot2.x = player.x
            shot2.y = player.y
            shot2.tvel = tv
            shot2.rotation = player.rotation - math.random(-7.5,-1.5) * math.pi / 180
            shot2.lifespan = shell_round.lifespan
            table.insert(player.shell_shots, shot2)

            local shot3 = {}
            shot3.x = player.x
            shot3.y = player.y
            shot3.tvel = tv
            shot3.rotation = player.rotation + math.random(1.5,7.5) * math.pi / 180
            shot3.lifespan = shell_round.lifespan
            table.insert(player.shell_shots, shot3)

            local shot4 = {}
            shot4.x = player.x
            shot4.y = player.y
            shot4.tvel = tv
            shot4.rotation = player.rotation - math.random(6,12) * math.pi / 180
            shot4.lifespan = shell_round.lifespan
            table.insert(player.shell_shots, shot4)

            local shot5 = {}
            shot5.x = player.x
            shot5.y = player.y
            shot5.tvel = tv
            shot5.rotation = player.rotation + math.random(-12,-6) * math.pi / 180
            shot5.lifespan = shell_round.lifespan
            table.insert(player.shell_shots, shot5)

            player.shell_ammo = player.shell_ammo - 1
            times = times + player.shell_firing_rate_tot
        end

        player.shell_firing_rate_cur = times
    end
end
