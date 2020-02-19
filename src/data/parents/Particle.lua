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
	this.color = pa(args.color, 0xFF69B4)
	this.maxLifeTime = pa(args.pt, args.lifeTime, args.maxLifeTime, -1)
	
	this.container = args.container
	this.lifeTime = pa(args.clt, args.currentLifeTime, 0)
	
	this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
		dc = global.conf.debug.drawCollider,
		dt = global.conf.debug.drawTrigger,
		logFunc = global.log,
		posX = pa(args.x, args.posX),
		posY = pa(args.y, args.posY),
		parent = this,
	})
	
	--===== custom functions =====--
	
	--===== default functions =====--
	this.pStart = function(this) 
		global.run(this.start, this)
	end
	
	this.pUpdate = function(this, dt, ra, particles, particleGameObjects) 
		
		
		this.lifeTime = this.lifeTime +dt
		if this.maxLifeTime ~= -1 and this.lifeTime > this.maxLifeTime then
			this:destroy()
		end
		
		--global.log(this.lifeTime)
		
		this.gameObject:updatePhx(particleGameObjects, dt)
		this.gameObject:update(particleGameObjects)
		
		global.run(this.update, this, dt, ra, particles, particleGameObjects)
		
		local x, y = this.gameObject:getPos()
		local lx, ly = this.gameObject:getLastPos()
		
		return this.gameObject:getPos()
	end
	
	this.pDraw = function(this, renderArea, offsetX, offsetY, type) 
		
		if global.conf.useDoubleBuffering then
			local x1, y1, x2, y2 = renderArea:getRealFOV()
			
			global.db.setDrawLimit(x1, x2, y1, y2)
			
			if type == 1 then
				local x, y = this.gameObject:getPos()
				x = math.floor(x +offsetX +.5)
				y = math.floor((y +offsetY) *2 +.5)
				global.db.semiPixelSet(x, y, this.color)
			elseif type == 2 then
				local x, y = this.gameObject:getPos()
				x = math.floor(x +offsetX +.5)
				y = math.floor(y +offsetY +.5)
				global.db.set(x, y, this.color, 0x000000, " ")
			elseif type == 3 then
				local x, y = this.gameObject:getPos()
				x = math.floor(x +offsetX +.5)
				y = math.floor(y +offsetY +.5)
				global.db.set(x, y, this.color, 0x000000, " ")
				global.db.set(x +1, y, this.color, 0x000000, " ")
			end
			
			global.db.resetDrawLimit()
		end
		
		global.run(this.draw, this, renderArea, offsetX, offsetY)
	end
	
	this.pClear = function(this, acctual) 
		global.run(this.clear, this)
	end
	
	this.pStop = function(this) 
		global.run(this.stop, this)
	end
	
	this.destroy = function(this)
		this.container:remParticle(this)
	end
	
	return this
end

return Particle
