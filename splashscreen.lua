splashscreen = {}

splashscreen.keyboard_icon = love.graphics.newImage("assets/images/keyboard_icon.png")
splashscreen.reveal_alpha = 255
splashscreen.reveal_timer = 5
splashscreen.reveal_cooldown = 5

function updateSplashscreen(dt)
    splashscreen.reveal_timer = splashscreen.reveal_timer - dt
    local alp = 255 * math.sin(math.pi * (splashscreen.reveal_cooldown - splashscreen.reveal_timer)/splashscreen.reveal_cooldown)
    splashscreen.reveal_alpha = alp --255 - (255 * splashscreen.reveal_timer / splashscreen.reveal_cooldown)
    if splashscreen.reveal_timer <= 0 then
        worldStateChange("start/open")
    end
end

function drawSplashscreen()
    drawStarfield()
    love.graphics.setColor(255,255,255,splashscreen.reveal_alpha)
    love.graphics.draw(splashscreen.keyboard_icon, 300,300, 0, 4, 4, splashscreen.keyboard_icon:getWidth()/2, splashscreen.keyboard_icon:getHeight()/2)

    love.graphics.setFont(fonts.font_text)
    love.graphics.setColor(255,255,255,splashscreen.reveal_alpha)
    love.graphics.printf("GAME REQUIRES KEYBOARD", 0, 300 + 20 + 2*splashscreen.keyboard_icon:getHeight(), world.width, "center")
end

return splashscreen
