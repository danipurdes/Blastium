pause_menu = {}

pause_menu.index = 0
pause_menu.size = 3
pause_menu.option_0 = "RESUME"
pause_menu.option_1 = "CONTROLS"
pause_menu.option_2 = "OPTIONS"
pause_menu.option_3 = "QUIT TO MENU"
pause_menu.indicator_left = love.graphics.newImage("assets/images/pause_indicator_left_new.png")
pause_menu.ind_left_x = 204
pause_menu.indicator_right = love.graphics.newImage("assets/images/pause_indicator_right_new.png")
pause_menu.ind_right_x = 381
pause_menu.ind_base_y = 295
pause_menu.ind_scale_y = 20

function updatePauseMenu(dt)
    updateStarfield(dt)
end

function keypressedPauseMenu(key)
    if key == "p" then
        worldStateChange("play")
        menuIndexSelect()
    end

    if key == "up" then
        pause_menu.index = (pause_menu.index - 1) % pause_menu.size
        menuIndexChange()
    end

    if key == "down" then
        pause_menu.index = (pause_menu.index + 1) % pause_menu.size
        menuIndexChange()
    end

    if key == "space" then
        if pause_menu.index == 0 then
            worldStateChange("play")
        elseif pause_menu.index == 1 then
            worldStateChange("controls")
        --elseif pause_menu.index == 2 then
        --    worldStateChange("options")
        elseif pause_menu.index == 2 then
            worldStateChange("start/main")
        end

        menuIndexSelect()
    end
end

function drawPauseMenu()
    drawStarfield()
    drawShots()
    drawPlayer()
    drawHUD()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", 150, 150, 300, 300)

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(fonts.font_title)
    local pause_text = "- PAUSED -"
    love.graphics.printf(pause_text, 0, world.height / 2 - 40, world.width, "center")
    love.graphics.setFont(fonts.font_text)
    love.graphics.printf(pause_menu.option_0, 0, world.height / 2, world.width, "center")
    love.graphics.printf(pause_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
    --love.graphics.printf(pause_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
    love.graphics.printf(pause_menu.option_3, 0, world.height / 2 + 40, world.width, "center")

    love.graphics.draw(pause_menu.indicator_left, pause_menu.ind_left_x, pause_menu.ind_base_y + (pause_menu.ind_scale_y * pause_menu.index), 0)
    love.graphics.draw(pause_menu.indicator_right, pause_menu.ind_right_x, pause_menu.ind_base_y + (pause_menu.ind_scale_y * pause_menu.index), 0)

    love.graphics.printf("USE ARROW KEYS AND SPACE TO NAVIGATE MENUS", 0, world.height - 30, world.width, "center")
end

return pause_menu
