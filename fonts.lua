fonts = {}

fonts.title_font = love.graphics.newImageFont("assets/images/title_font.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ ",
    8)

fonts.text_font = love.graphics.newImageFont("assets/images/example_font_inverted_monospace.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"",
    2)

fonts.hud_font = love.graphics.newImageFont("assets/images/thinpixelfont.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ", 1)

return fonts
