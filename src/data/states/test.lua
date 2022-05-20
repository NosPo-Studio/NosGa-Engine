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
	
	test.raMain = global.addRA({
		posX = 5, 
		posY = 3, 
		sizeX = 55, 
		sizeY = 20, 
		name = "TRA1", 
		drawBorders = true,
	})
	--test.ra2 = global.addRA({posX = 59, posY = 3, sizeX = 55, sizeY = 20, name = "TRA2", drawBorders = true, parent = test.raMain})
	
	--test.goTest = test.raMain:addGO("Test", {x = 0, y = 0})
	--test.goTest2 = test.raMain:addGO("test", {x = 10, y = 5})
	test.goTest3 = test.raMain:addGO("test", {x = 15, y = 10, layer = 2, name = "t1"})
	
	test.goTest4 = test.raMain:addGO("test2", {x = 15, y = 12, layer = 3, name = "t2"})
	test.goTest5 = test.raMain:addGO("test2", {x = 15, y = 16, layer = 5, name = "t3"})
	
	test.goStreet = test.raMain:addGO("street", {x = 2, y = 2, layer = 1, name = "s1"})

	test.raMain:moveCamera(15, 3)


	
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





