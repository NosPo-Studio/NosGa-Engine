--[[
    This file is part of the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019 NosPo Studio

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

--===== Requires =====--
local global = ...

--===== Variables =====--
local orgPrint = print
local frameCount = 0
local lastFPSCheck = 0

--===== Functions =====--

local function print(...)
	global.log(...)
end

local function run(func, ...)
	if func ~= nil then
		local suc, err = xpcall(func, debug.traceback, ...)
		if not suc then
			print("[ERROR][GE]: Tryed to call " .. tostring(func) .. ":")
			print(tostring(err))
			print(debug.traceback())
		end
	end
end

local function start()
	--[[
	global.gpu.setBackground(0x000000)
	global.gpu.clear()
	]]
	
	--global.clear()
	
	global.lastUptime = global.computer.uptime()
	
end

local function update()
	if frameCount >= global.conf.fpsCheckInterval then
		global.fps = global.conf.fpsCheckInterval / (global.computer.uptime() - lastFPSCheck)
		lastFPSCheck = global.computer.uptime()
		frameCount = 0
	else
		frameCount = frameCount +1
	end
	
	
	--===== frame calculation =====--
	if global.state[global.currentState].update ~= nil then	--manual check to avoid log spamming on missing update func.
		run(global.state[global.currentState].update)
	end
	global.ge.update()
	
	for i, ra in pairs(global.renderAreas) do
		global.re.calculateRenderArea(ra)
		ra:pCalculateNewRender()
	end
end

local function draw()
	if global.state[global.currentState].draw ~= nil then	--manual check to avoid log spamming on missing draw func.
		run(global.state[global.currentState].draw)
	end
	
	global.re.draw()
	
	global.ocui:draw()
	if global.conf.showConsole then
		global.tbConsole:draw()
	end
	
	if global.conf.debug.useDoubleBuffering then
		global.gpu.drawChanges()
	end
end

local function touch(_, _, x, y, b, p)
	global.ocui:update(x, y)
	run(global.state[global.currentState].touch, x, y, b, p)
end

local function drag(_, _, x, y, b, p)
	run(global.state[global.currentState].drag, x, y, b, p)
end

local function drop(_, _, x, y, b, p)
	run(global.state[global.currentState].drop, x, y, b, p)
end

local function keyDown(_, _, c, k, p)
	if c == 3 then --ctrl + c
		print("Program stopped by user.")
		global.isRunning = false
	end
	
	if k == global.controls.debug.showConsole then
		global.conf.showConsole = not global.conf.showConsole
		if not global.conf.showConsole then
			global.clear()
		end
	end
	
	run(global.state[global.currentState].keyDown, c, k, p)
	
	if k == global.controls.debug.showDebug then --f3
		global.conf.showDebug = not global.conf.showDebug
		if not global.conf.showDebug then
			global.clear()
		end
	end
	if k == global.controls.debug.reloadState and global.isDev then --f5
		global.log("--========== RELOAD STAGE ==========--")
		run(global.state[global.currentState].stop)
		global.state[global.currentState] = nil
		
		global.gameObjects = {}
		global.renderAreas = {}
		
		if global.conf.debug.onReload.conf then
			global.conf = dofile("conf.lua")
		end
		global.conf.debug.onReload.reload = true
		if global.keyboard.isControlDown() then
			local reloadList = {}
			
			for i, c in pairs(global.conf.debug.onReload) do
				reloadList[i] = true
			end
			
			global.load(reloadList)
		else
			global.load(global.conf.debug.onReload)
		end
		
		global.conf.debug.onReload.reload = nil
		
		global.state[global.currentState] = loadfile("data/states/" .. global.currentState .. ".lua")(global)
		run(global.state[global.currentState].init)
		run(global.state[global.currentState].start)
		
		global.clear()
	end
	if k == global.controls.debug.rerenderScreen then --f6
		global.clear()
	end
	
end

local function keyUp(_, _, c, k, p)
	run(global.state[global.currentState].keyUp, c, k, p)
end

local function progamEnd()
	global.event.ignore("touch", touch)
	global.event.ignore("drag", drag)
	global.event.ignore("drop", drop)
	global.event.ignore("key_down", keyDown)
	global.event.ignore("key_up", keyUp)
	
	for _, s in pairs(global.state) do
		run(s.stop)
	end
	
	global.ocui:stop()
	global.tbConsole:draw()
	global.ocl.close()
end

--===== global.event listening =====--
global.event.listen("touch", touch)
global.event.listen("drop", drop)
global.event.listen("drag", drag)
global.event.listen("key_down", keyDown)
global.event.listen("key_up", keyUp)

--===== std program structure / main while =====--
local std_previousScreenResolution = {global.gpu.getResolution()}
local std_success = true
local function std_onError(f, ...)
	print = orgPrint
	global.isRunning = false
	std_success = false
	global.gpu.setForeground(0xff0000)
	global.gpu.setBackground(0x000000)
	print("[ERROR] in func: " .. f)
	print(...)
	global.gpu.setForeground(0xffffff)
	global.fatal("In func: " .. tostring(f))
	global.fatal(...)
end

local s, m = xpcall(start, debug.traceback)
if s == false then
	std_onError("start()", m, debug.traceback())
end

while global.isRunning do
	local s, m = xpcall(update, debug.traceback)
	if s == false then
		std_onError("update()", m, debug.traceback())
		break
	end
	
	if global.isRunning then
		local s, m = xpcall(draw, debug.traceback)
		if s == false then
			std_onError("draw()", m, debug.traceback())
			break
		end
	end
	
	global.dt = global.computer.uptime() - global.lastUptime
	global.lastUptime = global.computer.uptime()
	
	if global.conf.targetFramerate == -1 then
		os.sleep()
	else
		os.sleep((1 / global.conf.targetFramerate) - math.max(global.dt - (1 / global.conf.targetFramerate), 0))
	end
	global.currentFrame = global.currentFrame +1
end

progamEnd()
global.gpu.setForeground(0xffffff)
global.gpu.setBackground(0x000000)
global.gpu.setResolution(std_previousScreenResolution[1], std_previousScreenResolution[2])

return std_success, "failed"