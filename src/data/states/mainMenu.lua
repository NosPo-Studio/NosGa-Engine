--[[
    This file is part of the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019-2020 NosPo Studio

    The NosGa Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The NosGa Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the NosGa Engine.  If not, see <https://www.gnu.org/licenses/>.
]]

local global = ...

--===== shared vars =====--
local mainMenu = {
	
}

--===== local vars =====--
local t = false
local c = 0

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function mainMenu.init()
	print("[mainMenu]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			textures = true,
		},
	})
	
	print("[mainMenu]: init done.")
end

function mainMenu.start()
	mainMenu.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY - global.conf.consoleSizeY -2, 
		name = "RA1", 
		drawBorders = true,
	})
	
	local _, resX, _, resY = mainMenu.raMain:getRealFOV()
	resX, resY = resX -1, resY -1
	local ui = nil
	local buttonSizeX, buttonSizeY = 14, 3
	local buttons = 3
	local posY = resY / 2 - buttons * (buttonSizeY + 1)
	
	global.clear()
	
	mainMenu.ocui = global.ocui.initiate(global.oclrl)
	ui = mainMenu.ocui
	
	mainMenu.bPlay = ui.Button.new(ui, {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 1 * (buttonSizeY + 1),
		sx = buttonSizeX,
		sy = buttonSizeY,
		textures = {
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x333333, 0x888888, "Play"),
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x777777, 0xaaaaaa, "Play"),
		},
		lf = function() 
			ui:draw()
			global.db.drawChanges()
			global.changeState("game") 
		end,
	})
	mainMenu.bGarage = ui.Button.new(ui, {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 2 * (buttonSizeY + 1),
		sx = buttonSizeX,
		sy = buttonSizeY,
		textures = {
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x333333, 0x888888, "Garage"),
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x777777, 0xaaaaaa, "Garage"),
		},
		lf = function() 
			ui:draw()
			global.db.drawChanges()
			global.changeState("garage") 
		end,
	})
	mainMenu.bCredits = ui.Button.new(ui, {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 3 * (buttonSizeY + 1),
		sx = buttonSizeX,
		sy = buttonSizeY,
		textures = {
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x333333, 0x888888, "Credits"),
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x777777, 0xaaaaaa, "Credits"),
		},
		lf = function() 
			ui:draw()
			global.db.drawChanges()
			global.changeState("credits") 
		end,
	})
	mainMenu.bQuit = ui.Button.new(ui, {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 4 * (buttonSizeY + 1),
		sx = buttonSizeX,
		sy = buttonSizeY,
		textures = {
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x333333, 0x888888, "Quit"),
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x777777, 0xaaaaaa, "Quit"),
		},
		lf = function() 
			global.isRunning = false
		end,
	})
	
	
	--===== debug =====--
	
	--===== debug end =====--
	
end

function mainMenu.update(dt)	
	
	
	while mainMenu.pause do
		os.sleep(.1)
		if global.keyboard.isKeyDown("z") or global.keyboard.isKeyDown(60) or global.keyboard.isKeyDown(63) or global.keyboard.isControlDown() then
			mainMenu.pause = not mainMenu.pause
		end
	end
end

function mainMenu.ctrl_pause_key_down(s, sname)
	mainMenu.pause = true
end

function mainMenu.draw()
	
	
	mainMenu.ocui:draw()
	
	global.drawDebug("BiofuleMachine: " .. global.gameVersion)
end

function mainMenu.touch(s)
	local x, y = s[3], s[4]
	
	mainMenu.ocui:update(x, y)
end

function mainMenu.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
	end 
end

function mainMenu.stop()
	if mainMenu.raMain ~= nil then
		global.remRA(mainMenu.raMain)
	end
	if mainMenu.ocui ~= nil then
		mainMenu.ocui:stop()
	end
end

return mainMenu





