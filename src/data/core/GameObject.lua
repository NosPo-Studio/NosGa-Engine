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
	local this = setmetatable({}, GameObject)

	this.ngeAttributes = {
		sizeX = pa(args.sx, args.sizeX, 0),
		sizeY = pa(args.sy, args.sizeY, 0),
		layer = pa(args.layer, global.conf.renderLayerAmount),
		name = pa(args.name, ""),
		drawSize = pa(args.ds, args.drawSize, global.conf.debug.drawGameObjectBorders),
		isParent = args.isParent,
		updateAlways = pa(args.updateAlways, false),
		isLoaded = false,

		updateOCGFGameObject = pa(args.calcInternalGameObject, args.internalGameObject, args.updateInternalGameObject, not args.deco --[[is true if deco is nil]], false), --if set to true this gameobject will not calulate own physics.
		updatePhysics = pa(args.calcPhysics, args.physics, args.updatePhysics, not args.deco --[[is true if deco is nil]], false), --if set to true this gameobject will not the own internal gameobject. thi smean sthat triggers an co will not work.

		ignoreOCGFGameObject = pa(args.ignoreGameObject, args.deco, false), --if set to true other objects will not interact with this. so triggers and vco will not get trigered.
		
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
		usesAnimation = pa(args.ua, args.animation, args.usesAnimation, args.useAnimation),
		clearedAlready,
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
			if type(c.texture) == "string" then
				c.texture = global.texture[c.texture]
			end

			assert(c.texture, "Cant add GameObject. No texture given.")
			
			if c.texture.format == "OCGLA" or c.texture.format == "pan" then
				this.ngeAttributes.usesAnimation = true
			elseif c.texture.format == "pic" then
				
			end
			
			this.gameObject:addSprite(c)
		elseif c[1] == "CopyArea" or c[1] == "ClearArea" then
			addAreaEntry(this.ngeAttributes.clearAreas, c)
			if global.conf.forceSmartMove or global.conf.useSmartMove and global.conf.useDoubleBuffering then
				addAreaEntry(this.ngeAttributes.copyAreas, c)
			end
		end
	end
	
	if args.noSizeArea ~= true and this.ngeAttributes.sizeX > 0 and this.ngeAttributes.sizeY > 0 then
		addAreaEntry(this.ngeAttributes.clearAreas, {posX = 0, posY = 0, sizeX = this.ngeAttributes.sizeX, sizeY = this.ngeAttributes.sizeY})
		addAreaEntry(this.ngeAttributes.copyAreas, {posX = 0, posY = 0, sizeX = this.ngeAttributes.sizeX, sizeY = this.ngeAttributes.sizeY})
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
	this.getOffset = function(this, ra)
		return math.floor(ra.posX + ra.cameraPosX +.5), math.floor(ra.posY + ra.cameraPosY +.5)
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
			end
		end
		
		this.ngeAttributes.hasMoved = true
	end
	
	--===== engine functions =====--
	this.ngeStart = function(this) --parent func 
		if this.ngeAttributes.isParent then
			global.run(this.pStart, this)
		else
			global.run(this.start, this)
		end
	end
	this.ngeUpdate = function(this, ocgfGameObjects, dt, ra) --parent func
		local insert = table.insert
		local ngeAttributes = this.ngeAttributes
		
		if this.test then
			--global.log(#ocgfGameObjects)
		end
		
		ngeAttributes.clearedAlready = nil

		if ngeAttributes.updatePhysics then
			this.gameObject:updatePhx(ocgfGameObjects, dt)
		end
		if ngeAttributes.updateOCGFGameObject then
			this.gameObject:update(ocgfGameObjects)
		end
		
		if ngeAttributes.isParent then
			global.run(this.pUpdate, this, dt, ra, ocgfGameObjects, ocgfGameObjects)
		else
			global.run(this.update, this, dt, ra, ocgfGameObjects, ocgfGameObjects)
		end
		
		local x, y = this:getPos()
		local lx, ly = this:getLastPos()
		
		if x ~= lx or y ~= ly or ngeAttributes.usesAnimation == true then
			ngeAttributes.hasMoved = true
			if global.conf.forceSmartMove or global.conf.useSmartMove and global.conf.useDoubleBuffering then
				for ra in pairs(ngeAttributes.responsibleRenderAreas) do
					local offsetX, offsetY = this:getOffset(ra)
					for i, ca in pairs(ngeAttributes.copyAreas) do
						insert(ra.copyInstructions, {ca.posX +lx +offsetX, ca.posY +ly +offsetY, ca.sizeX, ca.sizeY, -(lx - x), -(ly - y)})
					end
				end
			end
		end
		
		ngeAttributes.isUpdated = true
	end
	this.ngeActivate = function(this) --parent func
		if this.ngeAttributes.isParent then
			global.run(this.pActivate, this)
		else
			global.run(this.activate, this)
		end
	end
	this.ngeDraw = function(this, renderArea) --parent func
		local realArea = renderArea.realArea or renderArea
		local offsetX, offsetY = this:getOffset(realArea)
		
		for _, s in pairs(this.gameObject:getSprites()) do
			s.background = global.backgroundColor
		end

		--print(this:getName(), this.ngeAttributes.hasMoved)

		if 
			#realArea.gameObjectAttributes[this].overlappingAreas == 0 and realArea.gameObjectAttributes[this].mustBeRendered or 
			not realArea.gameObjectAttributes[this].hasBeenRenderedOnce or
			this.ngeAttributes.hasMoved
		then
			realArea.gameObjectAttributes[this].overlappingAreas = {{-math.huge, math.huge, -math.huge, math.huge}}
		end

		if renderArea.realArea ~= nil and this.ngeAttributes.hasMoved ~= true then --draw areas needed cause camera movement.
			for i, ra in pairs(renderArea) do
				if i ~= "realArea" then
					this.gameObject:draw(offsetX, offsetY, {ra.posX, ra.posX + ra.sizeX -1, ra.posY, ra.posY + ra.sizeY -1}, global.dt, global.backgroundColor)
				end
			end
		end

		for _, overlappingArea in pairs(realArea.gameObjectAttributes[this].overlappingAreas) do
			do
				local rx, _, ry, _ = realArea:getRealFOV()
				local x, _, y, _ = realArea:getFOV()

				this.gameObject:draw(offsetX, offsetY, {
					math.max(realArea.posX, overlappingArea[1] + rx - x), 
					math.min(realArea.posX + realArea.sizeX -1, overlappingArea[2] + rx - x), 
					math.max(realArea.posY, overlappingArea[3] + ry - y), 
					math.min(realArea.posY + realArea.sizeY -1, overlappingArea[4] + ry - y)}, 
				global.dt, global.backgroundColor)
			end
		end

		realArea.gameObjectAttributes[this].overlappingAreas = {}

		
		if this.ngeAttributes.isParent then
			global.run(this.pDraw, this, realArea, offsetX, offsetY)
		else
			global.run(this.draw, this, realArea, offsetX, offsetY)
		end
		
		if realArea.gameObjectAttributes[this] == nil then --WIP: ToDo: Deeper problem?
			realArea.gameObjectAttributes[this] = {}
		end
		realArea.gameObjectAttributes[this].mustBeRendered = false
		realArea.gameObjectAttributes[this].wasVisible = true
		
		if this.ngeAttributes.drawSize then
			local posX, posY = this:getPos()
			
			global.oclrl:draw(posX + offsetX, posY + offsetY, global.oclrl.generateTexture({
				{"b", 0xFF69B4},
				{0, 0, this.ngeAttributes.sizeX, 1, " "},
				{0, this.ngeAttributes.sizeY -1, this.ngeAttributes.sizeX, 1, " "},
				{0, 0, 1, this.ngeAttributes.sizeY, " "},
				{this.ngeAttributes.sizeX -1, 0, 1, this.ngeAttributes.sizeY, " "},
			}), true, {realArea:getRealFOV()})
		end
		realArea.gameObjectAttributes[this].hasBeenRenderedOnce = true
	end
	this.ngeClear = function(this, renderArea) --parent func
		local offsetX, offsetY = renderArea.posX + renderArea.cameraPosX, renderArea.posY + renderArea.cameraPosY
		local lastPosX, lastPosY = this:getLastPos()
		local posX, posY = this:getPos()
		
		if this.ngeAttributes.isParent then
			global.run(this.pClear, this, renderArea)
		else
			global.run(this.clear, this, renderArea)
		end
		
		global.gpu.setBackground(global.backgroundColor)
		
		for i, ca in pairs(this.ngeAttributes.clearAreas) do
			global.oclrl:draw(0, 0, global.oclrl.generateTexture(lastPosX + offsetX + ca.posX, lastPosY + offsetY + ca.posY, ca.sizeX, ca.sizeY, " "), nil, renderArea.sizeArray)
		end
		for i, ca in pairs(this.ngeAttributes.copyAreas) do
			if ca.solid ~= true then
				global.oclrl:draw(0, 0, global.oclrl.generateTexture(posX + offsetX + ca.posX, posY + offsetY + ca.posY, ca.sizeX, ca.sizeY, " "), nil, renderArea.sizeArray)
			end
		end
	end
	this.ngeSUpdate = function(this, gameObjects, dt, ra) --parent func
		if this.ngeAttributes.isParent then
			global.run(this.pSUpdate, this, dt, ra)
		else
			global.run(this.sUpdate, this, dt, ra)
		end
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
	this.ngeLoad = function(this, renderArea) --parent func
		this.ngeAttributes.isLoaded = true
		if this.ngeAttributes.isParent then
			global.run(this.pSpawn, this)
		else
			global.run(this.spawn, this)
		end
	end
	this.ngeUnload = function(this, renderArea) --parent func		
		this.ngeAttributes.isLoaded = false
		if this.ngeAttributes.isParent then
			global.run(this.pDespawn, this)
		else
			global.run(this.despawn, this)
		end
	end
	
	return this
end

return GameObject