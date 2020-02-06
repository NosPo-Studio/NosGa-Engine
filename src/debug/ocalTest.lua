--[PROG_NAME] (NNSPT_v1.2)
local version = "v0.0"

--===== Requires =====--
local component = require("component")
local computer = require("computer")
local event = require("event")
local serialization = require("serialization")
local gpu = component.gpu
local db = require("libs/thirdParty/DoubleBuffering")
local dbgpu = loadfile("libs/dbgpu_api.lua")({directDraw = false, path = "libs/thirdParty"})
local image = dofile("libs/thirdParty/image.lua")
local oclrl = dofile("libs/oclrl.lua").initiate(dbgpu)
package.loaded.ocal = nil
local ocal = require("ocal").initiate({oclrl = oclrl, db = db, image = image})

--===== Variables =====--
local animation = dofile("debug/testAnimation2.lua")
local animation2 = ocal:load("debug/testAnimation")

local anim = ocal.Animation.new(ocal, animation)
local anim2 = ocal.Animation.new(ocal, animation2)

anim.id = 1
anim2.id = 2




--===== Functions =====--
local function start()
	--gpu.setBackground(0x000000)
	--gpu.fill(1, 1, 1000, 1000, " ")
	
	--print()
end

local function update()
	
end

local i = 0

local function draw()
	db.drawRectangle(1, 1, 100, 40, 0x999999, 0x555555, " ")
	db.drawChanges()
	
	anim:draw(10, 10)
	anim2:draw(30, 10, nil, false)
	
	db.drawChanges()
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
