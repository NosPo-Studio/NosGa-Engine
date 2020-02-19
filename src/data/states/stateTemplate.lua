--[[
    This file is a State example for the NosGa Engine.
	
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

local global = ... --Here we get global.

--===== shared vars =====--
--[[Here are the State variables/functions stored also avaiable in "global.state.stateTemplate".
	This table must be returned (see end of file).
]]
local stateTemplate = { 
	
}

--===== local vars =====--

--===== local functions =====--
--Just a function to use the console for printing instead of the default print function.
local function print(...) 
	global.log(...)
end

--===== shared functions =====--
--[[This function is called once a time when the State is calculated the first time. 
	If the State is reloaded it will be called once again on first calculated frame.
]]
function stateTemplate.init() 
	print("[stateTemplate]: init start.")
	
	--[[Here we load all the data groups we need. 
		The States as well as global/structured global are already loaded 
		at the engine initiaisation per default.
	]]
	global.load({ 
		toLoad = {
			parents = true,
			gameObjects = true,
			textures = true,
			animations = true,
			mods = true,
		},
	})
	
	--Clearing the screen.
	global.clear() 
	
	--Creating an RenderArea in size of the screen.
	stateTemplate.raMainWindow = global.addRA({ 
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY, 
		name = "MainWindow", 
		drawBorders = true,
	})
	
	--Adding the GameObjectTemplate to the RenderArea.
	stateTemplate.gameObjectTemplate1 = stateTemplate.raMainWindow:addGO("GameObjectTemplate", {
		name = "got1", 
		x = 5, 
		y = 3,
		maxSpeed = 20,
	}) 
	
	--Adding the GameObjectTemplate to the RenderArea a second time but with other arguments.
	stateTemplate.gameObjectTemplate1 = stateTemplate.raMainWindow:addGO("GameObjectTemplate", {
		name = "got2", 
		x = 20, 
		y = 3,
		maxSpeed = 0,
	}) 
	
	print("[stateTemplate]: init done.")
end

--Called any time the current calculated state is changed to these one.
function stateTemplate.start() 

end

--Called once a frame.
function stateTemplate.update()	
	
end

--[[Called once a frame after the update function. 
	It is reconnemend to put all render/drawings into these function 
	to provide a faster drawing using the linear render mode.
]]
function stateTemplate.draw() 
	
end

--Called when the currend calculated State changed to an other state.
function stateTemplate.stop() 
	
end

--[[This is a signal function called by the engine on a incomming key_down signal. 
	"s" is a table containing the signal.
	Any other signal name can be used too to get the signal equivalent.
]]
function stateTemplate.key_down(s) 
	
end

--[[Called if a key defined for "example" in the controls.ini is pressed down. 
	"s" is a table with the signal. "sname" is the engine intern signal name. 
	That can be different to the original signal name (s[1]). 
	You could use just "ctrl_example()" too but that function would be called multiple times a frame 
	on key press (one time for the "key_down" and one time for the "key_pressed" signal).
]]
function stateTemplate.ctrl_example_key_down(s, sname) 
	
end

--Same as the function "stateTemplate.ctrl_example_key_down()" function but called on the "key_up" signal.
function stateTemplate.ctrl_example_key_up(s, sname) 

end

--Returing the state data.
return stateTemplate 
