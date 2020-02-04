--[PROG_NAME] (NNSPT_v1.2)
local version = "v0.0"

--===== Requires =====--
local component = require("component")
local computer = require("computer")
local event = require("event")
local gpu = component.gpu
local oclrl = dofile("libs/oclrl.lua").initiate(gpu)
local ocgf = dofile("libs/ocgf.lua").initiate({oclrl = oclrl})

--===== Variables =====--
local texture = dofile("debug/testAnimation2.lua")

local go1 = ocgf.GameObject.new(ocgf, {posX = 10, posY = 10})
local go2 = ocgf.GameObject.new(ocgf, {posX = 20, posY = 10})
local go3 = ocgf.GameObject.new(ocgf, {posX = 30, posY = 10})

--===== Functions =====--
local function start()
	gpu.setBackground(0x000000)
	gpu.fill(1, 1, 1000, 1000, " ")
	
	go1:addSprite({posX = 0, posY = 0, texture = texture})
	go2:addSprite({posX = 0, posY = 0, texture = texture})
	go3:addSprite({posX = 0, posY = 0, texture = texture})
	
end

local function update()
	
end

local function draw()
	go1:draw()
	go2:draw()
	go3:draw()
end

local function touch(_, _, x, y, _, _)
	
end

local function progamEnd()
	event.ignore("touch", touch)
end

--===== Event listening =====--
event.listen("touch", touch)

--===== std program structure / main while =====--
local std_sleepTime = .1
local std_programIsRunning = true
local std_previousScreenResolution = {gpu.getResolution()}
local function std_onError(f, ...)
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
	
	local _, _, key = event.pull(std_sleepTime, "key_down")
	if key == 3 then --ctrl+c
		std_programIsRunning = false
		break
	end
end

progamEnd()
gpu.setForeground(0xffffff)
gpu.setBackground(0x000000)
gpu.setResolution(std_previousScreenResolution[1], std_previousScreenResolution[2])
