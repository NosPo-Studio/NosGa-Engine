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

--===== shared vars =====--
local test = {
	camSpeed = 1,
	pause = false,
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function test.init()
	print("[test]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			parents = true,
			gameObjects = true,
			textures = true,
			animations = true,
		},
	})
	
	print("[test]: init done.")
end

function test.start()
	global.clear()
	
	
	package.loaded["libs/ocgf"] = nil
	
	global.ocgf = dofile("libs/ocgf.lua").initiate({gpu = global.gpu, db = global.db, oclrl = global.oclrl, ocal = global.ocal})
	
	
	--===== debug =====--
	--Creating 2 RenderAreas (windows) showing the same scene.
	test.ra1 = global.addRA({
		posX = 2, 
		posY = 3, 
		sizeX = 55, 
		sizeY = 20, 
		name = "TRA1", 
		drawBorders = true,
	})
	--test.ra2 = global.addRA({posX = 59, posY = 3, sizeX = 55, sizeY = 20, name = "TRA2", drawBorders = true, parent = test.ra1})
	
	--test.goTest = test.ra1:addGO("Test2", {posX = 2 +100, posY = 2, layer = 3, maxSpeed = 20, name = "goTest"})
	test.goTest2 = test.ra1:addGO("Test3", {posX = 35 +100, posY = 2, layer = 2, name = "goTest2"})
	test.goTest3 = test.ra1:addGO("Test4", {posX = 10 +100, posY = 2, layer = 2, name = "goTest3"})
	
	--test.goTest3:attach(test.goTest)
	
	
	test.pc1 = test.ra1:addGO("ParticleTestContainer", {posX = 20 +100, posY = 3, layer = 5, name = "PC1"})
	
	--Moce cameras to x 100.
	test.ra1:moveCameraTo(100, 0)
	--test.ra2:moveCameraTo(100, 0)
	
	--===== debug end =====--
	
end

function test.update()	
	--print("=====New frame=====")
	while test.pause do
		os.sleep(.1)
		if global.keyboard.isKeyDown("z") or global.keyboard.isKeyDown(60) or global.keyboard.isKeyDown(63) or global.keyboard.isControlDown() then
			test.pause = not test.pause
		end
	end
	
	--global.log(nil, nil, "t")
	--[[
	if test.camTestStep == 0 then
		--empty to get sure the cam is reseted.
		test.camTestStep = test.camTestStep +1
	elseif test.camTestStep == 1 then
		--test.ra1:moveCamera(10, 0)
		test.tgo1:move(20, 0)
		test.camTestStep = test.camTestStep +1
	elseif test.camTestStep == 2 then
		test.ra1:moveCamera(5, 0)
		test.tgo1:move(-10, 0)
		test.camTestStep = test.camTestStep +1
	elseif test.camTestStep == 3 then
		
		test.camTestStep = test.camTestStep +1
	elseif test.camTestStep == 4 then
	
		test.camTestStep = test.camTestStep +1
	elseif test.camTestStep == 5 then
		
		test.camTestStep = test.camTestStep +1
	elseif test.camTestStep == 6 then
		
		test.camTestStep = test.camTestStep +1
	end
	--os.sleep(.5)
	]]
end

function test.draw()
	--global.slog(test.ra1.copyInstructions)
	
	--global.gpu:drawChanges()
end

function test.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		
		if false then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
		
		global.db.set(100, 10, 0x000000, 0xaaaaaa, "▀")
		global.db.set(100, 11, 0x000000, 0xaaaaaa, "▄")
		global.db.set(100, 12, 0x000000, 0xaaaaaa, "█")
		
		--test.goTest3:detach()
		--test.goTest3:setSpeed(10, 0)
		--test.goTest:setSpeed(15, 0)
		
		--test.tgo1:ngeDraw(test.ra1)
		--test.rbm1:ngeDraw(test.ra1)
		--global.gpu.fill(6, 3, 25, 22, "#")
		
		--test.ra1:moveCamera(3, 3)
		
		--test.ra1:moveCamera(1, 0)
		--test.ra1:moveCamera(1, 0)
		--test.ra1:moveCamera(-1, 0)
		
		--test.ra1:moveCameraTo(100, 0)
		--test.camTestStep = 0
		
		--test.ra1.toClear[5][test.tgo1] = true
		
	end 
	
	--print("KEY DOWN:", s[3], s[4], global.currentFrame,  "=======================================")
	
	--print(c, k)
end

function test.key_pressed(s)
	--print("KEY PRESSED:", s[3], s[4], global.currentFrame)
	--test.ra1:rerenderAll()
	--test.ra2:rerenderAll()
	
	
end

function test.key_up(s)
	--print("KEY UP:", s[3], s[4], global.currentFrame, "===============================================")
end

function test.touch(s)
	--print(s[3], s[4], s[5])
	--print(test.ra1:getPos(x, y))
end

function test.ctrl_pause_key_down(s, sname)
	test.pause = not test.pause
end

function test.ctrl_camLeft(s, sname)
	test.ra1:moveCamera(-test.camSpeed, 0)
end
function test.ctrl_camRight(s, sname)
	test.ra1:moveCamera(test.camSpeed, 0)
end
function test.ctrl_camUp(s, sname)
	test.ra1:moveCamera(0, test.camSpeed)
end
function test.ctrl_camDown(s, sname)
	test.ra1:moveCamera(0, -test.camSpeed)
end

function test.ctrl_test(s, sname)
	--print("TEST", global.currentFrame, sname, tostring(s[3]), tostring(s[4]))
	--print("TEST", global.currentFrame, sname, tostring(s[1]), tostring(s[2]), tostring(s[3]), tostring(s[4]), tostring(s[5]), tostring(s[6]))
end
function test.ctrl_test_key_down(s, sname)
	--print("TEST_KD", global.currentFrame, sname, s[1], s[2], s[3], s[4], s[5], s[6])
end
function test.ctrl_test_key_pressed(s, sname)
	--print("TEST_P", global.currentFrame, sname, s[1], s[2], s[3], s[4], s[5], s[6])
end
function test.ctrl_test2_key_down(s, sname)
	--print("TEST2_KD", global.currentFrame, sname, s[1], s[2], s[3], s[4], s[5], s[6])
end

function test.drag(s)
	
end

function test.drop(s)
	
end

function test.stop()
	
end

return test





