credits_menu = {}

credits_menu.love_logo = love.graphics.newImage("assets/images/love-logo-0.10-small-white.png")

function keypressedCreditsMenu(key)
    if key == "space" then
        worldStateChange(world.previous_state)
        menuIndexSelect()
    end
end

function drawCreditsMenu(origin_x, origin_y)
    drawStarfield(origin_x, origin_y)

    love.graphics.setColor(100,100,100,100)
    love.graphics.rectangle("fill", origin_x, origin_y, world.width, world.height)

    love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill", origin_x + 50, origin_y + 50, 500, 500)
    love.graphics.rectangle("line", origin_x + 46, origin_y + 46, 508, 508)
    love.graphics.rectangle("line", origin_x + 47, origin_y + 47, 506, 506)

    love.graphics.setColor(255,255,255)

    --love.graphics.setFont(fonts.font_title)
    --love.graphics.printf(world.name, 0, 85, world.width, "center")
    love.graphics.draw(world.logo, origin_x + 300, origin_y + 124, 0, 4, 4, world.logo:getWidth()/2, world.logo:getHeight()/2)

    love.graphics.setFont(fonts.font_text)
    love.graphics.printf("- DEVELOPER -", 0, 190, world.width, "center")
    love.graphics.printf("DANIELLE PURDES", 0, 210, world.width, "center")

    love.graphics.printf("- TECHNICAL CONSULTANT -", origin_x, origin_y + 250, world.width, "center")
    love.graphics.printf("SCOTT MUNRO", origin_x, origin_y + 270, world.width, "center")

    love.graphics.printf("- PIXEL FONT DESIGNER -", origin_x, origin_y + 310, world.width, "center")
    love.graphics.printf("CHRIS EARLY", origin_x, origin_y + 330, world.width, "center")

    love.graphics.printf("MADE WITH", origin_x, origin_y + 420, world.width, "center")
    love.graphics.draw(credits_menu.love_logo, origin_x + world.width/2 - credits_menu.love_logo:getWidth()/2, origin_y + 440)
    love.graphics.printf("LOVE2D.ORG", origin_x, origin_y + 500, world.width, "center")

    love.graphics.printf("PRESS SPACE TO RETURN", origin_x, origin_y + world.height - 30, world.width, "center")
end

return credits_menu
