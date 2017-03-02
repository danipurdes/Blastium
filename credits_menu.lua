credits_menu = {}

credits_menu.love_logo = love.graphics.newImage("assets/images/love-logo-0.10-small-white.png")

function keypressedCreditsMenu(key)
    if key == "space" then
        worldStateChange(world.previous_state)
    end
end

function drawCreditsMenu()
    drawStarfield()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", 50, 50, 500, 500)

    love.graphics.setColor(255,255,255)

    love.graphics.setFont(fonts.title_font)
    love.graphics.printf(world.name, 0, 85, world.width, "center")

    love.graphics.setFont(fonts.text_font)

    love.graphics.printf("- Developer -", 0, 190, world.width, "center")
    love.graphics.printf("Daniel Purdes", 0, 210, world.width, "center")

    love.graphics.printf("- Technical Consultant -", 0, 250, world.width, "center")
    love.graphics.printf("Scott Munro", 0, 270, world.width, "center")

    love.graphics.printf("- Fonts -", 0, 310, world.width, "center")
    love.graphics.printf("Chris Early", 0, 330, world.width, "center")
    love.graphics.printf("Made with", 0, 420, world.width, "center")
    love.graphics.draw(credits_menu.love_logo, world.width/2 - credits_menu.love_logo:getWidth()/2, 440)
end

return credits_menu
