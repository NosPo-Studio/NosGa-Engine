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

--===== Requires =====--
local global = ...

--===== Variables =====--
local orgPrint = print
local frameCount = 0
local lastFPSCheck = 0
local dts = {}

local xpcall = xpcall

--===== Functions =====--

_G.print = global.print

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
		frameCount = 0
	end
	dts[frameCount] = global.dt
	local frameTimes = 0
	for i, c in pairs(dts) do
		frameTimes = frameTimes + c
	end
	frameCount = frameCount +1
	global.fps = 1 / (frameTimes / #dts)

	--global.core.re.draw() --needed here?

	--===== frame calculation =====--
	if global.state[global.currentState].update ~= nil then	--manual check to avoid log spamming on missing update func.
		run(global.state[global.currentState].update, global.dt)
	end
	global.core.updateHandler.update()

	if not global.conf.useExperimentalRenderEngine then
		for ra in pairs(global.renderAreas) do
			global.core.re.calculateRenderArea(ra)
			ra:ngeCalculateNewRender()
		end
	end
	
end

local function draw()
	if global.state[global.currentState].draw ~= nil then	--manual check to avoid log spamming on missing draw func.
		run(global.state[global.currentState].draw)
	end

	global.core.re.draw()
	
	if global.state[global.currentState].sUpdate ~= nil then	--manual check to avoid log spamming on missing update func.
		run(global.state[global.currentState].sUpdate)
	end
	global.core.updateHandler.sUpdate()
	
	global.ocui:draw()
	
	global.debug.renderDebugInformations()
	if global.conf.showConsole then
		global.mConsole:draw()
	end
	
	if global.conf.useDoubleBuffering then
		if not global.conf.useExperimentalRenderEngine then
			global.core.re.executeCopyOrders()
		end
		global.gpu.drawChanges()
	end
end

local function progamEnd()
	global.core.eventHandler.stop()
	
	for _, s in pairs(global.state) do
		run(s.stop)
	end
	
	global.ocui:stop()
	global.tbConsole:draw()
	global.ocl.close()
end

--===== std program structure / main while =====--
local std_previousScreenResolution = {global.gpu.getResolution()}
local std_success = true
local function std_onError(f, ...)
	print = orgPrint
	global.isRunning = false
	std_success = false
	global.gpu.setForeground(0xff0000)
	global.gpu.setBackground(0x000000)
	print("[FATAL] in func: " .. f)
	print(...)
	global.gpu.setForeground(0xffffff)
	global.fatal("In func: " .. tostring(f))
	global.fatal(...)
	global.tbConsole:draw()
	if global.conf.useDoubleBuffering then
		global.gpu.drawChanges()
	end
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
	
	global.core.eventHandler.update()
	global.currentFrame = global.currentFrame +1
end

progamEnd()
global.gpu.setForeground(0xffffff)
global.gpu.setBackground(0x000000)
global.gpu.setResolution(std_previousScreenResolution[1], std_previousScreenResolution[2])
_G.print = orgPrint

return std_success, "failed"