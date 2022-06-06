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

UiContainer = {}
UiContainer.__index = UiContainer

function UiContainer.init(this) 
	
end

function UiContainer.new(args) 
	local pa = global.ut.parseArgs
	
	args = args or {} 
	args.isParent = true
	
	--===== default stuff =====--
	local this = global.newGameObject(args)
	
	--===== init =====--
	this.name = args.name
	this.type = args.type
	
	--===== custom functions =====--
	
	--===== default functions =====--
	this.pStart = function(this) 
		global.run(this.start, this)
	end
	
	this.pUpdate = function(this, dt, ra, gameObjects, ocgfGameObjects) 
		global.run(this.update, this, dt, ra, this.particles, particleGameObjects)
	end
	
	this.pDraw = function(this, renderArea) 
		global.run(this.draw, this, renderArea)
	end
	
	this.pSUpdate = function(this, dt, ra)
		global.run(this.sUpdate, this)
	end
	
	this.pClear = function(this, acctual) 
		global.run(this.clear, this)
	end
	
	this.pStop = function(this) 
		global.run(this.stop, this)
	end
	
	return this
end

return UiContainer