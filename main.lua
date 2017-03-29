love.graphics.setDefaultFilter("nearest", "nearest")

utilities = require "utilities"

world = require "world"
play = require "play_state"
fonts = require "fonts"
audio = require "audio"
player = require "player"
starfield = require "starfield"
hud = require "hud"
screenshake = require "screenshake"
spawn_formations = require "spawn_formations"
spawner = require "spawner"

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

asteroid_32 = {
    image = love.graphics.newImage("assets/images/asteroid_32.png"),
    x = 0,
    y = 0,
    rotation = 0,
    speed = 10,
    radius = 32,
    removal_flag = false,
    type = 32,
    score = 25
}

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
    despawnAsteroids()

    loadPlayer()
    loadSpawner()

    screenshake.active = false
    screenshake.current_magnitude = 0
end

function love.update(dt)
  updateStarfield(dt)
  updateAudioIcon(dt)

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

  elseif world.state == "play" then
      updatePlayState(dt)
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

  elseif world.state == "start/main" then
      keypressedMainMenu(key)

  elseif world.state == "play" then
      keypressedPlayState(key)

  elseif world.state == "pause" then
    keypressedPauseMenu(key)

  elseif world.state == "controls" then
    keypressedControlsMenu(key)

  elseif world.state == "options" then
    keypressedOptionsMenu(key)

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
      drawPlayState()

  elseif world.state == "pause" then
      drawPauseMenu()

  elseif world.state == "controls" then
      drawControlsMenu()

  elseif world.state == "options" then
      drawOptionsMenu()

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

  drawAudioIcon()
end

function drawShots()
    drawBulletRounds()
    drawShellRounds()
end
