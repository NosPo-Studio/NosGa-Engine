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
local credits = {
	done = false,
	credits = {
		{"--===== Biofule Machine =====--"},
		{"Game design:",
			{"BladiSagashi", "MisterNoNameLP"},
		},
		{"Art design:",
			
		},
		{"Artworks:",
			{"BladiSagashi", "DerCaptain"},
		},
		{"Programming:",
			{"MisterNoNameLP"},
		},
		
		{"--===== NosGa Engine =====--"},
		{"Programming:",
			{"MisterNoNameLP"},
		},
		
		{"--===== Thirt party =====--"},
		{"DoubleBuffering:",
			{"Igor Timofeev", "MisterNoNameLP"},
		},
		{"Image, OCIF, Color, AdvancedLua:",
			{"Igor Timofeev"},
		},
		{"Lua console:",
			{"Florian \"Sangar\" Nücke"},
		},
		{"INI parser:",
			{"Carreras Nicolas"},
		},
	},
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function credits.init()
	print("[credits]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			textures = true,
			gameObjects = true,
		},
	})
	
	print("[credits]: init done.")
end

function credits.start()
	credits.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY - global.conf.consoleSizeY -2, 
		name = "RA1", 
		drawBorders = true,
	})
	credits.done = false
	
	local _, resX, _, resY = credits.raMain:getRealFOV()
	resX, resY = resX -1, resY -1
	local ui = nil
	local buttonSizeX, buttonSizeY = 14, 3
	
	global.clear()
	
	credits.ocui = global.ocui.initiate(global.oclrl)
	ui = credits.ocui
	
	credits.bBack = ui.Button.new(ui, {
		x = 3,
		y = resY - buttonSizeY,
		sx = buttonSizeX,
		sy = buttonSizeY,
		textures = {
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x333333, 0x888888, "Back"),
			global.getButtonTexture(buttonSizeX, buttonSizeY, 0x777777, 0xaaaaaa, "Back"),
		},
		lf = function() 
			ui:draw()
			global.db.drawChanges()
			global.changeState("mainMenu") 
		end,
	})
	
	credits.goCredits = credits.raMain:addGO("Credits", {
		x = buttonSizeX +3,
		y = resY,
		resX = resX - buttonSizeX *2, 
		resY = resY,
		bc = global.backgroundColor,
		fc = 0xaaaaaa,
		credits = credits.credits,
	})
	
	--===== debug =====--
	
	--===== debug end =====--
	
end

function credits.update(dt)	
	if credits.done then
		global.changeState("mainMenu") 
	end
end

function credits.draw()
	
	
	credits.ocui:draw()
	
	global.drawDebug("BiofuleMachine: " .. global.gameVersion)
end

function credits.touch(s)
	local x, y = s[3], s[4]
	
	credits.ocui:update(x, y)
end

function credits.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
	end 
end

function credits.stop()
	if credits.raMain ~= nil then
		if credits.goCredits ~= nil then
			credits.raMain:remGO(credits.goCredits)
		end
		global.remRA(credits.raMain)
	end
end

return credits





