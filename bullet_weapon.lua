bullet_weapon = {}
bullet_weapon.name = "BLASTER"
bullet_weapon.shots = {}
bullet_weapon.ammo_max = 25
bullet_weapon.ammo_current = 25
bullet_weapon.firing_rate_total = .3
bullet_weapon.firing_rate_current = .3
bullet_weapon.sound = love.audio.newSource("assets/audio/shoot_bullet.wav","static")
bullet_weapon.index = 0

function fire_bullet_weapon()
    if bullet_weapon.ammo_current > 0 and bullet_weapon.firing_rate_current <= 0 then
        local times = bullet_weapon.firing_rate_current
        while times <= 0 and bullet_weapon.ammo_current > 0 do
            local tv = math.sqrt(player.xvel * player.xvel + player.yvel * player.yvel) + bullet_round.velocity

            --player.xvel = player.xvel - bullet_round.mass * math.cos(player.rotation)
            --player.yvel = player.yvel - bullet_round.mass * math.sin(player.rotation)

            local shot1 = {}
            shot1.x = player.x + 14 * math.cos(player.rotation - 90)
            shot1.y = player.y + 14 * math.sin(player.rotation - 90)
            shot1.tvel = tv
            shot1.rotation = player.rotation

            local txv = bullet_round.velocity * math.cos(shot1.rotation) + math.abs(player.xvel) * math.cos(player.rotation)
            local tyv = bullet_round.velocity * math.sin(shot1.rotation) + math.abs(player.yvel) * math.sin(player.rotation)
            shot1.tvel = math.sqrt(math.pow(txv,2) + math.pow(tyv,2))

            shot1.lifespan = bullet_round.lifespan
            table.insert(bullet_weapon.shots, shot1)

            local shot2 = {}
            shot2.x = player.x + 14 * math.cos(player.rotation + 90)
            shot2.y = player.y + 14 * math.sin(player.rotation + 90)
            shot2.rotation = player.rotation

            local txv = bullet_round.velocity * math.cos(shot2.rotation) + math.abs(player.xvel) * math.cos(player.rotation)
            local tyv = bullet_round.velocity * math.sin(shot2.rotation) + math.abs(player.yvel) * math.sin(player.rotation)
            shot2.tvel = math.sqrt(math.pow(txv,2) + math.pow(tyv,2))

            shot2.lifespan = bullet_round.lifespan
            table.insert(bullet_weapon.shots, shot2)

            --bullet_weapon.ammo_current = bullet_weapon.ammo_current - 1
            times = times + bullet_weapon.firing_rate_total
        end

        bullet_weapon.firing_rate_current = times

        love.audio.play(bullet_weapon.sound)
    end
end

return bullet_weapon
