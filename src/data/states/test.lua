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

local global = ...

--===== shared vars =====--
local test = {
	camSpeed = 1,
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
		},
	})
	
	print("[test]: init done.")
end

function test.start()
	global.clear()
	
	--===== debug =====--
	--Creating 2 RenderAreas (windows) showing the same scene.
	test.ra1 = global.addRA({
		posX = 5, 
		posY = 5, 
		sizeX = 40, 
		sizeY = 12, 
		name = "TRA1", 
		drawBorders = true,
	})
	test.ra2 = global.addRA({posX = 50, posY = 5, sizeX = 40, sizeY = 12, name = "TRA2", drawBorders = true, parent = test.ra1})
	
	--Creating some GameObjects in the same scene.
	test.tgo1 = test.ra1:addGO("MovingTestGO", {posX = 2 +100, posY = 5, layer = 3, name = "test1"})
	test.rbm1 = test.ra1:addGO("RPT", {posX = 102, posY = 0, layer = 1, length = 1, name = "moving" .. tostring(c)})
	
	test.tgos = {}
	local amout, distance = 3, 16
	local c = 1
	amout = amout * distance
	for i = 1, amout, distance do
		c = c +1
		table.insert(test.tgos, test.ra1:addGO("StaticTestGO", {posX = i +100, posY = 3, layer = 2, name = "test" .. tostring(c)}))
	end
	
	test.rbms = {}
	local amout, distance = 50, 25
	local c = 0
	amout = amout * distance
	for i = 1, amout, distance do
		c = c +1
		--table.insert(test.rbms, test.ra1:addGO("RPT", {posX = i +100, posY = 0, layer = 1, length = 1, name = "rbm_" .. tostring(c)}))
	end
	
	--Moce cameras to x 100.
	test.ra1:moveCameraTo(100, 0)
	test.ra2:moveCameraTo(100, 0)
	
	test.rbm1:move(-3.2, 0)
	
	--===== debug end =====--
	
end

function test.update()
	global.log(nil, nil, "t")
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
	global.drawDebug()
	
	--global.slog(test.ra1.copyInstructions)
	
	--global.gpu:drawChanges()
end

function test.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		
		global.realGPU.setBackground(0x000000)
		global.term.clear()
		
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





