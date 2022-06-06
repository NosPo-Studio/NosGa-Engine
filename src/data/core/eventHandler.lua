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
local eh = {}

--===== local variables =====--
local pressedKeys = {}
local specialPressedKeys = {}

--===== local functions =====--
local function print(...)
	if global.conf.debug.ehDebug then
		global.debug.log(...)
	end
end

local function exportCtrlSignal(s, sname)
	local generalFunctionName = ""
	local specificFunctionName = ""
	
	local function callFunctions(f, sname)
		if f == nil then return false end
		
		for _, f in pairs(f) do
			generalFunctionName = "ctrl_" .. f
			specificFunctionName = generalFunctionName .. "_" .. sname
			
			if generalFunctionName ~= "" then
				global.run(global.state[global.currentState][generalFunctionName], s, sname)
				global.core.updateHandler.insertSignal(s, generalFunctionName)
				
				global.run(global.state[global.currentState][specificFunctionName], s, sname)
				global.core.updateHandler.insertSignal(s, specificFunctionName)
			end
		end
	end
	
	if sname == "key_down" or sname == "key_pressed" or sname == "key_up" then
		if global.controls.c[s[3]] then
			callFunctions(global.controls.c[s[3]], sname)
		elseif global.controls.k[s[4]] then
			callFunctions(global.controls.k[s[4]], sname)
		end
	elseif sname == "touch" or sname == "drag" or sname == "drop" then
		if global.controls.m[s[5]] then
			callFunctions(global.controls.m[s[5]], sname)
		end
	end
end

local function exportSignal(s, sname)
	sname = sname or s[1]
	
	if global.state[global.currentState] ~= nil then
		global.run(global.state[global.currentState][sname], s)
	end
	global.core.updateHandler.insertSignal(s, sname)
	
	exportCtrlSignal(s, sname)
end

local function parseSignal(signal)
	if #signal == 0 then return false end
	if global.tiConsole.status == true then
		if signal[1] == "key_down" or signal[1] == "key_up" then
			return true
		end
	end
	
	if global.conf.showConsole and signal[1] == "touch" then
		global.mConsole:update(signal[3], signal[4])
	end
	
	global.run(global.core.eventHandler[signal[1]], signal)
	
	if signal[1] ~= "key_down" then
		exportSignal(signal)
	end
	
	return true
end

--===== global functions =====--
function eh.init()
	
end

function eh.update(sleepTime)	
	local signal = {true}
	
	while parseSignal({global.computer.pullSignal(0)}) do end
	
	local maxDT = 1 / global.conf.targetFramerate
	
	global.dt = global.computer.uptime() - global.lastUptime
	
	if global.conf.targetFramerate ~= -1 and global.dt < maxDT then
		parseSignal({global.event.pull((1 / global.conf.targetFramerate) - math.max(global.dt - (1 / global.conf.targetFramerate), 0))})
	end
	
	global.dt = global.computer.uptime() - global.lastUptime
	if global.dt > global.conf.maxTickTime then
		if global.isDev then
			global.warn("Tick take too long: F: " .. tostring(global.currentFrame) .. ", T: " .. tostring(global.dt))
		end
		global.dt = global.conf.maxTickTime
	end
	global.lastUptime = global.computer.uptime()
	
	if global.tiConsole.status == false then
		for i, s in pairs(pressedKeys) do
			exportSignal(s, "key_pressed")
		end
		for i, s in pairs(specialPressedKeys) do
			exportSignal(s, "key_pressed")
		end
	end
end

function eh.touch(s)
	global.ocui:update(s[3], s[4])
	--run(global.state[global.currentState].touch, x, y, b, p)
end

function eh.key_down(s)
	local c, k, p = s[3], s[4], s[5] 
	
	--===== Engine internal functionalities =====--
	if c == 3 then --ctrl + c
		print("[EH]: Program stopped by user.")
		global.isRunning = false
	end
	
	if k == global.conf.debug.debugKeys.showConsole then --f1
		global.conf.showConsole = not global.conf.showConsole
		if not global.conf.showConsole then
			global.clear()
		end
	end
	
	if k == global.conf.debug.debugKeys.writeInConsole then --f2
		global.tiConsole:activate()
	end
	
	if k == global.conf.debug.debugKeys.showDebug then --f3
		global.conf.showDebug = not global.conf.showDebug
		if not global.conf.showDebug then
			global.clear()
		end
	end
	if k == global.conf.debug.debugKeys.reloadState and global.isDev then --f5
		global.log("--========== RELOAD STAGE ==========--")
		global.run(global.state[global.currentState].stop)
		global.state[global.currentState] = nil
		
		global.gameObjects = {}
		global.renderAreas = {}
		
		if global.conf.debug.onReload.conf then
			global.load({
				toLoad = {conf = true},
				reload = true, 
			})
		end
		global.conf.debug.onReload.reload = true
		if global.keyboard.isControlDown() then
			local reloadList = {}
			
			for i, c in pairs(global.conf.debug.onReload) do
				reloadList[i] = true
			end
			
			global.load({
				toLoad = reloadList,
				reload = true,
			})
		else
			global.load({
				toLoad = global.conf.debug.onReload,
				reload = true,
			})
		end
		
		global.conf.debug.onReload.reload = nil
		
		global.state[global.currentState] = loadfile("data/states/" .. global.currentState .. ".lua")(global)
		global.run(global.state[global.currentState].init)
		global.run(global.state[global.currentState].start)
		
		global.clear()
		global.lastUptime = global.computer.uptime()
	end
	if k == global.conf.debug.debugKeys.rerenderScreen then --f6
		global.clear()
	end
	
	--===== General key press handling =====--
	if pressedKeys[0] == nil and pressedKeys[c] == nil then
		exportSignal(s)
		pressedKeys[c] = s
	elseif pressedKeys[0] ~= nil and specialPressedKeys[c] == nil then
		exportSignal(s)
		specialPressedKeys[c] = s
	end
end

function eh.key_up(s)
	if s[3] == 0 then
		for i, c in pairs(specialPressedKeys) do
			exportSignal(c, s[1])
			specialPressedKeys[i] = nil
		end
	end
	
	pressedKeys[s[3]] = nil
	specialPressedKeys[s[3]] = nil
end

function eh.stop()
	pressedKeys = {}
	specialPressedKeys = {}
end

eh.parseSignal = parseSignal

return eh