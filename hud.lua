hud = {}

function drawHUD()
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("fill", 0, 0, world.width, 50)

    love.graphics.setFont(world.hud_font)
    local weapon_text = ""

    weapon_text = bullet_weapon.name .. "\n"
    local hud_bullet_x = 10
    local hud_bullet_y = 10
    love.graphics.setColor(255,255,255)
    love.graphics.print(weapon_text, hud_bullet_x, hud_bullet_y)

    love.graphics.setColor(100,100,100)
    love.graphics.rectangle("fill",hud_bullet_x + 100,hud_bullet_y+5,100,10)

    local reload_width = (1 - bullet_weapon.firing_rate_current / bullet_weapon.firing_rate_total) * 100
    if reload_width > 99.99999 then
      love.graphics.setColor(50,250,250)
    else
      love.graphics.setColor(90,255,255)
    end

    love.graphics.rectangle("fill",hud_bullet_x + 100,hud_bullet_y+5,reload_width,10)

    weapon_text = shell_weapon.name .. "\n"
    local hud_shell_x = 10
    local hud_shell_y = 30
    love.graphics.setColor(255,255,255)
    love.graphics.print(weapon_text, hud_shell_x, hud_shell_y)

    love.graphics.setColor(100,100,100)
    love.graphics.rectangle("fill",hud_shell_x + 100, hud_shell_y+5,100,10)

    reload_width = (1 - shell_weapon.firing_rate_current / shell_weapon.firing_rate_total) * 100
    if reload_width > 99.99999 then
      love.graphics.setColor(250,50,50)
    else
      love.graphics.setColor(255,90,90)
    end

    love.graphics.rectangle("fill",hud_shell_x + 100,hud_shell_y+5,reload_width,10)

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(world.text_font)
    love.graphics.printf("Score : " .. world.score, 10, 10, world.width - 20, "right")
end

return hud
