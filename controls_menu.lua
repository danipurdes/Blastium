controls_menu = {}
controls_menu.grid = love.graphics.newImage("assets/images/grid_600.png")
controls_menu.control_image = love.graphics.newImage("assets/images/controls.png")

function keypressedControlsMenu(key)
    if key == "space" then
        worldStateChange(world.previous_state)
        menuIndexSelect()
    end
end

function drawControlsMenu()
    drawStarfield()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", 100, 100, 400, 400)
    love.graphics.rectangle("line", 96, 96, 408, 408)
    love.graphics.rectangle("line", 97, 97, 406, 406)

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(fonts.font_title)
    love.graphics.printf("- CONTROLS -", 0, world.height / 2 - 150, world.width, "center")

    --love.graphics.setColor(200,200,200,255)
    --love.graphics.draw(controls_menu.control_image, world.width/2, world.height/2, 0, 1, 1, controls_menu.control_image:getWidth()/2, controls_menu.control_image:getHeight()/2)

    love.graphics.setFont(fonts.font_text)
    local text_div = 3
    love.graphics.printf("MOVEMENT", world.width / text_div, world.height / 2 - 100, world.width, "left")
    love.graphics.printf("W", world.width / text_div, world.height / 2 - 80, world.width, "left")
    love.graphics.printf("A", world.width / text_div, world.height / 2 - 60, world.width, "left")
    love.graphics.printf("D", world.width / text_div, world.height / 2 - 40, world.width, "left")
    love.graphics.printf("S", world.width / text_div, world.height / 2 - 20, world.width, "left")

    love.graphics.printf("SHOOTING", world.width / text_div, world.height / 2 + 20, world.width, "left")
    love.graphics.printf("UP", world.width / text_div, world.height / 2 + 40, world.width, "left")
    love.graphics.printf("LEFT", world.width / text_div, world.height / 2 + 60, world.width, "left")

    love.graphics.printf("OTHER", world.width / text_div, world.height / 2 + 100, world.width, "left")
    love.graphics.printf("P", world.width / text_div, world.height / 2 + 120, world.width, "left")
    love.graphics.printf("M", world.width / text_div, world.height / 2 + 140, world.width, "left")

    love.graphics.printf("- MOVE FORWARD", world.width / text_div + 20, world.height / 2 - 80, world.width, "left")
    love.graphics.printf("- TURN LEFT", world.width / text_div + 20, world.height / 2 - 60, world.width, "left")
    love.graphics.printf("- TURN RIGHT", world.width / text_div + 20, world.height / 2 - 40, world.width, "left")
    love.graphics.printf("- BRAKE", world.width / text_div + 20, world.height / 2 - 20, world.width, "left")

    love.graphics.printf("- FIRE BLASTER", world.width / text_div + 50, world.height / 2 + 40, world.width, "left")
    love.graphics.printf("- FIRE MOONSHOT", world.width / text_div + 50, world.height / 2 + 60, world.width, "left")

    love.graphics.printf("- PAUSE", world.width / text_div + 20, world.height / 2 + 120, world.width, "left")
    love.graphics.printf("- MUTE", world.width / text_div + 20, world.height / 2 + 140, world.width, "left")

    love.graphics.printf("PRESS SPACE TO RETURN", 0, world.height - 30, world.width, "center")
end

return controls_menu
