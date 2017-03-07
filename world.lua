world = {}
world.name = "BLASTIUM"
world.width = 600
world.height = 600
world.state = "start/open"
world.previous_state = "start/open"
world.score = 0
world.high_score = 0
world.high_score_flag = false

world.menu_index_change_sound = love.audio.newSource("assets/audio/menu_index_change.wav","static")
world.menu_index_select_sound = love.audio.newSource("assets/audio/menu_index_select.wav","static")

function worldStateChange(new_state)
    world.previous_state = world.state
    world.state = new_state
end

function menuIndexChange()
    love.audio.play(world.menu_index_change_sound)
end

function menuIndexSelect()
    love.audio.play(world.menu_index_select_sound)
end

return world
