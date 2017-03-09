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

fonts.font_text = love.graphics.newImageFont("assets/images/font_text_x2.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-", 2)

fonts.font_hud = love.graphics.newImageFont("assets/images/font_title.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 2)

fonts.font_title = love.graphics.newImageFont("assets/images/font_title_x2.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 4)

return fonts
