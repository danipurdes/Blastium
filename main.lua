player = {
  x = 150,
  y = 150,
  xvel = 0,
  yvel = 0,
  rotation = 0,
  ANGACCEL = 0,
  shots = {},
  ammo = 100,
  firing_rate_tot = .4,
  firing_rate_cur = 0
}

local ROTATION_SPEED = 180
local ACCELERATION = 400
local DRAG = 100;
local MAX_SPEED = 400;

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


  player.firing_rate_cur = player.firing_rate_cur - dt

  if love.keyboard.isDown("space") then
    shoot()
  end

  if player.firing_rate_cur <= 0 then
    player.firing_rate_cur = 0
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
  for i=#player.shots,1,-1 do
    -- move them up up up
    local v = player.shots[i]
    v.x = v.x + dt * math.cos(v.rotation) * v.tvel
    v.y = v.y + dt * math.sin(v.rotation) * v.tvel
    -- mark shots that are not visible for removal
    if v.y < 0 or v.y > love.graphics.getHeight() or v.x < 0 or v.x > love.graphics.getWidth() then
      table.remove(player.shots, i)
    end
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("(" .. math.floor(player.x) .. ", " .. math.floor(player.y) .. ") : " .. math.floor(vel_total), 10, 10)
  love.graphics.print("Number of bullets : " .. #player.shots, 10, 20)
  love.graphics.print("Ammo : " .. player.ammo, 10, 30)
  love.graphics.print("Time to reload : " .. player.firing_rate_cur .. " / " .. player.firing_rate_tot, 10, 40)

  --if (love.keyboard.isDown("space")) then
    --love.graphics.translate(2*math.random(), 2*math.random())
  --end

  love.graphics.setColor(255, 255, 255)
  love.graphics.translate(player.x, player.y)
  love.graphics.rotate(player.rotation)
  love.graphics.rectangle("fill", -6, -4, 12, 8)
  love.graphics.setColor(200, 200, 200)
  love.graphics.line(0, 0, 6, 0)
  love.graphics.rotate(-player.rotation)
  love.graphics.translate(-player.x, -player.y)

  -- let's draw our heros shots
  love.graphics.setColor(255,255,255)
  for i,v in ipairs(player.shots) do
    love.graphics.line(v.x, v.y, v.x + 4 * math.cos(v.rotation), v.y + 4 * math.sin(v.rotation))
  end
end

function love.keydown(key)
    if (key == "space") then
    --    shoot()
    end
end

function shoot()
    if player.ammo > 0 and player.firing_rate_cur <= 0 then
        local times = player.firing_rate_cur
        while times <= 0 and player.ammo > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + 300

            player.xvel = player.xvel - 2 * math.cos(player.rotation)
            player.yvel = player.yvel - 2 * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 5 * math.random()
            shot1.y = player.y + 5 * math.random()
            shot1.tvel = tv
            shot1.rotation = player.rotation + math.random(-3,3) * math.pi / 180
            table.insert(player.shots, shot1)

            player.ammo = player.ammo - 1
            times = times + player.firing_rate_tot
        end

        player.firing_rate_cur = times
    end

    --local shot2 = {}
    --shot2.x = player.x
    --shot2.y = player.y
    --shot2.tvel = tv
    --shot2.rotation = player.rotation - 5 * math.pi / 180
    --table.insert(player.shots, shot2)

    --local shot3 = {}
    --shot3.x = player.x
    --shot3.y = player.y
    --shot3.tvel = tv
    --shot3.rotation = player.rotation + 5 * math.pi / 180
    --table.insert(player.shots, shot3)
end
