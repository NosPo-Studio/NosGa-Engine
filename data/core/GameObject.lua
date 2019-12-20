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
	local this = setmetatable({}, GameObject)
	
	this.attributes = {
		sizeX = pa(args.sizeX, 0),
		sizeY = pa(args.sizeY, 0),
		layer = pa(args.layer, global.conf.debug.renderLayerAmount),
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
	
	if args.gameObject ~= nil then
		this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
			dc = global.conf.debug.drawCollider,
			dt = global.conf.debug.drawTrigger,
			logFunc = global.log,
			posX = args.posX,
			posY = args.posY,
		})
		
		for _, c in pairs(args.gameObject) do
			if c[1] == "BoxCollider" then
				this.gameObject:addBoxCollider(c)
			elseif c[1] == "BoxTrigger" then
				this.gameObject:addBoxTrigger(c)
			elseif c[1] == "RigidBody" then
				this.gameObject:addRigidBody(c)
			elseif c[1] == "Sprite" then
				this.gameObject:addSprite(c)
			elseif c[1] == "ClearArea" then
				addAreaEntry(this.attributes.clearAreas, c)
			elseif c[1] == "CopyArea" then
				addAreaEntry(this.attributes.clearAreas, c)
				if global.conf.debug.forceSmartMove or global.conf.debug.useSmartMove and global.conf.debug.useDoubleBuffering then
					addAreaEntry(this.attributes.copyAreas, c)
				end
			end
		end
	end
	
	if this.attributes.sizeX > 0 and this.attributes.sizeY > 0 then
		table.insert(this.attributes.clearAreas, {posX = 0, posY = 0, sizeX = this.attributes.sizeX, sizeY = this.attributes.sizeY})
	end
	
	--===== default functions =====--
	this.move = function(this, x, y)
		this.gameObject:move(x, -y)
		--this.attributes.hasMoved = true
	end
	this.moveTo = function(this, x, y)
		this.gameObject:moveTo(x, y)
		--this.attributes.hasMoved = true
	end
	this.addForce = function(this, x, y, maxSpeed)
		this.gameObject:addForce(x * (global.texturePack.size *2), -y * global.texturePack.size, maxSpeed)
	end
	this.setSpeed = function(this, x, y)
		this.gameObject:setSpeed(x, -y)
	end
	this.getPos = function(this)
		return math.floor(this.gameObject.posX), math.floor(this.gameObject.posY)
	end
	this.getRealLastPos = function(this)
		return math.floor(this.gameObject.lastPosX), math.floor(this.gameObject.lastPosY)
	end
	this.getLastPos = function(this)
		return math.floor(this.attributes.lastFramePosX), math.floor(this.attributes.lastFramePosY)
	end
	this.getSize = function(this)
		return this.attributes.sizeX, this.attributes.sizeY
	end
	this.getRA = function(this)
		for ra in pairs(this.attributes.responsibleRenderAreas) do
			if ra.parent == nil then
				return ra
			else
				return ra.parent
			end
		end
	end
	this.getOffset = function(this, ra)
		return ra.posX + ra.cameraPosX, ra.posY + ra.cameraPosY
	end
	this.destroy = function(this)
		for ra in pairs(this.attributes.responsibleRenderAreas) do
			ra:remGO(this)
			return
		end
	end
	
	--===== engine functions =====--
	this.pStart = function(this) --parent func 
		global.run(this.start, this)
	end
	this.pUpdate = function(this, gameObjects, dt, ra) --parent func
		this.gameObject:updatePhx(gameObjects, dt)
		this.gameObject:update(gameObjects)
		global.run(this.update, this, dt, ra)
		
		local x, y = this:getPos()
		local lx, ly = this:getLastPos()
		if x ~= lx or y ~= ly then
			this.attributes.hasMoved = true
			if global.conf.debug.forceSmartMove or global.conf.debug.useSmartMove and global.conf.debug.useDoubleBuffering then
				for ra in pairs(this.attributes.responsibleRenderAreas) do
					local offsetX, offsetY = this:getOffset(ra)
					for i, ca in pairs(this.attributes.copyAreas) do
						table.insert(ra.copyInstructions, {ca.posX +lx +offsetX, ca.posY +ly +offsetY, ca.sizeX, ca.sizeY, -(lx - x), -(ly - y)})
					end
				end
			end
		end
		
		this.attributes.isUpdated = true
	end
	this.pActivate = function(this) --parent func
		global.run(this.activate, this)
	end
	this.pDraw = function(this, renderArea) --parent func	
		local realArea = renderArea.realArea or renderArea
		
		local offsetX, offsetY = this:getOffset(realArea)
		
		for _, s in pairs(this.gameObject:getSprites()) do
			s.background = global.backgroundColor
		end
		
		if renderArea.realArea ~= nil and this.attributes.hasMoved ~= true then
			for i, ra in pairs(renderArea) do
				if i ~= "realArea" then
					this.gameObject:draw(offsetX, offsetY, {ra.posX, ra.posX + ra.sizeX -1, ra.posY, ra.posY + ra.sizeY -1})
				end
			end
		elseif renderArea.realArea == nil then
			this.gameObject:draw(offsetX, offsetY, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1})
		else
			this.gameObject:draw(offsetX, offsetY, {realArea.posX, realArea.posX + realArea.sizeX -1, realArea.posY, realArea.posY + realArea.sizeY -1})
		end
			
		global.run(this.draw, this, realArea, renderArea)
		
		realArea.gameObjectAttributes[this.attributes.id].mustBeRendered = false
		realArea.gameObjectAttributes[this.attributes.id].wasVisible = true
	end
	this.pClear = function(this, renderArea) --parent func
		local offsetX, offsetY = renderArea.posX + renderArea.cameraPosX, renderArea.posY + renderArea.cameraPosY
		local lastPosX, lastPosY = this:getLastPos()
		local posX, posY = this:getPos()
		
		global.run(this.clear, this, renderArea)
		
		global.gpu.setBackground(global.backgroundColor)
		
		for i, ca in pairs(this.attributes.clearAreas) do
			global.ocgl:draw(0, 0, global.ocgl.generateTexture(lastPosX + offsetX + ca.posX, lastPosY + offsetY + ca.posY, ca.sizeX, ca.sizeY, " "), nil, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1})
		end
		for i, ca in pairs(this.attributes.copyAreas) do
			if ca.solid ~= true then
				global.ocgl:draw(0, 0, global.ocgl.generateTexture(posX + offsetX + ca.posX, posY + offsetY + ca.posY, ca.sizeX, ca.sizeY, " "), nil, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1})
			end
		end
	end
	this.pSetLastPos = function(this)
		this.attributes.lastFramePosX = math.floor(this.gameObject.posX)
		this.attributes.lastFramePosY = math.floor(this.gameObject.posY)
		
		this.attributes.hasMoved = false
	end
	this.pStop = function(this)
		this.gameObject:stop()
		global.run(this.stop, this)
		this.gameObject:stop()
	end
	this.pSpawn = function(this) --parent func
		global.run(this.spawn, this)
	end
	this.pDespawn = function(this) --parent func
		global.run(this.despawn, this)
	end
	
	return this
end

return GameObject