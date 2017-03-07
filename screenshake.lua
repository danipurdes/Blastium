screenshake = {}

screenshake.active = false
screenshake.magnitude = 2
screenshake.current_magnitude = 0
screenshake.lifespan = 1
screenshake.period = 0.01
screenshake.age = 0

function updateScreenshake(dt)
    if screenshake.active then
      screenshake.age = screenshake.age + dt
      screenshake.current_magnitude = screenshake.magnitude * math.exp(-(screenshake.age*2)) * math.sin((1/screenshake.period) * math.pi * (screenshake.age/screenshake.lifespan))
      if screenshake.age > screenshake.lifespan then
          screenshake.active = false
          resetScreenshake()
      end
    end
end

function initiateScreenshake()
    screenshake.active = true
    resetScreenshake()
end

function resetScreenshake()
    screenshake.age = 0
    screenshake.current_magnitude = 0
end

return screenshake
