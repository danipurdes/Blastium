world = {}
world.name = "BLASTIUM"
world.width = 600
world.height = 600
world.state = "start/open"
world.previous_state = "start/open"
world.score = 0

function worldStateChange(new_state)
    world.previous_state = world.state
    world.state = new_state
end

return world
