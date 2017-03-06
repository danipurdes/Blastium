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
    x = 0,
    y = 0,
    rotation = 0,
    velX = 0,
    velY = 0,
    speed = 90,
    rotation_influence = 1,
    removal_flag = false
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
    player.health = 5
    player.coins = 0
    world.score = 0

    enemySpawnFormation(1)
    --enemySpawnFormation(2)

    for i=1,12 do
        local c = {}
        c.x = coin.x + i*40
        c.y = coin.y + i*20
        c.radius = coin.radius
        c.removal_flag = false
        table.insert(coins, c)
    end

    screenshake.active = false
    screenshake.current_magnitude = 0
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
            if onPlayerDamage(v.x, v.y) then
                return
            end
          end

          for j=#bullet_weapon.shots,1,-1 do
            local s = bullet_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
              v.removal_flag = true
              s.removal_flag = true
              world.score = world.score + 1

              --enemy drops a coin
              local co = {}
              co.x = v.x
              co.y = v.y
              co.radius = coin.radius
              co.removal_flag = false
              table.insert(coins, co)

              initiateScreenshake()
            end
          end

          for j=#shell_weapon.shots,1,-1 do
            local s = shell_weapon.shots[j]
            if circle_overlap(s.x, s.y, 4, v.x, v.y, 16) then
              v.removal_flag = true
              s.removal_flag = true
              world.score = world.score + 1
              initiateScreenshake()
            end
          end
      end

      for i,c in ipairs(coins) do
          if circle_overlap(player.x, player.y, 16, c.x, c.y, c.radius) then
            player.coins = player.coins + 1
            love.audio.play(coin.pickup_sound)
            c.removal_flag = true
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

      for i=#coins, 1, -1 do
        if coins[i].removal_flag then
            table.remove(coins, i)
        end
      end

      updateStarfield(dt)

  elseif world.state == "pause" then
    updatePauseMenu(dt)

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

      if key == "x" then
        if player.coins >= 3 then
            player.health = player.health + 1
            player.coins = player.coins - 3
        end
      end

      if key == "n" then
        if player.coins >= 5 then
            shell_weapon.firing_rate_total = shell_weapon.firing_rate_total * .6
            player.coins = player.coins - 5
        end
      end

      if key == "m" then
        if player.coins >= 5 then
            bullet_weapon.firing_rate_total = bullet_weapon.firing_rate_total * .6
            player.coins = player.coins - 5
        end
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
      love.graphics.setFont(fonts.title_font)
      love.graphics.printf(world.name, 0, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), world.width, "center")
      love.graphics.setFont(fonts.text_font)

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

      love.graphics.setColor(coin.red, coin.green, coin.blue)
      for i,c in ipairs(coins) do
        love.graphics.ellipse("fill", c.x, c.y, c.radius, c.radius)
      end

      love.graphics.setColor(255,255,255)
      drawShots()
      drawPlayer()
      drawHUD()
      love.graphics.printf("fps " .. love.timer.getFPS(), 20, world.height - 40, world.width);
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
      love.graphics.setFont(fonts.text_font)
      love.graphics.printf(end_text, 0, world.height / 2 - 10, world.width, "center")
      love.graphics.printf(score_text, 0, world.height / 2 + 10, world.width, "center")
  end
end

function drawShots()
    drawBulletRounds()
    drawShellRounds()
end
