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
	
	global.clear()
	
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

	for i, c in pairs(global.texture) do
		if c.format == "pic" then
			global.makeImageTransparent(c, 0x00ffff)
		end
	end
	
	print("[test]: init done.")
end

function test.start()
	test.raMain = global.addRA({
		posX = 5, 
		posY = 3, 
		sizeX = 55, 
		sizeY = 20, 
		name = "TRA1", 
		drawBorders = true,
	})
end

function test.update()	
	
end

function test.draw()
	
end

function test.stop()
	
end

return test






