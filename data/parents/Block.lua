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

--Block main class
local global = ...

local Block = {version = "v0.0d"}
Block.__index = Block

function Block.init(this) --parent func
	
end

function Block.new(args)
	local this = setmetatable({}, Block)
	this.id = blockId
	
	this.hardness = args.hardness or 0
	this.damage = args.damage or 0
	
	if type(args.texture) == "string" then
		args.texture = global.textures[args.texture]
	end
	
	this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
		dc = global.conf.debug.drawCollider,
		x = args.posX,
		y = args.posY
	})
	this.gameObject:addBoxCollider({
		sx = global.texturePack.size *2, 
		sy = global.texturePack.size, 
	})
	this.gameObject:addSprite({
		texture = args.texture or global.ocgl:generateTexture(),
	})
	
	this.getPos = function()
		return global.getBlockPos(this.gameObject.posX, this.gameObject.posY)
	end
	
	this.pRemoved = function(this) --parent func
		global.run(this.removed, this)
	end
	this.pPlaced = function(this) --parent func
		global.run(this.placed, this)
	end
	this.pStart = function(this) --parent func 
		global.run(this.start, this)
	end
	this.pUpdate = function(this)
		global.run(this.update, this)
	end
	this.pDraw = function(this)
		this.gameObject:draw()
		global.run(this.draw, this)
	end
	this.pClear = function(this, acctual)
		this.gameObject:clear(global.backgroundColor, acctual)
		global.run(this.clear, this)
	end
	this.pStop = function(this)
		global.run(this.stop, this)
	end
	this.pActivate = function(this) --parent func
		global.run(this.activate, this)
	end
	
	return this
end

return Block