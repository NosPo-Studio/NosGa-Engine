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
	moveDis = 0,
	isMovingLeft = false,
	
	testTable = {
		t1 = 1,
		t2 = 2,
		ts1 = "1",
	},
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
		states = true,
		parents = true,
		gameObjects = true,
		textures = true,
	})
	
	print("[test]: init done.")
end

function test.start()
	global.clear()
	
	--[[
	print(loadfile("data/core/RenderArea.lua"))
	global.core.RenderArea = loadfile("data/core/RenderArea.lua")(global)
	print(loadfile("data/core/GameObject.lua"))
	global.core.GameObject = loadfile("data/core/GameObject.lua")(global)
	]]
	
	--===== debug =====--
	test.ra1 = global.addRA({
		posX = 5, 
		posY = 5, 
		sizeX = 40, 
		sizeY = 12, 
		name = "TRA1", 
		drawBorders = true,
	})
	test.ra2 = global.addRA({posX = 50, posY = 5, sizeX = 40, sizeY = 12, name = "TRA2", drawBorders = true, parent = test.ra1})
	
	test.tgo1 = test.ra1:addGO("TestGO2", {posX = 2 +100, posY = 5, layer = 3, name = "test1"})
	test.rbm1 = test.ra1:addGO("RenderBenchMark", {posX = 102, posY = 0, layer = 1, length = 1, name = "rbm_" .. tostring(c)})
	
	
	test.tgos = {}
	local amout, distance = 3, 16
	local c = 1
	amout = amout * distance
	for i = 1, amout, distance do
		c = c +1
		table.insert(test.tgos, test.ra1:addGO("TestGO", {posX = i +100, posY = 3, layer = 2, name = "test" .. tostring(c)}))
	end
	
	test.rbms = {}
	local amout, distance = 50, 25
	local c = 0
	amout = amout * distance
	for i = 1, amout, distance do
		c = c +1
		--table.insert(test.rbms, test.ra1:addGO("RenderBenchMark", {posX = i +100, posY = 0, layer = 1, length = 1, name = "rbm_" .. tostring(c)}))
	end
	
	test.ra1:moveCameraTo(100, 0)
	test.ra2:moveCameraTo(100, 0)
	
	--global.fatal(test.ra1.matrix)
	
	
	--global.tiConsole:activate()
	
	--===== debug end =====--
	
end

function test.update()
	if test.isMovingLeft then
		--test.tgo1:move(-1, 0)
		test.moveDis = test.moveDis -1
	else
		--test.tgo1:move(1, 0)
		test.moveDis = test.moveDis +1
	end
	if test.moveDis >= 30 or test.moveDis <= 0 then
		test.isMovingLeft = not test.isMovingLeft
	end
	
	
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
	
	
	--[[
	local camSpeed = 1
	if global.keyboard.isKeyDown(32) then
		--test.tgo1:move(1, 0)
		test.rbm1:move(1, 0)
	end 
	if global.keyboard.isKeyDown(30) then
		--test.tgo1:move(-1, 0)
		test.rbm1:move(-1, 0)
	end 
	if global.keyboard.isKeyDown(31) then
		--test.tgo1:move(0, -1)
		test.rbm1:move(0, -1)
	end 
	if global.keyboard.isKeyDown(17) then
		--test.tgo1:move(0, 1)
		test.rbm1:move(0, 1)
	end 
	if global.keyboard.isKeyDown(16) then
		test.ra1:moveCamera(-camSpeed, 0)
	end 
	if global.keyboard.isKeyDown(18) then
		test.ra1:moveCamera(camSpeed, 0)
	end 
	if global.keyboard.isKeyDown(19) then
		test.ra1:moveCamera(0, -camSpeed)
	end 
	if global.keyboard.isKeyDown(33) then
		test.ra1:moveCamera(0, camSpeed)
	end
	]]
end

function test.draw()
	global.drawDebug()
	
	--global.slog(test.ra1.copyInstructions)
	
	--global.gpu:drawChanges()
end

function test.keyDown(c, k)
	if k == 28 and global.isDev then
		--print("--===== EINGABE =====--")
		
		--global.realGPU.setBackground(0x000000)
		--global.term.clear()
		
		--test.tgo1:pDraw(test.ra1)
		--test.rbm1:pDraw(test.ra1)
		--global.gpu.fill(6, 3, 25, 22, "#")
		
		--test.ra1:moveCamera(3, 3)
		
		--test.ra1:moveCamera(1, 0)
		--test.ra1:moveCamera(1, 0)
		--test.ra1:moveCamera(-1, 0)
		
		--test.ra1:moveCameraTo(100, 0)
		--test.camTestStep = 0
		
		--test.ra1.toClear[5][test.tgo1] = true
		
	end 
	
	--print("KEY DOWN:", c, k, "===============================================")
	
	
	local camSpeed = 1
	if k == 205 then
		test.rbm1:move(2, 0)
		test.ra1:moveCamera(1, 0)
	elseif k == 203 then
		--test.rbm1:move(-2, 0)
		test.ra1:moveCamera(0, 1)
	elseif k == 200 then
		--test.rbm1:move(0, 2)
		--test.tgo1:move(0, 2)
	elseif k == 208 then
		--test.rbm1:move(0, -2)
		--test.tgo1:move(0, -2)
	end
	--[[
	elseif k == 16 then
		test.ra1:moveCamera(-camSpeed, 0)
	elseif k == 18 then
		test.ra1:moveCamera(camSpeed, 0)
	elseif k == 19 then
		test.ra1:moveCamera(0, -camSpeed)
	elseif k == 33 then
		test.ra1:moveCamera(0, camSpeed)
	end
	]]
	
	--print(c, k)
end

function test.keyUp(c, k)
	
end

function test.touch(x, y, b, p)
	--print(x, y, b, p)
	--print(test.ra1:getPos(x, y))
end

function test.drag(x, y, b, p)
	
end

function test.drop(x, y, b, p)
	
end

function test.stop()
	global.tiConsole:stop()
end

return test





