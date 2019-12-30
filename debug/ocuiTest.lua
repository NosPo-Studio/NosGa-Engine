--[PROG_NAME] (NNSPT_v1.2)
local version = "v0.0d"

--===== Requires =====--
local component = require("component")
local computer = require("computer")
local event = require("event")
local term = require("term")
local gpu = component.gpu
local ocgf = dofile("libs/ocgf.lua")
local oclrl = dofile("libs/oclrl.lua").initiate(gpu)
local ocui = dofile("libs/ocui.lua").initiate(oclrl)

--===== Variables =====--
local orgPrint = print
local textures = {
	test = dofile("texturePacks/default/textures/player.lua"),	
}

local lastTime = computer.uptime()
local dt = 0

local clockStart = 0
local clockEnd = 0

local textBox = ocui.TextBox.new(ocui, {x=1, y=18, sx=80, sy=30, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})



--===== Functions =====--
local function print(text)
	textBox:add(text)
end

local function start()
	term.clear()
	
	--loadfile("test.lua")()
	local suc, err = xpcall(loadfile("test.lua"), debug.traceback)
	
	orgPrint(err)
	orgPrint("====================================================")
	
	print(err)
	--print("test ocCraft test")
end

local function update()	
	
end

local c = 1
local function draw()
	ocui:draw()
end

local function touch(_, _, x, y, _, _)
	ocui:update(x, y)
end

local function keyDown(_, _, c, k, _, _)
	if c == 119 then --w
		gameObject1:addForce(0, -2)
	end
	if c == 97 then --a
		gameObject1:addForce(-1, 0)
	end
	if c == 115 then --s
		gameObject1:addForce(0, 1)
	end
	if c == 100 then --d
		gameObject1:addForce(1, 0)
	end
	
	if c == 114 then
		gameObject1:moveTo(0, 0)
		print("RESET")
	end
end

local function progamEnd()
	event.ignore("touch", touch)
	event.ignore("key_down", keyDown)
end

--===== Event listening =====--
event.listen("touch", touch)
event.listen("key_down", keyDown)

--===== std program structure / main while =====--
local std_sleepTime = .1
local std_programIsRunning = true
local std_previousScreenResolution = {gpu.getResolution()}
local function std_onError(f, ...)
	print = orgPrint
	std_programIsRunning = false
	gpu.setForeground(0xff0000)
	gpu.setBackground(0x000000)
	print("[ERROR] in func: " .. f)
	print(...)
	gpu.setForeground(0xffffff)
end

local s, m = xpcall(start, debug.traceback)
if s == false then
	std_onError("start()", m, debug.traceback())
end

while std_programIsRunning do
	local s, m = xpcall(update, debug.traceback)
	if s == false then
		std_onError("update()", m, debug.traceback())
		break
	end
	
	local s, m = xpcall(draw, debug.traceback)
	if s == false then
		std_onError("draw()", m, debug.traceback())
		break
	end
	
	--local _, _, key = event.pull("key_down")
	local _, _, key = event.pull(std_sleepTime, "key_down")
	if key == 3 then --ctrl+c
		std_programIsRunning = false
		break
	end
	dt = computer.uptime() - lastTime
	lastTime = computer.uptime()
end

progamEnd()
gpu.setForeground(0xffffff)
gpu.setBackground(0x000000)
gpu.setResolution(std_previousScreenResolution[1], std_previousScreenResolution[2])
