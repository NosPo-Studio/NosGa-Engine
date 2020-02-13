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

--[[
ToDo:
	Add braille char support (doubleing the particle resolution) (https://en.wikipedia.org/wiki/Braille_Patterns).
	
]]

local global = ...

local csParticleType1 = {
	up = "▀",
	low = "▄",
	full = "█",
}

local function print(...)
	if global.conf.debug.pcDebug then
		global.debug(...)
	end
end

local function addRenderMapEntry(map, x, y, entry)
	if map[x] == nil then
		map[x] = {}
	end
	map[x][y] = entry
end

local function move(this, x, y, sx, sy)
	--this:move(x, y)
	this:moveTo(x, y)
	this.ngeAttributes.sizeX = sx
	this.ngeAttributes.sizeY = sy
	this.ngeAttributes.clearAreas[1].sizeX = sx
	this.ngeAttributes.clearAreas[1].sizeY = sy
	this.hasMoved = true
end

ParticleContainer = {}
ParticleContainer.__index = ParticleContainer

function ParticleContainer.init(this) 
	
end

function ParticleContainer.new(args) 
	args = args or {} 
	args.isParent = true
	args.useAnimation = true
	args.sizeX = 1
	args.sizeY = 1
	args.solid = false
	
	args.components = {
		{"Sprite", posX = 0, posY = 0, texture = global.oclrl.generateTexture({})},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args) 
	this = setmetatable(this, ParticleContainer) 
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.name = args.name
	this.type = args.type
	this.color = args.color
	this.particleSizeX = 1
	
	if this.type == 2 then
		this.particleSizeX = 2
	end
	
	this.particles = {}
	this.moveToX, this.moveToY, this.newSizeX, this.newSizeY = 0, 0, this.ngeAttributes.sizeX, this.ngeAttributes.sizeY
	this.hasMoved = false
	this.lastMaxX = -2^32
	this.lastMaxY = -2^32
	
	
	--===== custom functions =====--
	this.addParticle = function(this, particle, x, y, args)
		args = args or {}
		print("[PC][" .. tostring(this.name) .. "]: Creating particle, F: " .. tostring(global.currentFrame))
		
		local posX, posY = this:getPos()
		args.x = x
		args.y = y
		
		if type(this.particle) == "string" then
			particle = global.gameObject[this.particle]
		end
		particle = particle.new(args)
		
		print("[PC][" .. tostring(this.name) .. "]: Adding particle: " .. tostring(particle.name) .. ", X: " ..tostring(x) .. ", Y: " .. tostring(y) .. ", F: " .. tostring(global.currentFrame))
		
		table.insert(this.particles, particle)
	end
	
	--===== default functions =====--
	this.pStart = function(this) 
		global.run(this.start, this)
	end
	
	this.pUpdate = function(this, dt, ra) 
		local offsetX, offsetY = this:getOffset(ra)
		local particleGameObjects = {}
		local particlePositions = {}
		local renderMap = {}
		local toRender = {}
		local texture = {{"f", this.color}}
		local posX, posY = this:getPos()
		local minX, maxX, minY, maxY = 2^32, -2^32, 2^32, -2^32
		local particleCount = 0
		local isVisible = false
		
		move(this, this.moveToX, this.moveToY, this.newSizeX, this.newSizeY)
	
		for i, c in pairs(this.particles) do
			table.insert(particleGameObjects, c.gameObject)
		end
		
		global.run(this.update, this, dt, ra, this.particles, particleGameObjects)
		
		for i, c in pairs(this.particles) do
			local x, y = c:pUpdate(dt, ra, this.particles, particleGameObjects)
			
			minX = math.min(x, minX)
			minY = math.min(y, minY)
			maxX = math.max(x, maxX)
			maxY = math.max(y, maxY)
			
			if this.type == 1 then
				addRenderMapEntry(renderMap, math.floor(x - posX), math.floor((y - posY) *2 +.5), true)
			end
			particleCount = particleCount +1
		end
		
		if particleCount > 0 then
			this.hasMoved = false
			
			this.moveToX, this.moveToY = math.floor(minX), math.floor(minY)
			
			local sx, sy = 0, 0
			
			if maxX > this.lastMaxX then
				sx = maxX - this.moveToX
			else
				sx = this.lastMaxX - this.moveToX
			end
			if maxY > this.lastMaxY then
				sy = maxY - this.moveToY
			else
				sy = this.lastMaxY - this.moveToY
			end
			
			this.newSizeX = sx +2 +this.particleSizeX
			this.newSizeY = sy +2
			
			this.lastMaxX = maxX
			this.lastMaxY = maxY
			
			--[[
			this.moveToX, this.moveToY = math.floor(minX - posX), math.floor(- (minY - posY))
			
			local x, y = math.abs(this.moveToX), math.abs(this.moveToY)
			
			if this.moveToY > 0 then
				y = y *2
			end
			if this.moveToX < 0 then
				x = x *2
			end
			
			this.newSizeX = math.floor(x + (maxX - posX) +.5) +1
			this.newSizeY = math.floor(y + (maxY - posY) +.5) +1
			]]
		end
		
		for ra, s in pairs(this.ngeAttributes.isVisibleIn) do
			this:ngeClear(ra)
			
			--isVisible = true
			--break
		end
		if not isVisible then
			--move(this, this.moveToX, this.moveToY, this.newSizeX, this.newSizeY)
		end
		
		this.ngeAttributes.clearedAlready = true
		move(this, this.moveToX, this.moveToY, this.newSizeX, this.newSizeY)
	end
	
	this.pDraw = function(this, renderArea) 
		local offsetX, offsetY = this:getOffset(renderArea)
		
		if this.hasMoved == false then	
			--global.log(this.moveToX, this.moveToY, this.newSizeX, this.newSizeY)
			
			--move(this, this.moveToX, this.moveToY, this.newSizeX, this.newSizeY)
		end
		
		global.run(this.draw, this, renderArea)
		
		for i, c in pairs(this.particles) do
			c:pDraw(renderArea, offsetX, offsetY, this.type)
		end
	end
	
	this.pSUpdate = function(this, dt, ra)
		--move(this, this.moveToX, this.moveToY, this.newSizeX, this.newSizeY)
	end
	
	this.pClear = function(this, acctual) 
		global.run(this.clear, this)
	end
	
	this.pStop = function(this) 
		global.run(this.stop, this)
	end
	
	return this
end

return ParticleContainer