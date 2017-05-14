highscore = {}

highscore.score = 10000
highscore.name = "PABLO"

highscore.save_contents = ""

function loadHighscores()
    if not love.filesystem.exists("data.txt") then
        love.filesystem.write("data.txt","10000 PABLO")
    end
    highscore.save_contents = love.filesystem.read("data.txt")
    local pair = str_explode(highscore.save_contents, " ")
    highscore.score = tonumber(pair[1])
    highscore.name = pair[2]
end

function writeHighscore()
    local data = highscore.score .. " " .. "HANKR"
    love.filesystem.write("data.txt", data)
end

function str_explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end

return highscore
