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

Particle = {}
Particle.__index = Particle

function Particle.init(this) 
	
end

function Particle.new(args) 
	local pa = global.ut.parseArgs
	--===== default stuff =====--
	local this = {}
	this = setmetatable(this, Particle) 
	
	--===== init =====--
	this.name = args.name
	this.type = args.type -- 1 == half size pixel, 2 == full size pixel, 3 == 2 pixels.
	this.color = pa(args.color, 0xFF69B4)
	this.relativePosX = args.rx
	this.relativePosY = args.ry
	
	
	this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
		dc = global.conf.debug.drawCollider,
		dt = global.conf.debug.drawTrigger,
		logFunc = global.log,
		posX = pa(args.x, args.posX),
		posY = pa(args.y, args.posY),
	})
	
	--===== custom functions =====--
	
	--===== default functions =====--
	this.pStart = function(this) 
		global.run(this.start, this)
	end
	
	this.pUpdate = function(this, dt, ra, particles, particleGameObjects) 
		this.gameObject:updatePhx(particleGameObjects, dt)
		this.gameObject:update(particleGameObjects)
		
		global.run(this.update, this, dt, ra, particles, particleGameObjects)
		
		local x, y = this.gameObject:getPos()
		local lx, ly = this.gameObject:getLastPos()
		
		return this.gameObject:getPos()
	end
	
	this.pDraw = function(this, renderArea, offsetX, offsetY) 
		if global.conf.useDoubleBuffering then
			local x, y = this.gameObject:getPos()
			x = math.floor(x +offsetX +.5)
			y = math.floor((y +offsetY) *2 +.5)
			global.db.semiPixelSet(x, y, this.color)
		end
		
		global.run(this.draw, this, renderArea, offsetX, offsetY)
	end
	
	this.pClear = function(this, acctual) 
		global.run(this.clear, this)
	end
	
	this.pStop = function(this) 
		global.run(this.stop, this)
	end
	
	return this
end

return Particle