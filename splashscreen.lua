splashscreen = {}

splashscreen.donny_logo = love.graphics.newImage("assets/images/keyboard_icon.png")
splashscreen.reveal_alpha = 255
splashscreen.reveal_timer = 5
splashscreen.reveal_cooldown = 5

function updateSplashscreen(dt)
    splashscreen.reveal_timer = splashscreen.reveal_timer - dt
    splashscreen.reveal_alpha = 255 - (255 * splashscreen.reveal_timer / splashscreen.reveal_cooldown)
    if splashscreen.reveal_timer <= 0 then
        worldStateChange("start/open")
    end
end

function drawSplashscreen()
    drawStarfield()
    love.graphics.setColor(255,255,255,splashscreen.reveal_alpha)
    love.graphics.draw(splashscreen.donny_logo, 300,300, 0, 4, 4, splashscreen.donny_logo:getWidth()/2, splashscreen.donny_logo:getHeight()/2)

    love.graphics.setFont(fonts.font_text)
    love.graphics.setColor(255,255,255,255)
    love.graphics.printf("GAME REQUIRES KEYBOARD", 0, 300 + 20 + 2*splashscreen.donny_logo:getHeight(), world.width, "center")
end

return splashscreen
