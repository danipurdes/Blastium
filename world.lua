world = {}
world.name = "BLASTIUM"
world.width = 600
world.height = 600
world.state = "splashscreen"
world.previous_state = "splashscreen"
world.score = 0
world.high_score = 0
world.high_score_flag = false
world.logo = love.graphics.newImage("assets/images/blastium_logo.png")
world.game_timer = 500
world.game_cooldown = 500
world.stateChangeOccurred = false

world.menu_index_change_sound = love.audio.newSource("assets/audio/menu_index_change.wav","static")
world.menu_index_select_sound = love.audio.newSource("assets/audio/menu_index_select.wav","static")

function worldStateChange(new_state)
    world.previous_state = world.state
    world.state = new_state
    world.stateChangeOccurred = true

    if new_state == "start/main" then
        toMainMenu()
    end

    if new_state == "pause" then
        toPauseMenu()
    end
end

function menuIndexChange()
    love.audio.play(world.menu_index_change_sound)
end

function menuIndexSelect()
    love.audio.play(world.menu_index_select_sound)
end

return world
