options_menu = {}

options_menu.index = 0
options_menu.count = 2
options_menu.option_1_title = "Music Volume"
options_menu.option_1_value = 1
options_menu.option_2_title = "Sound Volume"
options_menu.option_2_value = 1

function keypressedOptionsMenu(key)
    if key == "escape" then
      worldStateChange(world.previous_state)
    end

    if key == "down" then
      options_menu.index = (options_menu.index + 1) % options_menu.count
    end

    if key == "up" then
      options_menu.index = (options_menu.index + 1) % options_menu.count
    end

    if key == "right" then
      if options_menu.index == 1 then
        options_menu.option_1_value = options_menu.option_1_value + .1
        if options_menu.option_1_value > 1 then
          options_menu.option_1_value = 1
        end
      else
        options_menu.option_2_value = options_menu.option_2_value + .1
        if options_menu.option_2_value > 1 then
          options_menu.option_2_value = 1
        end
      end
    end

    if key == "left" then
      if options_menu.index == 1 then
        options_menu.option_1_value = options_menu.option_1_value - .1
        if options_menu.option_1_value < 0 then
          options_menu.option_1_value = 0
        end
      else
        options_menu.option_2_value = options_menu.option_2_value - .1
        if options_menu.option_2_value < 0 then
          options_menu.option_2_value = 0
        end
      end
    end
end

function drawOptionsMenu()
    love.graphics.setFont(fonts.text_font)
    love.graphics.setColor(255,255,255)
    love.graphics.printf(options_menu.option_1_title, 40, world.height / 2 - 50, world.width - 40, "left")
    love.graphics.rectangle("fill", 40, world.height / 2 - 20, 104, 4)
    love.graphics.rectangle("fill", 40 + options_menu.option_1_value * 100, world.height / 2 - 28, 4, 16)
    love.graphics.printf(options_menu.option_2_title, 40, world.height / 2 + 10, world.width - 40, "left")
    love.graphics.rectangle("fill", 40, world.height / 2 + 40, 104, 4)
    love.graphics.rectangle("fill", 40 + options_menu.option_2_value * 100, world.height / 2 + 32, 4, 16)
end

return options_menu
