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
	
	testStep = 0,
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
			gui = true,
		},
	})

	
	
	print("[test]: init done.")
end

function test.start()
	global.clear()

	
	--===== debug =====--
	--Creating 2 RenderAreas (windows) showing the same scene.
	
	test.raMain = global.addRA({
		posX = 5, 
		posY = 3, 
		sizeX = 50, 
		sizeY = 40, 
		name = "TRA1", 
		drawBorders = true,
	})
	--test.ra2 = global.addRA({posX = 59, posY = 3, sizeX = 55, sizeY = 20, name = "TRA2", drawBorders = true, parent = test.raMain})
	
	test.goMoving = test.raMain:addGO("test", {x = 5, y = 3, layer = 2, name = "barrier"})
	test.goMoving2 = test.raMain:addGO("test", {x = 5, y = 25, layer = 2, name = "barrier"})

	package.loaded["libs/thirdParty/GUI"] = nil
	global.gui = require("libs/thirdParty/GUI")

	print("INIT")

	if true then
		local GUI = global.gui
		local app = GUI.application()
		local container = app:addChild(GUI.container(6, 3, 50, 20))
		local button1 = container:addChild(GUI.button(2, 1, 11, 3, 0x444444, 0x999999, 0x777777, 0xdddddd, "Button1"))
		local button2 = container:addChild(GUI.button(2, 5, 11, 3, 0x444444, 0x999999, 0x777777, 0xdddddd, "Button2"))
		local switch1 = container:addChild(GUI.switch(15, 2, 11, 0x444444, 0x999999, 0x777777))
		local switch2 = container:addChild(GUI.switch(15, 6, 11, 0x444444, 0x999999, 0x777777))
			
			
		button1.onTouch = function()
			if not switch1.state then
				GUI.alert("NEIN NEIN NEIN NEIN!!! DAS GEHT SO NICHT!! DER SChALTER IST AUS!!!!")
			end
		end
		
		button2.onTouch = function()
			if not switch2.state then
				GUI.alert("Nein.")
			end
		end
		
		
		app:draw(true)
		app:start()
	end
	
	
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





