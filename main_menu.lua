main_menu = {}

main_menu.index = 0
main_menu.size = 5
main_menu.option_0 = "Play"
main_menu.option_1 = "Controls"
main_menu.option_2 = "Options"
main_menu.option_3 = "Credits"
main_menu.option_4 = "Quit Game"
main_menu.indicator_left = love.graphics.newImage("assets/images/pause_indicator_left_new.png")
main_menu.ind_left_x = 204
main_menu.indicator_right = love.graphics.newImage("assets/images/pause_indicator_right_new.png")
main_menu.ind_right_x = 381
main_menu.ind_base_y = 300
main_menu.ind_scale_y = 20

function keypressedMainMenu(key)
    if key == "up" then
        main_menu.index = (main_menu.index - 1) % main_menu.size
    end

    if key == "down" then
        main_menu.index = (main_menu.index + 1) % main_menu.size
    end

    if key == "space" then
        if main_menu.index == 0 then
            loadGame()
            world.state = "play"
            world.previous_state = "start/main"
        elseif main_menu.index == 1 then
            world.state = "controls"
            world.previous_state = "start/main"
        elseif main_menu.index == 2 then
            world.state = "options"
            world.previous_state = "start/main"
        elseif main_menu.index == 3 then
            world.state = "credits"
            world.previous_state = "start/main"
        elseif main_menu.index == 4 then
            love.event.quit()
        end
    end
end

function drawMainMenu()
    drawStarfield()

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(world.title_font)
    love.graphics.printf(world.name, 0, lerp(logo_anim.start_y, logo_anim.t, logo_anim.end_y, logo_anim.lifespan), world.width, "center")
    love.graphics.setFont(world.text_font)

    love.graphics.setColor(255, 255, 255);
    love.graphics.printf(main_menu.option_0, 0, world.height / 2, world.width, "center")
    love.graphics.printf(main_menu.option_1, 0, world.height / 2 + 20, world.width, "center")
    love.graphics.printf(main_menu.option_2, 0, world.height / 2 + 40, world.width, "center")
    love.graphics.printf(main_menu.option_3, 0, world.height / 2 + 60, world.width, "center")
    love.graphics.printf(main_menu.option_4, 0, world.height / 2 + 80, world.width, "center")

    love.graphics.draw(main_menu.indicator_left, main_menu.ind_left_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)
    love.graphics.draw(main_menu.indicator_right, main_menu.ind_right_x, main_menu.ind_base_y + (main_menu.ind_scale_y * main_menu.index), 0)
end

return main_menu
