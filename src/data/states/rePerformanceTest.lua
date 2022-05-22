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

	testObjecs = {},
	physicObjects = {},
	testAnimations = {},
	objectBundlesAdded = 0,

	renderAreas = {},
	
	--debug
	stats = global.stats,
	cameraOffsetX = 0,
	cameraOffsetY = 0,
	ui = {},
	ocui = {},
	maxDistance = 0,
	lines = 3,
	streetWidth = 5,
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
	
	--[[
	test.raMain = global.addRA({
		posX = 5, 
		posY = 3, 
		sizeX = 80, 
		sizeY = 50, 
		name = "TRA1", 
		drawBorders = true,
	})
	]]
	--test.ra2 = global.addRA({posX = 59, posY = 3, sizeX = 55, sizeY = 20, name = "TRA2", drawBorders = true, parent = test.raMain})

	test.raMain = global.addRA({
		posX = 5, 
		posY = 3, 
		sizeX = 80, 
		sizeY = 50, 
		name = "TRA1", 
		drawBorders = true,
	})


	
	--test.goTest = test.raMain:addGO("Test", {x = 0, y = 0})
	--test.goTest2 = test.raMain:addGO("test", {x = 10, y = 5})
	
	for c = 1, 1 do
		test.goTest3 = test.raMain:addGO("test", {x = 15, y = 10, layer = 2, name = "barrier"})
	end
	
	for c = 0, 3, 1 do
		--test.goStreet = test.raMain:addGO("street", {x = c * 18, y = 2, layer = 1, name = "s1"})
	end
	for c = 0, 3, 1 do
		--test.goStreet = test.raMain:addGO("street", {x = c * 18, y = 26, layer = 1, name = "s1"})
	end

	for x = 0, 6, 1 do
		for y = 0, 6, 1 do
			--test.goTest5 = test.raMain:addGO("test2", {x = 8 * x, y = 8 * y, layer = 4, name = "t3"})
		end
	end

	for x = 0, 4, 1 do
		for y = 0, 1, 1 do
			--test.goTest5 = test.raMain:addGO("test", {x = 8 * x, y = 8 * y + 20, layer = 4, name = "t3"})
		end
	end

	for c = 0, 30 do
		--test.testAnimations[c] = test.raMain:addGO("fakeAnimation", {x = 16, y = 30, layer = 5, name = "fake anim"})
	end

	for c = 0, 100, 1 do
		test.testObjecs[c] = test.raMain:addGO("test2", {x = 15, y = 16, layer = 5, name = "testObject_" .. tostring(c)})
	end

	for c = 0, 1, 1 do
		test.physicObject = test.raMain:addGO("physicObject", {x = 8 * c + 1, y = 30, layer = 5, name = "phys"})
		test.ground = test.raMain:addGO("test2", {x = 8 * c + 1, y = 38, layer = 5, name = "ground"})
	end
	

	--[[
	for c = 0, 3, 1 do
		test.goStreet = test.raMain:addGO("street", {x = c * 21, y = 2, layer = 1, name = "s1"})
	end
	for c = 0, 3, 1 do
		test.goStreet = test.raMain:addGO("street", {x = c * 21, y = 31, layer = 1, name = "s1"})
	end

	for x = 0, 8, 1 do
		for y = 0, 5, 1 do
			test.goTest5 = test.raMain:addGO("test2", {x = 8 * x, y = 8 * y, layer = 5, name = "t3"})
		end
	end
	]]

	--test.raMain:moveCamera(5, 0)


	
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
	
end

function test.draw()
	
end

function test.key_down(s)
	if s[4] == 28 and global.isDev then
		print("--===== EINGABE =====--")
		
		if false then
			global.realGPU.setBackground(0x000000)
			global.term.clear()
		end
	end 
end

function test.key_pressed(s)

end

function test.key_up(s)
	
end

function test.touch(s)
	
end

function test.ctrl_pause_key_down(s, sname)
	test.pause = true
end

function test.ctrl_left_key_pressed()
	print("###########################")
	--test.raMain:moveCamera(-1, 0)
end
function test.ctrl_right_key_pressed()
	print("###########################")
	--test.raMain:moveCamera(1, 0)
end

function test.ctrl_camLeft_key_pressed()
	print("###########################")
	test.raMain:moveCamera(-1, 0)
end
function test.ctrl_camRight_key_pressed()
	print("###########################")
	test.raMain:moveCamera(1, 0)
end
function test.ctrl_bothLeft_key_pressed()
	print("###########################")
	test.raMain:moveCamera(-1, 0)
end
function test.ctrl_bothRight_key_pressed()
	print("###########################")
	test.raMain:moveCamera(1, 0)
end

function test.ctrl_add_key_down()
	if test.goAdded == nil then
		test.goAdded = test.raMain:addGO("test2", {x = 3, y = 3, l = 5, name = "Added"})
	end
end
function test.ctrl_rem_key_down()
	test.goAdded:destroy()
	test.goAdded = nil
end

function test.ctrl_test1_key_down()
	if test.testStep == 0 then
		test.goMoving:move(1, 0)
		if test.goAdded == nil then
			test.goAdded = test.raMain:addGO("test2", {x = 3, y = 3, l = 5, name = "Added"})
		end
		test.testStep = 1
	elseif test.testStep == 1 then
		test.goMoving:move(-1, 0)
		test.goAdded:destroy()
		test.goAdded = nil
		test.testStep = 0
	end
end


function test.ctrl_clearScreen_key_pressed()
	global.log("Clear screen")
	global.realGPU.setBackground(0x000000)
	global.db.drawRectangle(0, 0, global.resX, global.resY, 0x0, 0x0, " ")
	global.db.drawChanges(true)
end

function test.ctrl_test(s, sname)
	
end
function test.ctrl_test_key_down(s, sname)
	
end
function test.ctrl_test_key_pressed(s, sname)
	
end
function test.ctrl_test2_key_down(s, sname)
	
end

function test.drag(s)
	
end

function test.drop(s)
	
end

function test.stop()
	
end

return test





