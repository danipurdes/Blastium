fonts = {}

fonts.font_text = love.graphics.newImageFont("assets/images/font_text_x2.png",
    " ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-.", 2)

fonts.font_hud = love.graphics.newImageFont("assets/images/font_title.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 2)

fonts.font_title = love.graphics.newImageFont("assets/images/font_title_x2.png",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 4)

return fonts
