--[PROG_NAME] (NNSPT_v1.2)
local version = "v0.0"

--===== Requires =====--
local component = require("component")
local computer = require("computer")
local event = require("event")
local term = require("term")
local serialization = require("serialization")
local gpu = component.gpu
local mainOcgl = dofile("libs/oclrl.lua").initiate(gpu)
local ocui = dofile("libs/ocui.lua").initiate(mainOcgl)
local oclrl = dofile("libs/oclrl.lua").initiate(gpu)
local ocgf = dofile("libs/ocgf.lua").initiate({oclrl = oclrl})

--===== Variables =====--
local texture = dofile("debug/testTexture.lua")

local textBox = ocui.TextBox.new(ocui, {x=1, y=38, sx=114, sy=30, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})
local function cprint(...) textBox:add(...) end

local gameObject1 = ocgf.GameObject.new(ocgf, {})
gameObject1:addSprite({x = 10, y = 3, t = texture})

--===== Functions =====--
local function start()
	gpu.setBackground(0x000000)
	gpu.fill(0, 0, 1000, 1000, " ")
end

local function update()
	cprint("T")
end

local function draw()
	textBox:draw()
	gameObject1:draw()
	gameObject1:update()
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
