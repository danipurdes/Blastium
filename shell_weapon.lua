shell_weapon = {}
shell_weapon.name = "MOONSHOT"
shell_weapon.shots = {}
shell_weapon.ammo_max = 15
shell_weapon.ammo_current = 15
shell_weapon.firing_rate_total = 1.2
shell_weapon.firing_rate_current = 1.2
shell_weapon.sound = love.audio.newSource("assets/audio/shoot_shell.wav","static")
shell_weapon.index = 1
shell_weapon.removal_flag = false

function updateShellWeapon(dt)
    for i=#shell_weapon.shots,1,-1 do
      local v = shell_weapon.shots[i]
      v.x = v.x + dt * math.cos(v.rotation) * v.tvel
      v.y = v.y + dt * math.sin(v.rotation) * v.tvel

      v.lifespan = v.lifespan - dt

      if v.lifespan <= 0 then
        table.remove(shell_weapon.shots, i)
      elseif v.x < -10 or v.x > world.width + 10 or v.y < -10 or v.y > world.height + 10 then
        table.remove(bullet_weapon.shots, i)
      end
    end
end

function fire_shell_weapon()
    if shell_weapon.ammo_current > 0 and shell_weapon.firing_rate_current <= 0 then
        local times = shell_weapon.firing_rate_current
        while times <= 0 and shell_weapon.ammo_current > 0 do
            player.xvel = player.xvel - shell_round.mass * math.cos(player.rotation)
            player.yvel = player.yvel - shell_round.mass * math.sin(player.rotation)

            for i = 0, 9 do
                local shot = {}
                shot.x = player.x
                shot.y = player.y
                local spread = 200
                shot.rotation = player.rotation - spread/2 * (math.pi/180) + spread * (i/9) * (math.pi/180)

                local txv = shell_round.velocity * math.cos(shot.rotation) + math.abs(player.xvel) * math.cos(player.rotation)
                local tyv = shell_round.velocity * math.sin(shot.rotation) + math.abs(player.yvel) * math.sin(player.rotation)
                shot.tvel = math.sqrt(math.pow(txv,2) + math.pow(tyv,2))

                shot.lifespan = shell_round.lifespan
                --shell_weapon.shots[#shell_weapon.shots+1] = shot
                table.insert(shell_weapon.shots, shot)
            end

            --shell_weapon.shots[#shell_weapon.shots+1] = shot

            --shell_weapon.ammo_current = shell_weapon.ammo_current - 1
            times = times + shell_weapon.firing_rate_total
        end

        shell_weapon.firing_rate_current = times

        love.audio.play(shell_weapon.sound)
    end
end

function drawShellRounds(origin_x, origin_y)
    for i,v in ipairs(shell_weapon.shots) do
      love.graphics.draw(shell_round.image, origin_x + v.x, origin_y + v.y, v.rotation, 1, 1, shell_round.image:getWidth()/2, shell_round.image:getHeight()/2)
    end
end

return shell_weapon
