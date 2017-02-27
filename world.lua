world = {}
world.name = "BLASTIUM"
world.width = 600
world.height = 600
world.title_font = love.graphics.newImageFont("assets/images/title_font.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ ",
    8)
world.text_font = love.graphics.newImageFont("assets/images/example_font_inverted_monospace.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"",
    2)
world.hud_font = love.graphics.newImageFont("assets/images/thinpixelfont.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ", 1)
world.state = "start/open"
world.previous_state = "start/open"
world.score = 0

function worldStateChange(new_state)
    world.previous_state = world.state
    world.state = new_state
end

return world
