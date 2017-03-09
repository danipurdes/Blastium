hud = {}

function drawHUD()
    --love.graphics.setColor(0,0,0,100)
    --love.graphics.rectangle("fill", 0, 0, world.width, 50)

    drawWeaponInfo(bullet_weapon.name, 10, 10,
                    bullet_weapon.firing_rate_current, bullet_weapon.firing_rate_total,
                    50, 250, 250,
                    90, 255, 255)

    drawWeaponInfo(shell_weapon.name, 10, 30,
                    shell_weapon.firing_rate_current, shell_weapon.firing_rate_total,
                    250, 50, 50,
                    255, 90, 90)

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(fonts.font_hud)
    love.graphics.printf("SCORE", 10, 10, world.width - 150, "right")
    love.graphics.printf(world.score, 10, 30, world.width - 150, "right")

    love.graphics.printf("HEALTH", 10, 10, world.width - 24, "right")
    for i=0,player.health-1 do
        love.graphics.draw(player.image, 588 - 11 - i * 20, 34, 3*math.pi/2, .5, .5, player.image:getWidth()/2, player.image:getHeight()/2)
    end

    love.graphics.setColor(50,50,50)
    for i=player.health,player.health_max-1 do
        love.graphics.draw(player.image, 588 - 11 - i * 20, 34, 3*math.pi/2, .5, .5, player.image:getWidth()/2, player.image:getHeight()/2)
    end

    --love.graphics.printf("Coins : " .. player.coins, 10, 50, world.width - 20, "right")
end

function drawWeaponInfo(name, x, y, frc, frt, r0, g0, b0, r1, g1, b1)
    love.graphics.setFont(fonts.font_hud)

    love.graphics.setColor(255,255,255)
    love.graphics.print(name, x, y)

    love.graphics.setColor(100,100,100)
    love.graphics.rectangle("fill", x + 85, y , 100, 10)

    local reload_width = (1 - frc / frt) * 100
    if reload_width > 99.99999 then
      love.graphics.setColor(r0,g0,b0)
      --love.graphics.circle("fill", x + 85 + reload_width - 14, y + 1, 14)
    else
      love.graphics.setColor(r1,g1,b1)
    end

    love.graphics.rectangle("fill", x + 85, y , reload_width, 10)
end

return hud
