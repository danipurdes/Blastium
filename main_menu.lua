main_menu = {}

main_menu.index = 0
main_menu.size = 4
main_menu.option_0 = "PLAY"
main_menu.option_1 = "CONTROLS"
main_menu.option_2 = "OPTIONS"
main_menu.option_3 = "CREDITS"
main_menu.option_4 = "QUIT GAME"
main_menu.indicator_left = love.graphics.newImage("assets/images/pause_indicator_left_new.png")
main_menu.ind_left_x = 220
main_menu.indicator_right = love.graphics.newImage("assets/images/pause_indicator_right_new.png")
main_menu.ind_right_x = 365
main_menu.ind_base_y = 295
main_menu.ind_scale_y = 20

function keypressedMainMenu(key)
    if key == "up" then
        main_menu.index = (main_menu.index - 1) % main_menu.size
        menuIndexChange()
    end

    if key == "down" then
        main_menu.index = (main_menu.index + 1) % main_menu.size
        menuIndexChange()
    end

    if key == "space" then
        if main_menu.index == 0 then
            loadGame()
            worldStateChange("play")
        elseif main_menu.index == 1 then
            worldStateChange("controls")
        --elseif main_menu.index == 2 then
        --    worldStateChange("options")
        elseif main_menu.index == 2 then
            worldStateChange("credits")
        elseif main_menu.index == 3 then
            love.event.quit()
        end

        menuIndexSelect()
    end
end

function drawMainMenu()
    drawStarfield()

    love.graphics.setColor(255, 255, 255)
    --love.graphics.setFont(fonts.title_font)
    --love.graphics.printf(world.name, 0, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), world.width, "center")
    love.graphics.draw(world.logo, 300, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), 0, 4, 4, world.logo:getWidth()/2, world.logo:getHeight()/2)
    love.graphics.setFont(fonts.font_text)

    love.graphics.setColor(255, 255, 255);
    love.graphics.printf(main_menu.option_0, 0, world.height / 2, world.width, "center")
    love.graphics.printf(main_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
    --love.graphics.printf(main_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
    love.graphics.printf(main_menu.option_3, 0, world.height / 2 + 40, world.width, "center")
    love.graphics.printf(main_menu.option_4, 0, world.height / 2 + 60, world.width, "center")

    love.graphics.draw(main_menu.indicator_left, main_menu.ind_left_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)
    love.graphics.draw(main_menu.indicator_right, main_menu.ind_right_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)

    love.graphics.printf("USE ARROW KEYS AND SPACE TO NAVIGATE MENUS", 0, world.height - 30, world.width, "center")
    end

return main_menu
