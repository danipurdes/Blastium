credits_menu = {}

credits_menu.love_logo = love.graphics.newImage("assets/images/love-logo-0.10-small-white.png")

function keypressedCreditsMenu(key)
    if key == "space" then
        worldStateChange(world.previous_state)
        menuIndexSelect()
    end
end

function drawCreditsMenu()
    drawStarfield()

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", 0, 0, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", 50, 50, 500, 500)
    love.graphics.rectangle("line", 46, 46, 508, 508)
    love.graphics.rectangle("line", 47, 47, 506, 506)

    love.graphics.setColor(255,255,255)

    --love.graphics.setFont(fonts.font_title)
    --love.graphics.printf(world.name, 0, 85, world.width, "center")
    love.graphics.draw(world.logo, 300, 124, 0, 4, 4, world.logo:getWidth()/2, world.logo:getHeight()/2)

    love.graphics.setFont(fonts.font_text)

    love.graphics.printf("- DEVELOPER -", 0, 190, world.width, "center")
    love.graphics.printf("DANNY PURDES", 0, 210, world.width, "center")

    love.graphics.printf("- TECHNICAL CONSULTANT -", 0, 250, world.width, "center")
    love.graphics.printf("SCOTT MUNRO", 0, 270, world.width, "center")

    love.graphics.printf("- PIXEL FONT DESIGNER -", 0, 310, world.width, "center")
    love.graphics.printf("CHRIS EARLY", 0, 330, world.width, "center")

    love.graphics.printf("MADE WITH", 0, 420, world.width, "center")
    love.graphics.draw(credits_menu.love_logo, world.width/2 - credits_menu.love_logo:getWidth()/2, 440)
    love.graphics.printf("LOVE2D.ORG", 0, 500, world.width, "center")

    love.graphics.printf("PRESS SPACE TO RETURN", 0, world.height - 30, world.width, "center")
end

return credits_menu
