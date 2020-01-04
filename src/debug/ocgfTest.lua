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
	test2 = dofile("texturePacks/default/textures/dirt.lua"),
}
local animation = dofile("debug/testAnimation.lua")
local animation2 = dofile("debug/testAnimation2.lua")
local anim = oclrl.Animation.new(oclrl, animation)

local lastTime = computer.uptime()
local dt = 0

local clockStart = 0
local clockEnd = 0

local textBox = ocui.TextBox.new(ocui, {x=1, y=18, sx=80, sy=30, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})

local function textFunc(...) textBox:add(...) end

local gameObject1 = ocgf.GameObject.new(ocgf, {dt = true, dc = true, logFunc = textFunc, x = 20})
local gameObject2 = ocgf.GameObject.new(ocgf, {dt = true, dc = true, logFunc = textFunc})
local gameObject3 = ocgf.GameObject.new(ocgf, {dt = true, dc = true, logFunc = textFunc})

gameObject1:addBoxCollider({sx = 7, sy = 4, x = 0, y = 0, lf = function(this) this.gameObject.log(computer.uptime() - clockStart) end, n = "collider1"})
gameObject1:addRigidBody({mass = 1, g = 5, stiffness = .5})
gameObject1:addBoxTrigger({x = 0, y = 0, sx = 3, sy = 10, lf = function()
	
end})
--gameObject1:addSprite({x = 0, y = -6, t = textures.test})
gameObject1:addSprite({x = 0, y = -6, t = textures.test})

gameObject2:addBoxCollider({sx = 50, sy = 3, x = 8, y = 17, lf = function(this) this.gameObject.log("trigger2") end, n = "collider2"})
gameObject2:addRigidBody({stiffness = -1})


gameObject3:addBoxCollider({sx = 3, sy = 4, x = 10, y = 2, n = "collider1"})

--===== Functions =====--
local function print(text)
	textBox:add(text)
end

local function start()
	term.clear()
	--gameObject1:moveTo(10, 10)
	
	gameObject1:getSprites()
	
	for _, s in pairs(gameObject1:getSprites()) do
		s:changeTexture(animation2)
	end
	
	clockStart = computer.uptime()
end

local function update()	
	gameObject1:update({gameObject2, gameObject3})
	gameObject1:updatePhx({gameObject2, gameObject3}, dt)
	--textFunc(gameObject1.rigidBodys[1].update)
end

local c = 1
local function draw()
	gpu.setBackground(0x000000)
	--gpu.fill(1, 1, 100, 100, " ")
	
	gameObject1:clear()
	
	gameObject1:draw()
	gameObject2:draw()
	gameObject3:draw()
	
	ocui:draw()
	--event.push("key_down", 3, 3) --stops program
	gpu.set(1, 1, "DT: " .. tostring(dt))
end

local function touch(_, _, x, y, _, _)
	
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
