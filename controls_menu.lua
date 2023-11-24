controls_menu = {}
controls_menu.grid = love.graphics.newImage("assets/images/grid_600.png")
controls_menu.control_image = love.graphics.newImage("assets/images/controls.png")

function keypressedControlsMenu(key)
    if key == "space" then
        worldStateChange(world.previous_state)
        menuIndexSelect()
    end
end

function drawControlsMenu(origin_x, origin_y)
    drawStarfield(origin_x, origin_y)

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", origin_x, origin_y, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", origin_x + 100, origin_y + 100, 400, 400)
    love.graphics.rectangle("line", origin_x + 96, origin_y + 96, 408, 408)
    love.graphics.rectangle("line", origin_x + 97, origin_y + 97, 406, 406)

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(fonts.font_title)
    love.graphics.printf("- CONTROLS -", origin_x, origin_y + world.height / 2 - 150, world.width, "center")

    --love.graphics.setColor(200,200,200,255)
    --love.graphics.draw(controls_menu.control_image, world.width/2, world.height/2, 0, 1, 1, controls_menu.control_image:getWidth()/2, controls_menu.control_image:getHeight()/2)

    love.graphics.setFont(fonts.font_text)
    local text_div = 3
    love.graphics.printf("MOVEMENT", origin_x + world.width / text_div, origin_y + world.height / 2 - 100, world.width, "left")
    love.graphics.printf("UP", origin_x + world.width / text_div, origin_y + world.height / 2 - 80, world.width, "left")
    love.graphics.printf("LEFT", origin_x + world.width / text_div, origin_y + world.height / 2 - 60, world.width, "left")
    love.graphics.printf("RIGHT", origin_x + world.width / text_div, origin_y + world.height / 2 - 40, world.width, "left")
    love.graphics.printf("DOWN", origin_x + world.width / text_div, origin_y + world.height / 2 - 20, world.width, "left")

    love.graphics.printf("SHOOTING", origin_x + world.width / text_div, origin_y + world.height / 2 + 20, world.width, "left")
    love.graphics.printf("Z", origin_x + world.width / text_div, origin_y + world.height / 2 + 40, world.width, "left")
    love.graphics.printf("X", origin_x + world.width / text_div, origin_y + world.height / 2 + 60, world.width, "left")

    love.graphics.printf("OTHER", origin_x + world.width / text_div, origin_y + world.height / 2 + 100, world.width, "left")
    love.graphics.printf("P", origin_x + world.width / text_div, origin_y + world.height / 2 + 120, world.width, "left")
    love.graphics.printf("M", origin_x + world.width / text_div, origin_y + world.height / 2 + 140, world.width, "left")

    love.graphics.printf("- MOVE FORWARD", origin_x + world.width / text_div + 60, origin_y + world.height / 2 - 80, world.width, "left")
    love.graphics.printf("- TURN LEFT", origin_x + world.width / text_div + 60, origin_y + world.height / 2 - 60, world.width, "left")
    love.graphics.printf("- TURN RIGHT", origin_x + world.width / text_div + 60, origin_y + world.height / 2 - 40, world.width, "left")
    love.graphics.printf("- BRAKE", origin_x + world.width / text_div + 60, origin_y + world.height / 2 - 20, world.width, "left")

    love.graphics.printf("- FIRE BLASTER", origin_x + world.width / text_div + 20, origin_y + world.height / 2 + 40, world.width, "left")
    love.graphics.printf("- FIRE MOONSHOT", origin_x + world.width / text_div + 20, origin_y + world.height / 2 + 60, world.width, "left")

    love.graphics.printf("- PAUSE", origin_x + world.width / text_div + 20, origin_y + world.height / 2 + 120, world.width, "left")
    love.graphics.printf("- MUTE", origin_x + world.width / text_div + 20, origin_y + world.height / 2 + 140, world.width, "left")

    love.graphics.printf("PRESS SPACE TO RETURN", origin_x, origin_y + world.height - 30, origin_y + world.width, "center")
end

return controls_menu
