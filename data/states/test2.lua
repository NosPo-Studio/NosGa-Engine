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
	
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function test.init()
	print("TEST2: init")
end

function test.start()
	print("TEST2: start")
end

function test.update()
end

function test.draw()
	global.drawDebug()
end

function test.keyDown(c, k)
	if k == 28 and global.isDev then
		print("--===== EINGABE =====--")
		global.changeState("test")
		
		
		
		--local tgo = global.gameObject.TestGO.new()
		--print(tgo.attributes.size[1])
	end 
	
	--print(c, k)
end

function test.keyUp(c, k)
	
end

function test.touch(x, y, b, p)
	
end

function test.drag(x, y, b, p)
	
end

function test.drop(x, y, b, p)
	
end

function test.stop()
	
end

return test





