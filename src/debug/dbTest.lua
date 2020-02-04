local term = require("term")
local db = require("libs/thirdParty/DoubleBuffering")
local image = require("libs/thirdParty/image")
local texture = image.load("texturePacks/default/textures/test.pic")

term.clear()

db.drawRectangle(1, 1, 1000, 1000, 0x000000, 0x000000, " ")

for c = 0, 10 do
	db.drawImage(10 +c *10, 10, texture)
	
end


db.drawChanges()
