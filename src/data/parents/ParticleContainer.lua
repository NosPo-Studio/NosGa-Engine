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
	this.particle = pa(args.p, args.particle)
	this.type = args.type
	this.color = args.color
	
	this.particles = {}
	this.toMoveX, this.toMoveY, this.newSizeX, this.newSizeY = 0, 0, this.ngeAttributes.sizeX, this.ngeAttributes.sizeY
	
	if type(this.particle) == "string" then
		this.particle = global.gameObject[this.particle]
	end
	
	--===== custom functions =====--
	this.addParticle = function(this, x, y, args)
		args = args or {}
		print("[PC][" .. tostring(this.name) .. "]: Creating particle, F: " .. tostring(global.currentFrame))
		
		local posX, posY = this:getPos()
		args.x = posX + x
		args.y = posY + y
		args.rx = x
		args.ry = y
		
		local particle = this.particle.new(args)
		
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
		local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
		
		for i, c in pairs(this.particles) do
			table.insert(particleGameObjects, c.gameObject)
		end
		
		global.run(this.update, this, dt, ra, this.particles, particleGameObjects)
		
		for i, c in pairs(this.particles) do
			local x, y = c:pUpdate(dt, ra, this.particles, particleGameObjects)
			
			if x < minX then
				minX = x
			end
			if y < minY then
				minY = y
			end
			if x > maxX then
				maxX = x
			end
			if y > maxY then
				maxY = y
			end
			
			if this.type == 1 then
				addRenderMapEntry(renderMap, math.floor(x - posX), math.floor((y - posY) *2 +.5), true)
			end
		end
		
		this.toMoveX, this.toMoveY = math.floor(minX - posX +.5), math.floor(- (minY - posY) +.5)
		this.newSizeX, this.newSizeY = math.floor((minX - posX) + (maxX - posX) +1 +.5), math.floor((minY - posY) + (maxY - posY) +1 +.5)
		
		if global.conf.useDoubleBuffering == false then
			if this.type == 1 then
				for x, xm in pairs(renderMap) do
					for y, ym in pairs(xm) do 	
						local symbol = ""
						local _, f = math.modf(y /2)
						
						if f == 0 then
							if renderMap[x][y +1] then
								symbol = csParticleType1.full
							else
								symbol = csParticleType1.up
							end
						else
							if renderMap[x][y -1] then
								symbol = csParticleType1.full
							else
								symbol = csParticleType1.low
							end
						end
						
						addRenderMapEntry(toRender, x, math.floor(y /2), symbol)
					end
				end
			end
			
			for x, xm in pairs(toRender) do
				for y, ym in pairs(xm) do 	
					table.insert(texture, {x, y, ym})
				end
			end
			
			this.gameObject.sprites[1].texture = global.oclrl.generateTexture(texture)
		end
	end
	
	this.pDraw = function(this, renderArea) 
		local offsetX, offsetY = this:getOffset(renderArea)
		
		this:move(this.toMoveX, this.toMoveY)
		this.ngeAttributes.sizeX = this.newSizeX
		this.ngeAttributes.sizeY = this.newSizeY
		this.ngeAttributes.clearAreas[1].sizeX = this.newSizeX
		this.ngeAttributes.clearAreas[1].sizeY = this.newSizeY
		
		global.run(this.draw, this, renderArea)
		
		for i, c in pairs(this.particles) do
			c:pDraw(renderArea, offsetX, offsetY)
		end
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