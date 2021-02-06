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
global.gameVersion = "v0.0.12d"

--===== shared vars =====--
local game = {
	stats = global.stats,
	cameraOffsetX = 0,
	cameraOffsetY = 23,
	ui = {},
	ocui = {},
	maxDistance = 0,
	lines = 3,
	streetWidth = 9,
	
	runIsRunning = true,
	
	firstRun = true --debug
}

--===== local vars =====--
local t = false
local c = 0
local transparencyColor = 0x00ffff

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function game.init()
	print("[game]: Start init.")
	
	--global.debugDisplayPosY = global.resY
	global.debugDisplayPosY = global.resY - 6
	
	global.loadGame()
	
	--===== debug =====--
	--[[
	package.loaded["libs/thirdParty/DoubleBuffering"] = nil
	global.db = require("libs/thirdParty/DoubleBuffering")
	
	package.loaded["libs/dbgpu_api"] = nil
	global.gpu = loadfile("libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})
	
	package.loaded["libs/ocal"] = nil
	global.ocal = require("libs/ocal").initiate({oclrl = global.oclrl, db = global.db, libs = "libs/thirdParty"})
	
	]]
	
	package.loaded["libs/ocgf"] = nil
	global.ocgf = dofile("libs/ocgf.lua").initiate({gpu = global.gpu, db = global.db, oclrl = global.oclrl, ocal = global.ocal})
	
	global.worldHandler = nil
	global.worldHandler = loadfile("data/global/worldHandler.lua")(global)
	
	global.gameObject.Player = nil
	--global.gameObject.Player = loadfile("data/gameObjects/Player.lua")(global)
	
	t1, t2 = nil, nil
	
	--===== debug end =====--
	
	print("[game]: init done.")
end

function game.start()
	local resX, resY = global.resX, global.resY
	
	global.load({
		toLoad = {
			parents = true,
			gameObjects = true,
			structuredGameObjects = true,
			textures = true,
			animations = true,
		},
	})
	
	for i, c in pairs(global.texture) do
		if c.format == "pic" then
			global.makeImageTransparent(c, transparencyColor)
		end
	end
	
	global.clear()
	
	game.ocui = global.ocui.initiate(global.oclrl)
	game.ui.speed = game.ocui.Bar.new(game.ocui, {posX = 10, posY = resY -5, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	game.ui.armor = game.ocui.Bar.new(game.ocui, {posX = 10, posY = resY -3, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	
	game.ui.fuel = game.ocui.Bar.new(game.ocui, {posX = global.resX / 2 + 9, posY = resY -5, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	game.ui.life = game.ocui.Bar.new(game.ocui, {posX = global.resX / 2 + 9, posY = resY -3, sizeX = global.resX / 2 - 10, sizeY = 1, clickable = false})
	
	game.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY - 7, 
		name = "RA1", 
		drawBorders = false,
	})
	
	game.goPlayer = game.raMain:addGO("Player", {
		posX = 10, 
		posY = 11, 
		layer = 4, 
		name = "player", 
		stats = game.stats,
	})
	
	if global.conf.particles > 0 then
		game.pcDefaultParticleContainer = game.raMain:addGO("DefaultParticleContainer", {})
		game.goPlayer.particleContainer = game.pcDefaultParticleContainer
	end
	
	--global.worldHandler.start(game, -7, "test")
	game.reset()
	
	--===== debug =====--
	
	--===== debug end =====--
	
end

function game.update(dt)	
	game.goPlayer.test = true
	
	--game.goPlayer:move(10 * dt, 0)
	--game.raMain:moveCamera(20 * dt, 0)
	
	
	--game.goPlayer.driving = true
	--global.event.pull("key_down")
	
	local x, y = game.goPlayer:getPos()
	local speed = select(1, game.goPlayer:getSpeed())
	
	game.ui.speed:setStatus(math.abs(speed) / game.stats.maxSpeed / 1.5)
	game.ui.fuel:setStatus(game.goPlayer.fuel / game.stats.fuelTank)
	game.ui.life:setStatus(game.goPlayer.life / game.stats.life)
	game.ui.armor:setStatus(game.goPlayer.armor / game.stats.armor)
	
	global.worldHandler.update()
	
	if game.goPlayer.life <= 0 and game.runIsRunning then
		game.runIsRunning = false
	elseif not game.runIsRunning and game.goPlayer:getSpeed() <= 0 and game.goScoreScreen == nil then
		game.goScoreScreen = game.raMain:addGO("ScoreScreen", {
			money = game.goPlayer.moneyEarned,
			fuel = game.goPlayer.fuelEarned,
			distance = select(1, game.goPlayer:getPos()),
			uiHeight = 7,
		})
	end
	
	--print("=====New frame=====")
	while game.pause do
		os.sleep(.1)
		if global.keyboard.isKeyDown("z") or global.keyboard.isKeyDown(60) or global.keyboard.isKeyDown(63) or global.keyboard.isControlDown() then
			game.pause = not game.pause
		end
	end
end

function game.ctrl_pause_key_down(s, sname)
	game.pause = not game.pause
end

function game.draw()
	
	if false then
		if not game.firstRun then
			if not game.pause then
				global.computer.pushSignal(global.event.pull("key_down"))
				global.log("===========================================================================")
			end
		else
			game.firstRun = false
			global.conf.debug.reDebug = true
		end
		
		if false then
			global.gpu.setBackground(0x0)
			global.gpu.fill(0, 0, global.resX, global.resY, " ")
			global.db.drawChanges()
			--os.sleep(.1)
		end
	end
	
	
	local resX, resY = global.resX, global.resY
	game.maxDistance = math.max(game.goPlayer:getPos(), game.maxDistance)
	
	global.gpu.setBackground(global.conf.uiBackgroundColor)
	global.gpu.setForeground(global.conf.uiForegroundColor)
	global.gpu.fill(1, resY - 6, global.resX, 7, " ")
	global.gpu.set(3, resY - 5, "Speed:")
	global.gpu.set(global.resX / 2 + 3, resY -5, "Fuel:")
	global.gpu.set(3, resY - 3, "Armor:")
	global.gpu.set(global.resX / 2 + 3, resY - 3, "Life:")
	
	global.gpu.set(global.resX / 2 - 10, resY - 1, "Max distance: " .. tostring(game.maxDistance))
	
	game.ocui:draw()
	
	global.drawDebug("BiofuleMachine: " .. global.gameVersion)
end

function game.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		
		if true then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
		
	end 
end

function game.reset()
	global.saveGame()
	
	global.worldHandler.reset()
	
	game.raMain:remGO(game.goPlayer)
	game.raMain:remGO(game.goScoreScreen)
	game.goScoreScreen = nil
	
	for go in pairs(game.raMain.gameObjects) do
		if go.isIngameObject then
			game.raMain:remGO(go)
		end
	end
	
	game.goPlayer = game.raMain:addGO("Player", {
		posX = 10, 
		posY = 11, 
		layer = 4, 
		name = "player", 
		stats = game.stats,
	})
	
	game.raMain:moveCameraTo(game.goPlayer:getPos() + game.cameraOffsetX, game.cameraOffsetY)
	
	global.worldHandler.start(game, -7, "test") --ToDo, bug: camera pos not updated instantly.
	
	game.runIsRunning = true
end

function game.ctrl_reset_key_down()
	game.reset()
end
function game.ctrl_garage_key_down(s, sname)
	if not game.runIsRunning then
		global.changeState("garage")
	end
end

function game.ctrl_camLeft_key_pressed()
	game.raMain:moveCamera(- 10 * global.dt, 0)
end
function game.ctrl_camRight_key_pressed()
	game.raMain:moveCamera(10 * global.dt, 0)
end

function game.stop()
	if game.raMain ~= nil then
		for go in pairs(game.raMain.gameObjects) do
			game.raMain:remGO(go)
		end
	end
end

return game





