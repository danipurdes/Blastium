pause_menu = {}

pause_menu.index = 0
pause_menu.size = 4
pause_menu.option_0 = "Resume"
pause_menu.option_1 = "Controls"
pause_menu.option_2 = "Options"
pause_menu.option_3 = "Quit to Menu"
pause_menu.indicator_left = love.graphics.newImage("assets/images/pause_indicator_left_new.png")
pause_menu.ind_left_x = 204
pause_menu.indicator_right = love.graphics.newImage("assets/images/pause_indicator_right_new.png")
pause_menu.ind_right_x = 381
pause_menu.ind_base_y = 300
pause_menu.ind_scale_y = 20

function keypressedPauseMenu(key)
    if key == "p" then
        world.state = "play"
        world.previous_state = "pause"
    end

    if key == "up" then
        pause_menu.index = (pause_menu.index - 1) % pause_menu.size
    end

    if key == "down" then
        pause_menu.index = (pause_menu.index + 1) % pause_menu.size
    end

    if key == "space" then
        if pause_menu.index == 0 then
            world.state = "play"
            world.previous_state = "pause"
        elseif pause_menu.index == 1 then
            world.state = "controls"
            world.previous_state = "pause"
        elseif pause_menu.index == 2 then
            world.state = "options"
            world.previous_state = "pause"
        elseif pause_menu.index == 3 then
            world.state = "start/main"
            world.previous_state = "pause"
        end
    end
end

function drawPauseMenu()
    drawStarfield()
    drawShots()
    drawPlayer()
    drawHUD()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(255, 255, 255);
    local pause_text = "- PAUSED -"
    love.graphics.printf(pause_text, 0, world.height / 2 - 40, world.width, "center")
    love.graphics.printf(pause_menu.option_0, 0, world.height / 2, world.width, "center")
    love.graphics.printf(pause_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
    love.graphics.printf(pause_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
    love.graphics.printf(pause_menu.option_3, 0, world.height / 2 + 60, world.width, "center")

    love.graphics.draw(pause_menu.indicator_left, pause_menu.ind_left_x, pause_menu.ind_base_y + (pause_menu.ind_scale_y * pause_menu.index), 0)
    love.graphics.draw(pause_menu.indicator_right, pause_menu.ind_right_x, pause_menu.ind_base_y + (pause_menu.ind_scale_y * pause_menu.index), 0)
end

return pause_menu
