audio = {}
audio.volume_max = .5
audio.volume_current = .5
audio.music = love.audio.newSource("assets/audio/Busy Signal - Beatwave.wav")
audio.mute = false
audio.icon_sound = love.graphics.newImage("assets/images/icon_sound.png")
audio.icon_nosound = love.graphics.newImage("assets/images/icon_nosound.png")
audio.icon_alpha = 255
audio.icon_alpha_cooldown = .75
audio.icon_alpha_timer = 0
audio.icon_alpha_sustain_cooldown = 1
audio.icon_alpha_sustain_timer = 0

function toggleMute()
    audio.mute = not audio.mute
    if audio.mute then
        love.audio.setVolume(0)
        audio.volume_current = 0
    else
        love.audio.setVolume(audio.volume_max)
        audio.volume_current = audio.volume_max
    end

    audio.icon_alpha_sustain_timer = audio.icon_alpha_sustain_cooldown
end

function updateAudioIcon(dt)
    if audio.icon_alpha_timer > 0 then
        audio.icon_alpha_timer = audio.icon_alpha_timer - dt
        if audio.icon_alpha_timer <= 0 then
            audio.icon_alpha_timer = 0
        end
    end

    if audio.icon_alpha_sustain_timer > 0 then
        audio.icon_alpha_sustain_timer = audio.icon_alpha_sustain_timer - dt
        if audio.icon_alpha_sustain_timer <= 0 then
            audio.icon_alpha_sustain_timer = 0
            audio.icon_alpha_timer = audio.icon_alpha_cooldown
        end
    end
end

function drawAudioIcon()
    local sound_icon
    if audio.mute then
        sound_icon = audio.icon_nosound
    else
        sound_icon = audio.icon_sound
    end

    local ix = 564
    local iy = 560

    if audio.icon_alpha_sustain_timer > 0 then
        love.graphics.setColor(255,255,255,255)
    else
        love.graphics.setColor(255,255,255,math.floor(255*(audio.icon_alpha_timer/audio.icon_alpha_cooldown)))
    end

    love.graphics.draw(sound_icon, ix, iy)
end

return audio
