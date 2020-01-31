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

local GameObject = {}
GameObject.__index = GameObject

function GameObject.init()
	
end

local pa = global.ut.parseArgs

local function addAreaEntry(a, e)
	local toInsert = {}
	toInsert.posX = pa(e.x, e.posX, 0)
	toInsert.posY = pa(e.y, e.posY, 0)
	toInsert.sizeX = pa(e.sx, e.sizeX, 0)
	toInsert.sizeY = pa(e.sy, e.sizeY, 0)
	toInsert.solid = pa(e.solid, false)
	table.insert(a, toInsert)
end

function GameObject.new(args)
	args = args or {}
	local this = setmetatable(this or {}, GameObject)
	
	this.ngeAttributes = {
		sizeX = pa(args.sx, args.sizeX, 0),
		sizeY = pa(args.sy, args.sizeY, 0),
		layer = pa(args.layer, global.conf.renderLayerAmount),
		name = args.name,
		
		--=== Auto generated ===--
		id, 
		lastFramePosX = 0,
		lastFramePosY = 0,
		responsibleRenderAreas = {},
		hasMoved = false,
		isVisibleIn = {},
		lastCalculatedFrame = 0,
		clearAreas = {},
		copyAreas = {},
	}
	
	args.gameObject = global.ut.parseArgs(args.components, args.gameObject) --ToDo: Completly remove args.gameObject from the code.
	
	if args.gameObject ~= nil then
		this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
			dc = global.conf.debug.drawCollider,
			dt = global.conf.debug.drawTrigger,
			logFunc = global.log,
			posX = pa(args.x, args.posX),
			posY = pa(args.y, args.posY),
		})
		
		for _, c in pairs(args.gameObject) do
			if c[1] == "BoxCollider" then
				this.gameObject:addBoxCollider(c)
			elseif c[1] == "BoxTrigger" then
				this.gameObject:addBoxTrigger(c)
			elseif c[1] == "RigidBody" then
				this.gameObject:addRigidBody(c)
			elseif c[1] == "Sprite" then
				if type(c.texture) == "string" then
					c.texture = global.texture[c.texture]
				end
				
				this.gameObject:addSprite(c)
			elseif c[1] == "CopyArea" or c[1] == "ClearArea" then
				addAreaEntry(this.ngeAttributes.clearAreas, c)
				if global.conf.forceSmartMove or global.conf.useSmartMove and global.conf.useDoubleBuffering then
					addAreaEntry(this.ngeAttributes.copyAreas, c)
				end
			end
		end
	end
	
	if args.noSizeArea ~= true and this.ngeAttributes.sizeX > 0 and this.ngeAttributes.sizeY > 0 then
		table.insert(this.ngeAttributes.clearAreas, {posX = 0, posY = 0, sizeX = this.ngeAttributes.sizeX, sizeY = this.ngeAttributes.sizeY})
	end
	
	--===== default functions =====--
	this.move = function(this, x, y)
		--x = math.floor(x)
		--y = math.floor(y)
		this.gameObject:move(x, -y)
		--this.ngeAttributes.hasMoved = true
	end
	this.moveTo = function(this, x, y)
		--x = math.floor(x)
		--y = math.floor(y)
		this.gameObject:moveTo(x, y)
		--this.ngeAttributes.hasMoved = true
	end
	this.addForce = function(this, x, y, maxSpeed)
		this.gameObject:addForce(x, y, maxSpeed)
	end
	this.addSpeed = function(this, x, y, maxSpeed) --ToDo / WIP: untested. Outsource to ocgf.
		local x2, y2 = this:getSpeed()
		if x > 0 then
			x = math.max(x + x2, maxSpeed)
		else
			x = math.min(x + x2, -maxSpeed)
		end
		if y > 0 then
			y = math.max(y + y2, maxSpeed)
		else
			y = math.min(y + y2, -maxSpeed)
		end
		this.gameObject:setSpeed(x, -y)
	end
	this.setSpeed = function(this, x, y)
		this.gameObject:setSpeed(x, -y)
	end
	this.getPos = function(this)
		return math.floor(this.gameObject.posX +.5), math.floor(this.gameObject.posY +.5)
	end
	this.getScreenPos = function(this)--ToDo: untested.
		return this:getRA():getGOPos(this)
	end
	this.getRealLastPos = function(this)
		return math.floor(this.gameObject.lastPosX +.5), math.floor(this.gameObject.lastPosY +.5)
	end
	this.getLastPos = function(this)
		return math.floor(this.ngeAttributes.lastFramePosX +.5), math.floor(this.ngeAttributes.lastFramePosY +.5)
	end
	this.getSize = function(this) --ToDo: generate real size dependent on the ClearAreas.
		return this.ngeAttributes.sizeX, this.ngeAttributes.sizeY
	end
	this.getRA = function(this)
		for ra in pairs(this.ngeAttributes.responsibleRenderAreas) do
			if ra.parent == nil then
				return ra
			else
				return ra.parent
			end
		end
	end
	this.getName = function(this)
		return this.ngeAttributes.name
	end
	this.getOffset = function(this, ra)
		return math.floor(ra.posX + ra.cameraPosX +.5), math.floor(ra.posY + ra.cameraPosY +.5)
	end
	this.destroy = function(this)
		for ra in pairs(this.ngeAttributes.responsibleRenderAreas) do
			ra:remGO(this)
			return
		end
	end
	
	--===== engine functions =====--
	this.ngeStart = function(this) --parent func 
		global.run(this.start, this)
	end
	this.ngeUpdate = function(this, gameObjects, dt, ra) --parent func
		local ocgfGameObjects = {}
		for i, go in pairs(gameObjects) do
			table.insert(ocgfGameObjects, go.gameObject)
		end
		
		this.gameObject:updatePhx(ocgfGameObjects, dt)
		this.gameObject:update(ocgfGameObjects)
		global.run(this.update, this, dt, ra)
		
		local x, y = this:getPos()
		local lx, ly = this:getLastPos()
		if x ~= lx or y ~= ly then
			this.ngeAttributes.hasMoved = true
			if global.conf.forceSmartMove or global.conf.useSmartMove and global.conf.useDoubleBuffering then
				for ra in pairs(this.ngeAttributes.responsibleRenderAreas) do
					local offsetX, offsetY = this:getOffset(ra)
					for i, ca in pairs(this.ngeAttributes.copyAreas) do
						table.insert(ra.copyInstructions, {ca.posX +lx +offsetX, ca.posY +ly +offsetY, ca.sizeX, ca.sizeY, -(lx - x), -(ly - y)})
					end
				end
			end
		end
		
		this.ngeAttributes.isUpdated = true
	end
	this.ngeActivate = function(this) --parent func
		global.run(this.activate, this)
	end
	this.ngeDraw = function(this, renderArea) --parent func
		local realArea = renderArea.realArea or renderArea
		local offsetX, offsetY = this:getOffset(realArea)
		
		for _, s in pairs(this.gameObject:getSprites()) do
			s.background = global.backgroundColor
		end
		
		if renderArea.realArea ~= nil and this.ngeAttributes.hasMoved ~= true then
			for i, ra in pairs(renderArea) do
				if i ~= "realArea" then
					this.gameObject:draw(offsetX, offsetY, {ra.posX, ra.posX + ra.sizeX -1, ra.posY, ra.posY + ra.sizeY -1})
				end
			end
		elseif renderArea.realArea == nil then
			this.gameObject:draw(offsetX, offsetY, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1}, global.dt, global.backgroundColor)
		else
			this.gameObject:draw(offsetX, offsetY, {realArea.posX, realArea.posX + realArea.sizeX -1, realArea.posY, realArea.posY + realArea.sizeY -1}, global.dt, global.backgroundColor)
		end
		
		global.run(this.draw, this, realArea, renderArea)
		
		realArea.gameObjectAttributes[this.ngeAttributes.id].mustBeRendered = false
		realArea.gameObjectAttributes[this.ngeAttributes.id].wasVisible = true
	end
	this.ngeClear = function(this, renderArea) --parent func
		local offsetX, offsetY = renderArea.posX + renderArea.cameraPosX, renderArea.posY + renderArea.cameraPosY
		local lastPosX, lastPosY = this:getLastPos()
		local posX, posY = this:getPos()
		
		global.run(this.clear, this, renderArea)
		
		global.gpu.setBackground(global.backgroundColor)
		
		for i, ca in pairs(this.ngeAttributes.clearAreas) do
			global.oclrl:draw(0, 0, global.oclrl.generateTexture(lastPosX + offsetX + ca.posX, lastPosY + offsetY + ca.posY, ca.sizeX, ca.sizeY, " "), nil, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1})
		end
		for i, ca in pairs(this.ngeAttributes.copyAreas) do
			if ca.solid ~= true then
				global.oclrl:draw(0, 0, global.oclrl.generateTexture(posX + offsetX + ca.posX, posY + offsetY + ca.posY, ca.sizeX, ca.sizeY, " "), nil, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1})
			end
		end
	end
	this.ngeSetLastPos = function(this)
		this.ngeAttributes.lastFramePosX = math.floor(this.gameObject.posX +.5)
		this.ngeAttributes.lastFramePosY = math.floor(this.gameObject.posY +.5)
		
		this.ngeAttributes.hasMoved = false
	end
	this.ngeStop = function(this)
		this.gameObject:stop()
		global.run(this.stop, this)
		this.gameObject:stop()
	end
	this.ngeSpawn = function(this) --parent func
		global.run(this.spawn, this)
	end
	this.ngeDespawn = function(this) --parent func
		global.run(this.despawn, this)
	end
	
	return this
end

return GameObject