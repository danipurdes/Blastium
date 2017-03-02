controls_menu = {}

function keypressedControlsMenu(key)
    if key == "space" then
        worldStateChange(world.previous_state)
    end
end

function drawControlsMenu()
    drawStarfield()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", 50, 50, 500, 500)

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(fonts.text_font)
    love.graphics.printf("- Controls -", 0, world.height / 2 - 90, world.width, "center")
    love.graphics.printf("W - accelerate", world.width / 5, world.height / 2 - 50, world.width, "left")
    love.graphics.printf("A - turn left/counter-clockwise", world.width / 5, world.height / 2 - 30, world.width, "left")
    love.graphics.printf("D - turn right/clockwise", world.width / 5, world.height / 2 - 10, world.width, "left")
    love.graphics.printf("S - brake/decelerate", world.width / 5, world.height / 2 + 10, world.width, "left")
    love.graphics.printf("; - fire blaster", world.width / 5, world.height / 2 + 30, world.width, "left")
    love.graphics.printf("' - fire moonshot", world.width / 5, world.height / 2 + 50, world.width, "left")
    love.graphics.printf("P - pause game", world.width / 5, world.height / 2 + 70, world.width, "left")
    love.graphics.printf("M - mute", world.width / 5, world.height / 2 + 90, world.width, "left")
end

return controls_menu
