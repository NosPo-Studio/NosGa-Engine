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
local garage = {
	uiUpgrades = {},
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function garage.init()
	print("[garage]: Start init.")
	
	global.loadGame()
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			textures = true,
			gameObjects = true,
		},
	})
	
	print("[garage]: init done.")
end

function garage.start()
	garage.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY, 
		name = "RA1", 
		drawBorders = true,
	})
	local _, resX, _, resY = garage.raMain:getRealFOV()
	resX, resY = resX -1, resY -1
	garage.ocui = global.ocui.initiate(global.oclrl)
	local ui = garage.ocui
	local buttonSizeX, buttonSizeY = 30, 3
	local buttons = 3
	local posY = resY / 3 - buttons * (buttonSizeY + 1)
	local colors = global.conf.colors
	
	global.clear()
	
	--[[
		Speed.
		Life.
		Armor.
		Tank.
		Damage.
		Traction.
		FuelConsuption.
	]]
	
	
	garage.uiUpgrades.uSpeed = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 1 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "speed",
		statName = "Speed",
		colors = colors,
	})
	garage.uiUpgrades.uLife = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 2 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "life",
		statName = "Life",
		colors = colors,
	})
	garage.uiUpgrades.uArmor = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 3 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "armor",
		statName = "Armor",
		colors = colors,
	})
	garage.uiUpgrades.uTank = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 4 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "tank",
		statName = "Tank",
		colors = colors,
	})
	garage.uiUpgrades.uDamage = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 5 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "damage",
		statName = "Damage",
		colors = colors,
	})
	garage.uiUpgrades.uTraction = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 6 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "traction",
		statName = "Traction",
		colors = colors,
	})
	garage.uiUpgrades.uFuelConsuption = garage.raMain:addGO("Upgrade", {
		x = resX / 2 - buttonSizeX / 2,
		y = posY + 7 * (buttonSizeY + 1),
		buttonSizeX = buttonSizeX, 
		buttonSizeY = buttonSizeY,
		stat = "fuelConsuption",
		statName = "Fuel consuption",
		colors = colors,
	})
	
	
	garage.bBack = ui.Button.new(ui, {
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
	garage.bPlay = ui.Button.new(ui, {
		x = resX - buttonSizeX - 1,
		y = resY - buttonSizeY,
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
	
	--===== debug =====--
	
	--===== debug end =====--
	
end

function garage.update(dt)	
	
end

function garage.draw()
	global.gpu.fill(global.resX / 2 - 2 - global.unicode.len(tostring(global.stats.player.money)) / 2, 2, 11 + global.unicode.len(tostring(global.stats.player.money)), 3, " ")
	global.gpu.set(global.resX / 2 - global.unicode.len(tostring(global.stats.player.money)) / 2, 3, "Money: " .. tostring(global.stats.player.money))
	
	garage.ocui:draw()
	
	global.drawDebug("BiofuleMachine: " .. global.gameVersion)
end

function garage.touch(s)
	local x, y = s[3], s[4]
	
	garage.ocui:update(x, y)
end

function garage.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
	end 
end

function garage.stop()
	global.saveGame()
	if garage.raMain ~= nil then
		for go in pairs(garage.raMain.gameObjects) do
			go:destroy()
		end
		global.remRA(garage.raMain)
	end
	if garage.ocui ~= nil then
		garage.ocui:stop()
	end
end

return garage





