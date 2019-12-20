local fs = require("filesystem")
local gpu = require("component").gpu
local ocgl = require("libs/ocgl").initiate(gpu)
local term = require("term")
local keyboard = require("keyboard")
local event = require("event")

term.clear()

local texture = "pig"

local global = {conf = {texturePack = "default"}, fs = fs, shell = require("shell")}

while true do
	gpu.setBackground(0x000000)
	gpu.fill(1, 1, 1000, 1000, " ")
	
	local t = nil
	while t == nil do
		t = dofile("mods/exampleMod/textures/" .. texture .. ".lua")
		os.sleep()
	end
	
	ocgl:draw(2, 10, t)
	
	for c = 0, 90, 6 do
		ocgl:draw(15 +c, 10, t)
	end
	
	if keyboard.isKeyDown("r") then
		gpu.setBackground(0x000000)
		gpu.fill(1, 1, 1000, 1000, " ")
	end
	
	os.sleep(.01)
end
