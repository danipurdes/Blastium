audio = {}
audio.volume_max = .5
audio.volume_current = .5
audio.music = love.audio.newSource("assets/audio/Busy Signal - Beatwave.wav")
audio.mute = false

function toggleMute()
    audio.mute = not audio.mute
    if audio.mute then
        love.audio.setVolume(0)
        audio.volume_current = 0
    else
        love.audio.setVolume(audio.volume_max)
        audio.volume_current = audio.volume_max
    end
end

return audio
