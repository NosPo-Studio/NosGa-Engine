--[[
    This file is a GameObject example for the NosGa Engine.
	
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

local global = ... --Here we get global.

GameObjectsTemplate = {}
GameObjectsTemplate.__index = GameObjectsTemplate

function GameObjectsTemplate.init(this) --Called once when the class is loaded by the engine.
	
end

function GameObjectsTemplate.new(args) --Calles on the bject creation of the class. Here you define/initiate the class.
	--===== gameObject definition =====--
	args = args or {} --Take given GameObject args if present and prevents it from being nil if not.
	args.sizeX = 6
	args.sizeY = 3
	args.components = { --Define the GameObjects components.
		{"Sprite", 
			x = 0, 
			y = 0, 
			texture = "exampleTexture",
		},
		{"RigidBody", 
			g = 0,
			stiffness = 1,
		},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args) --Inheritance from the GameObject main class.
	this = setmetatable(this, GameObjectsTemplate) --Not sure to be honest, I only know that this is necessary to declare a class/create an object (.^.)
	
	--===== init =====--
	
	this.gameObject:addBoxTrigger({ --Manually add a trigger to use object intern variables in the listed function.
		x = 0,
		y = 0,
		sx = 6, 
		sy = 3,
		
		lf = function(collider, go, selfCall)
			global.log(global.currentFrame, this:getName())
		end
	})
	
	--===== custom functions =====--
	this.key_down = function(this, signal) --Same as the function equevalent in the stateTemplate but called with the additionally conditions as "this.update()".
		
	end
	
	this.ctrl_right_key_pressed = function(this, signal, sname) --Same as the function ctrl_... fucntion in the stateTemplate but called with the additionally conditions from "this.update()".
		this:addForce(5, 0, args.maxSpeed) --Addign force to move the object.
	end
	
	this.ctrl_left_key_pressed = function(this, signal, sname) --Same as the function ctrl_... fucntion in the stateTemplate but called with the additionally conditions from "this.update()".
		this:addForce(-5, 0, args.maxSpeed) --Addign negative force to move the object.
	end
	
	--===== default functions =====--
	this.start = function(this) --Called when this GameObject is added to a RenderArea.
		
	end
	
	this.update = function(this, dt, ra) --Called up to once a frame.
		--global.log(this.gameObject.rigidBodys[1].speedX)
	end
	
	this.draw = function(this) --Called every time the GameObject is drawed. That can happen multiple times a frame if the GameObject is visible in multiple RenderAreas.
	
	end
	
	this.clear = function(this, acctual) --Called every time the GameObject graphics are removed from the screen. That can happen multiple times a frame if the GameObject is visible in multiple RenderAreas.
		
	end
	
	this.stop = function(this) --Called when this GameObject is removed from a RenderArea.
		
	end
	
	return this
end

return GameObjectsTemplate