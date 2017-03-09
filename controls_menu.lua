controls_menu = {}

function keypressedControlsMenu(key)
    if key == "escape" then
        worldStateChange(world.previous_state)
        menuIndexSelect()
    end
end

function drawControlsMenu()
    drawStarfield()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", 150, 150, 300, 300)

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(fonts.font_title)
    love.graphics.printf("- CONTROLS -", 0, world.height / 2 - 90, world.width, "center")

    love.graphics.setFont(fonts.font_text)
    local text_div = 2.8
    love.graphics.printf("W", world.width / text_div, world.height / 2 - 50, world.width, "left")
    love.graphics.printf("A", world.width / text_div, world.height / 2 - 30, world.width, "left")
    love.graphics.printf("D", world.width / text_div, world.height / 2 - 10, world.width, "left")
    love.graphics.printf("S", world.width / text_div, world.height / 2 + 10, world.width, "left")
    love.graphics.printf("K", world.width / text_div, world.height / 2 + 30, world.width, "left")
    love.graphics.printf("L", world.width / text_div, world.height / 2 + 50, world.width, "left")
    love.graphics.printf("P", world.width / text_div, world.height / 2 + 70, world.width, "left")
    love.graphics.printf("M", world.width / text_div, world.height / 2 + 90, world.width, "left")

    love.graphics.printf("- ACCELERATE", world.width / text_div + 20, world.height / 2 - 50, world.width, "left")
    love.graphics.printf("- TURN LEFT", world.width / text_div + 20, world.height / 2 - 30, world.width, "left")
    love.graphics.printf("- TURN RIGHT", world.width / text_div + 20, world.height / 2 - 10, world.width, "left")
    love.graphics.printf("- DECELERATE", world.width / text_div + 20, world.height / 2 + 10, world.width, "left")
    love.graphics.printf("- FIRE BLASTER", world.width / text_div + 20, world.height / 2 + 30, world.width, "left")
    love.graphics.printf("- FIRE MOONSHOT", world.width / text_div + 20, world.height / 2 + 50, world.width, "left")
    love.graphics.printf("- PAUSE", world.width / text_div + 20, world.height / 2 + 70, world.width, "left")
    love.graphics.printf("- MUTE", world.width / text_div + 20, world.height / 2 + 90, world.width, "left")

    love.graphics.printf("PRESS ESCAPE TO RETURN", 0, world.height - 30, world.width, "center")
end

return controls_menu
