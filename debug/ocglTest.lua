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
oclrl.name = "OCGL_1"

--===== Variables =====--
local consoleSizeY = 30

local orgPrint = print
local texture = dofile("debug/testTexture.lua")
local animation = dofile("debug/testAnimation.lua")
local background = dofile("texturePacks/default/textures/grass.lua")

local tbConsole = ocui.TextBox.new(ocui, {x=1, y=10, sx=0, sy=0, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})

local anim = oclrl.Animation.new(oclrl, animation, {})

local posX, posY = 10, 10

--===== Functions =====--
local function print(...)
	tbConsole:add(...)
end
function cprint(...)
	tbConsole:add(...)
end
function sprint(...)
	tbConsole:add(serialization.serialize(...))
	ocui:draw()
end

local function start()
	term.clear()
	local resX, resY = gpu.getResolution()
	tbConsole.sizeX = resX
	tbConsole.sizeY = resY - (resY - consoleSizeY)
	tbConsole.posY = resY - consoleSizeY
	
end

local function update()
	--texture = dofile("debug/testTexture.lua")
	
end

local function draw()
	gpu.setBackground(0x555555)
	term.clear()
	--oclrl:draw(40, 1, texture)
	--anim:stop(nil, true)
	--anim:play(-1)
	--anim:draw(40, 1, .1)
	
	
	--anim:stop(nil, true)
	--anim:play(-1)
	--anim:draw(posX, posY, .1, nil, nil, {{10, 13, 10, 13}})
	
	--[[
	oclrl:draw(posX, posY, texture, nil, {10, 13, 10, 13})
	
	oclrl:draw(posX +20, posY, texture, nil)
	oclrl:draw(posX, posY, texture, nil, {10 +20, 13 +20, 10, 13})
	
	oclrl:draw(60, 10, oclrl.generateTexture(0, 0, "test"))
	]]
	
	--gpu.set(posX +20, posY, "0123456789", true)
	--gpu.fill(posX +30, posY, 10, 10, "#")
	
	gpu.set(1, 1, tostring(posX) .. " | " .. tostring(posY))
	
	
	ocui:draw()
end

local function keyDown(_, _, c, k)
	if c == 100 then
		posX = posX +1
	elseif c == 97 then
		posX = posX -1
	elseif c == 115 then
		posY = posY +1
	elseif c == 119 then
		posY = posY -1
	end
end

local function touch(_, _, x, y, _, _)
	
end

local function progamEnd()
	event.ignore("touch", touch)
	event.ignore("key_down", keyDown)
end

--===== Event listening =====--
event.listen("touch", touch)
event.listen("key_down", keyDown)

--===== std program structure / main while =====--
--local std_sleepTime = 2^32
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
