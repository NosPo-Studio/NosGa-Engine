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
	toInsert.transparent = pa(e.transparent, false)
	table.insert(a, toInsert)
end

function GameObject.new(args)
	args = args or {}
	local this = setmetatable({}, GameObject)
	
	local noSizeArea = pa(args.noSizeArea, false)
	local noAutoSize = pa(args.noAutoSize, false)
	local noAutoClearAreas = pa(args.noAutoClearAreas, true)
	
	this.ngeAttributes = {
		sizeX = pa(args.sx, args.sizeX, 0),
		sizeY = pa(args.sy, args.sizeY, 0),
		layer = pa(args.layer, global.conf.renderLayerAmount),
		name = pa(args.name, ""),
		drawSize = pa(args.ds, args.drawSize, global.conf.debug.drawGameObjectBorders),
		isParent = args.isParent,
		updateAlways = pa(args.updateAlways, false),
		useIWL = pa(args.useIWL, false),
		interactionWhiteList = pa(args.iw, args.iwl, args.interactionWhiteList, {}),
		
		--=== Auto generated ===--
		id, 
		sprites = {},
		lastFramePosX = 0,
		lastFramePosY = 0,
		responsibleRenderAreas = {},
		hasMoved = false,
		isVisibleIn = {},
		lastCalculatedFrame = 0,
		clearAreas = {},
		usesAnimation = pa(args.ua, args.usesAnimation, args.useAnimation),
		alive = true,
	}
	
	args.gameObject = global.ut.parseArgs(args.components, args.gameObject) --ToDo: Completly remove args.gameObject from the code.
	
	this.gameObject = global.ocgf.GameObject.new(global.ocgf, {
		dc = global.conf.debug.drawCollider,
		dt = global.conf.debug.drawTrigger,
		logFunc = global.log,
		posX = pa(args.x, args.posX),
		posY = pa(args.y, args.posY),
		parent = this,
	})
	
	for _, c in pairs(args.gameObject or {}) do
		if c[1] == "BoxCollider" then
			this.gameObject:addBoxCollider(c)
		elseif c[1] == "BoxTrigger" then
			this.gameObject:addBoxTrigger(c)
		elseif c[1] == "RigidBody" then
			this.gameObject:addRigidBody(c)
		elseif c[1] == "Sprite" then
			local sprite, texture, posX, posY = global.core.Sprite.new(c)
			
			if c.texture.format == "OCGLA" or c.texture.format == "pan" then
				this.ngeAttributes.usesAnimation = true
			elseif c.texture.format == "pic" then
				
			end
			
			if not noAutoSize then
				this.sizeX = math.max(this.ngeAttributes.sizeX, posX + texture.resX)
				this.sizeY = math.max(this.ngeAttributes.sizeY, posY + texture.resY)
			end
			
			this.ngeAttributes.sprites[sprite] = true
			--this.gameObject:addSprite(c)
		elseif c[1] == "CopyArea" or c[1] == "ClearArea" then --CopyArea still there for legacy reasons.
			addAreaEntry(this.ngeAttributes.clearAreas, c)
		end
	end
	
	if not noSizeArea and this.ngeAttributes.sizeX > 0 and this.ngeAttributes.sizeY > 0 then
		addAreaEntry(this.ngeAttributes.clearAreas, {posX = 0, posY = 0, sizeX = this.ngeAttributes.sizeX, sizeY = this.ngeAttributes.sizeY, transparent = args.transparent})
	end
	
	
	
	--===== default functions =====--
	this.move = function(this, x, y)
		--x = math.floor(x)
		--y = math.floor(y)
		this.gameObject:move(x, -y)
		this.ngeAttributes.hasMoved = true
	end
	this.moveTo = function(this, x, y)
		--x = math.floor(x)
		--y = math.floor(y)
		this.gameObject:moveTo(x, y)
		this.ngeAttributes.hasMoved = true
	end
	this.addForce = function(this, x, y, maxSpeed)
		this.gameObject:addForce(x, y, maxSpeed)
	end
	this.addSpeed = function(this, x, y, maxSpeed) --ToDo / WIP: buggy. Outsource to ocgf.
		local x2, y2 = this:getSpeed()
		maxSpeed = maxSpeed or math.huge
		if x > 0 then
			x = math.min(x + x2, maxSpeed)
		else
			x = math.max(x + x2, -maxSpeed)
		end
		if y > 0 then
			y = math.min(y + y2, maxSpeed)
		else
			y = math.max(y + y2, -maxSpeed)
		end
		this.gameObject:setSpeed(x, -y)
	end
	this.setSpeed = function(this, x, y)
		this.gameObject:setSpeed(x, -y)
	end
	this.getPos = function(this)
		return math.floor(this.gameObject.posX +.5), math.floor(this.gameObject.posY +.5)
	end
	this.getSpeed = function(this)
		return this.gameObject:getSpeed()
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
	this.getOffset = function(this, ra) --legacy support.
		return ra:getOffset()
	end
	this.destroy = function(this)
		for ra in pairs(this.ngeAttributes.responsibleRenderAreas) do
			this.ngeAttributes.alive = false
			ra:remGO(this)
			return
		end
	end
	this.attach = function(this, gameObject)
		this.gameObject:attach(gameObject.gameObject)
	end
	this.detach = function(this)
		this.gameObject:detach()
	end
	this.rerender = function(this)
		for ra in pairs(this.ngeAttributes.responsibleRenderAreas) do
			if ra.gameObjectAttributes[this] ~= nil then
				ra.gameObjectAttributes[this].mustBeRendered = true
				this.ngeAttributes.isRerendered = true
			end
		end
		
		this.ngeAttributes.hasMoved = true
		
		this:ngeAddToRenderQueue()
	end
	this.addIWL = function(this, go)
		this.ngeAttributes.interactionWhiteList[go] = true
	end
	this.remIWL = function(this, go)
		this.ngeAttributes.interactionWhiteList[go] = nil
	end
	this.activateIWL = function(this, IWL)
		this.ngeAttributes.useIWL = true
		this:setIWL(IWL)
	end
	this.setIWL = function(this, IWL)
		if IWL ~= nil then
			this.ngeAttributes.interactionWhiteList = IWL
		end
	end
	this.getIWL = function(this)
		return this.ngeAttributes.interactionWhiteList
	end
	this.deactivateIWL = function(this)
		this.ngeAttributes.useIWL = false
	end
	this.getLayer = function(this)
		return this.ngeAttributes.layer
	end
	
	--===== engine functions =====--
	this.ngeStart = function(this) --parent func 
		if this.ngeAttributes.isParent then
			global.run(this.pStart, this)
		else
			global.run(this.start, this)
		end
	end
	this.ngeUpdate = function(this, gameObjects, dt, ra) --parent func
		local ocgfGameObjects = {}
		local posX, posY = this:getPos()
		local lastPosX, lastPosY = this:getLastPos()
		
		if this.ngeAttributes.useIWL then
			gameObjects = this.ngeAttributes.interactionWhiteList
		end
		
		for go in pairs(gameObjects) do
			table.insert(ocgfGameObjects, go.gameObject)
		end
		
		
		this.gameObject:updatePhx(ocgfGameObjects, dt)
		this.gameObject:update(ocgfGameObjects)
		
		if this.ngeAttributes.isParent then
			global.run(this.pUpdate, this, dt, ra, gameObjects, ocgfGameObjects)
		else
			global.run(this.update, this, dt, ra, gameObjects, ocgfGameObjects)
		end
		
		
		
		if posX ~= lastPosX or posY ~= lastPosY then
			this:ngeAddToRenderQueue()
			this.ngeAttributes.hasMoved = true
		end
		
		this.ngeAttributes.isUpdated = true
	end
	this.ngeActivate = function(this) --parent func
		if this.ngeAttributes.isParent then
			global.run(this.pActivate, this)
		else
			global.run(this.activate, this)
		end
	end
	
	this.ngeIsInsideRenderArea = function(this, area, screenPos) --ToDo: fix.
		local posX, posY = this:getPos()
		local sizeX, sizeY = this:getSize()
		
		
		--[[
		global.log(posX, posY)
		
		global.log(global.ut.tostring(area))
		global.log(posX , sizeX , area.posX , posX , area.posX , area.sizeX ,
			posY , sizeY , area.posY , posY , area.posY , area.sizeY)
			
		global.log(posX + sizeX > area.posX , posX < area.posX + area.sizeX ,
			posY + sizeY > area.posY , posY < area.posY + area.sizeY)
		]]
		if  
			posX + sizeX > area.posX and posX < area.posX + area.sizeX and
			posY + sizeY > area.posY and posY < area.posY + area.sizeY
		then
			return true
		end
		
		return false
	end
	
	
	
	this.ngeClear = function(this, areas, offsetX, offsetY) --parent func
		local posX, posY = this:getLastPos()
		
		for _, area in pairs(areas) do
			area = {area.posX, area.posX + area.sizeX -1, area.posY, area.posY + area.sizeY -1}
			
			for _, ca in pairs(this.ngeAttributes.clearAreas) do
				global.oclrl:draw(posX + ca.posX - offsetX, posY + ca.posY - offsetY, global.oclrl.generateTexture(0, 0, ca.sizeX, ca.sizeY, " "), nil, area)
			end
		end
	end
	this.ngeDraw = function(this, renderArea, areas, offsetX, offsetY) --parent func
		local posX, posY = this:getPos()
		for _, area in pairs(areas) do
			for s in pairs(this.ngeAttributes.sprites) do
				s:draw(renderArea, area, posX - offsetX, posY - offsetY)
			end
		end
	end
	
	
	
	this.ngeSUpdate = function(this, gameObjects, dt, ra) --parent func
		if this.ngeAttributes.isParent then
			global.run(this.pSUpdate, this, dt, ra)
		else
			global.run(this.sUpdate, this, dt, ra)
		end
		this.ngeAttributes.isRerendered = false
		this:ngeSetLastPos()
	end
	this.ngeSetLastPos = function(this)
		this.ngeAttributes.lastFramePosX = math.floor(this.gameObject.posX +.5)
		this.ngeAttributes.lastFramePosY = math.floor(this.gameObject.posY +.5)
		
		this.ngeAttributes.hasMoved = false
	end
	this.ngeStop = function(this)
		this.gameObject:stop()
		if this.ngeAttributes.isParent then
			global.run(this.pStop, this)
		else
			global.run(this.stop, this)
		end
		this.gameObject:stop()
	end
	this.ngeSpawn = function(this) --parent func
		if this.ngeAttributes.isParent then
			global.run(this.pSpawn, this)
		else
			global.run(this.spawn, this)
		end
	end
	this.ngeDespawn = function(this) --parent func
		if this.ngeAttributes.isParent then
			global.run(this.pDespawn, this)
		else
			global.run(this.despawn, this)
		end
	end
	this.ngeAddToRenderQueue = function(this)
		global.core.re.toRender[this] = true
	end
	
	return this
end

return GameObject