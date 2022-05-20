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

--====== local functions =====--
local function print(...)
	if global.conf.debug.raDebug then
		global.debug.log(...)
	end
end

--===== class =====--
local RenderArea = {}
RenderArea.__index = RenderArea

function RenderArea.init()

end

function RenderArea.new(args)
	args = args or {}
	local this = setmetatable({}, RenderArea)
	
	local pa = global.ut.parseArgs
	this.posX = pa(args.x, args.posX, 1)
	this.posY = pa(args.y, args.posY, 1)
	this.sizeX = pa(args.sx, args.sizeX, 0)
	this.sizeY = pa(args.sy, args.sizeY, 0)
	this.layer = pa(args.layer, global.conf.renderLayerAmount)
	this.silent = pa(args.silent, false) --if true the RA is not updating gameObjects.
	this.name = tostring(args.name)
	this.cameraPosX = pa(args.cx, args.cameraPosX, 0)
	this.cameraPosY = pa(args.cy, args.cameraPosY, 0)
	this.lastCameraPosX = this.cameraPosX
	this.lastCameraPosY = this.cameraPosY
	this.id = args.id
	this.layerBlacklist = pa(args.lbl, args.layerBlacklist, {})
	this.drawBorders = pa(args.drawBorders, false)
	this.borderColor = pa(args.borderColor, 0xFF69B4)
	this.narrowUpdateExpansion = pa(args.nue, args.narrowUpdateExpansion, global.conf.narrowUpdateExpansion)
	this.debugLog = pa(args.debugLog, true)
	
	this.parent = args.parent
	this.gameObjects = {}
	this.gameObjectAttributes = {}
	this.toRender = {}
	this.toClear = {}
	this.toUpdate = {}
	--this.cameraMoveInstructions = {copy = {}, clear = {}, raw = {x = 0, y = 0}}
	this.cameraMoveInstructions = {copy = {}, clear = {}, raw = {x = 0, y = 0}}
	this.copyInstructions = {}
	this.firstRender = true
	this.backBufferID = global.screenBufferID
	this.useOwnBackBuffer = pa(args.ownBuffer, args.ownBackBuffer, args.useOwnBuffer, args.useOwnBackBuffer, true)
	
	this.childs = {}
	
	this.isVisible = pa(args.visible, args.isVisible, true)
	
	if this.useOwnBackBuffer then
		this.backBufferID = global.gpu.allocateBuffer(this.sizeX, this.sizeY)
		
		global.gpu.setActiveBuffer(this.backBufferID)
		global.gpu.setBackground(global.backgroundColor)
		global.gpu.fill(1, 1, this.sizeX, this.sizeY, " ")
		if global.conf.useDoubleBuffering then 
			global.gpu.drawChanges() 
		end
		global.gpu.setActiveBuffer(global.screenBufferID)
	end
	
	if this.parent ~= nil then
		if this.parent.parent ~= nil then
			this.parent = this.parent.parent
		end
		
		this.gameObjects = this.parent.gameObjects
		this.parent.childs[this] = true
		for i, c in pairs(this.parent.gameObjectAttributes) do
			this.gameObjectAttributes[i] = c
		end
		
		this.narrowUpdateExpansion = this.parent.narrowUpdateExpansion
	end
	
	for i = 0, global.conf.renderLayerAmount do 
		this.toRender[i] = {}
		this.toClear[i] = {}
	end
	
	--===== default functions =====--
	this.addGO = function(this, go, args)
		local path, goClass = global.ut.seperatePath(go)
		--local gameObject = global.gameObject
		
		for s in string.gmatch(tostring(path), "[^/]+") do
			global.gameObject = global.gameObject[s]
		end
		
		if global.gameObject[goClass] == nil then
			print("[RA/" .. tostring(this.name) .. "]: Failed to add gameObject: \"" .. go .. "\" (not found).")
		else
			if this.parent ~= nil then
				return this.parent:addGO(go, args)
			else
				local id = #this.gameObjects +1
				local gameObject = nil
				
				print("[RA/" .. tostring(this.name) .. "]: Adding gameObject: \"" .. go .. "\" (#" .. tostring(id) .. ").")
				
				gameObject = global.gameObject[goClass].new(args)
				
				this.gameObjects[gameObject] = true
				
				gameObject.ngeAttributes.responsibleRenderAreas[this] = true
				this.gameObjectAttributes[gameObject] = {
					mustBeRendered = true,
					lastCalculatedFrame = 0,
					wasVisible,
					nonDrawAreas = {},
					drawAreas = {},
				}
				
				for c in pairs(this.childs) do
					gameObject.ngeAttributes.responsibleRenderAreas[c] = true
					c.gameObjectAttributes[gameObject] = {
						mustBeRendered = true,
						lastCalculatedFrame = 0,
						wasVisible,
						nonDrawAreas = {},
						drawAreas = {},
					}
				end
				
				--global.run(this.gameObjects[id].spawn)
				global.run(gameObject.ngeStart, gameObject)
				return gameObject
			end
		end
	end
	this.remGO = function(this, go, t)
		if go == nil then return false end
		
		if this.parent ~= nil then
			return this.parent:remGO(go, args)
		else
			print("[RA/" .. tostring(this.name) .. "]: Removing gameObject: \"" .. go.ngeAttributes.name .. "\" (#" .. tostring(id) .. ").")
			
			go:ngeClear(this)
			
			global.run(go.ngeStop, go)
			this.toRender[go.ngeAttributes.layer][go] = nil			
			this.gameObjectAttributes[go] = nil
			
			global.core.re.checkOverlapping(this, go, go.ngeAttributes.layer)
			for c in pairs(this.childs) do
				c.gameObjectAttributes[go] = nil
				go:ngeClear(c)
				global.core.re.checkOverlapping(c, go, go.ngeAttributes.layer)
			end
			
			this.gameObjects[go] = nil
		end
	end
	this.move = function(this, x, y)
		
	end
	this.moveTo = function(this, x, y)
		
	end
	this.moveCamera = function(this, x, y)
		local cmir = this.cameraMoveInstructions.raw
		this.cameraMoveInstructions.raw.x = cmir.x +x
		this.cameraMoveInstructions.raw.y = cmir.y -y
	end
	this.moveCameraTo = function(this, x, y)
		local cmir = this.cameraMoveInstructions.raw
		this.cameraMoveInstructions.raw.x = this.cameraPosX +x
		this.cameraMoveInstructions.raw.y = this.cameraPosY -y
	end
	
	this.rerenderAll = function(this)
		global.gpu.setBackground(global.backgroundColor)
		if this.useOwnBackBuffer then
			global.gpu.setActiveBuffer(this.backBufferID)
			global.gpu.fill(1, 1, this.sizeX, this.sizeY, " ")
		else
			global.gpu.fill(this.posX, this.posY, this.sizeX, this.sizeY, " ")
		end
		
		for i, a in pairs(this.gameObjectAttributes) do
			a.mustBeRendered = true
		end
		this.firstRender = true
	end
	this.getFOV = function(this) --ToDo: has to give prositive x and y values.
		local cmir = this.cameraMoveInstructions.raw
		return this.cameraPosX + cmir.x, this.sizeX + this.cameraPosX + cmir.x, this.cameraPosY + cmir.y, this.sizeY + this.cameraPosY + cmir.y
	end
	this.getFOVLegacy = function(this)
		return - this.cameraPosX, this.sizeX - this.cameraPosX, - this.cameraPosY, this.sizeY - this.cameraPosY
	end
	this.getLastFOV = function(this)
		return - this.lastCameraPosX, this.sizeX - this.lastCameraPosX, - this.lastCameraPosY, this.sizeY - this.lastCameraPosY
	end
	this.getRealFOV = function(this, bufferIntern)
		if bufferIntern and this.useOwnBackBuffer then
			return 1, this.sizeX, 1, this.sizeY
		else
			return this.posX, this.posX + this.sizeX, this.posY, this.posY + this.sizeY
		end
	end
	this.getPixelPos = function(this, x, y) --returns the renderArea pos from the screen pixel pos.
		return x - this.posX - this.cameraPosX, y - this.posY - this.cameraPosY
	end
	this.getGOPos = function(this, go) --returns the pos on the screen.
		return go.gameObject.posX + this.posX + this.cameraPosX, go.gameObject.posY + this.posY + this.cameraPosY
	end
	this.getPos = function(this)
		return this.posX, this.posY
	end
	this.getSize = function(this)
		return this.sizeX, this.sizeY
	end
	
	this.resetCMI = function(this)
		local cmi = this.cameraMoveInstructions
		local subPixelX = cmi.raw.x - math.floor(cmi.raw.x)
		local subPixelY = cmi.raw.y - math.floor(cmi.raw.y)
		
		this.cameraMoveInstructions = {copy = {}, clear = {}, raw = {x = subPixelX, y = subPixelY}}
		this.copyInstructions = {}
	end
	this.getBufferID = function(this)
		return this.backBufferID
	end
	this.getOffset = function(this)
		local x, _, y = this:getFOV()
		if not this.useOwnBackBuffer then
			local rx, _, ry = this:getRealFOV(true)
			x, y = x - rx +1, y - ry +1
		end
		
		return math.floor(x), math.floor(y)
		
		--[[
		if this.directDraw then
			return math.floor(this.posX + this.cameraPosX +.5), math.floor(this.posY + this.cameraPosY +.5)
		else
			return math.floor(this.cameraPosX +.5), math.floor(this.cameraPosY +.5)
		end
		]]
	end
	
	--===== engine functions =====--
	this.ngeStart = function(this) --parent func 
		
	end
	this.ngeUpdate = function(this, RenderAreas, dt) --parent func
		
	end
	
	this.ngeAddToRenderQueue = function(this, go, area, draw, clear)
		if draw then
			if this.toRender[go:getLayer()][go] == nil then
				this.toRender[go:getLayer()][go] = {}
			end
			table.insert(this.toRender[go:getLayer()][go], area)
		end
		if clear then
			if this.toClear[go:getLayer()][go] == nil then
				this.toClear[go:getLayer()][go] = {}
			end
			table.insert(this.toClear[go:getLayer()][go], area)
		end
	end
	
	this.ngeCalculateNewRender = function(this) --parent func
		if not this.isVisible then
			return false, "Not visible"
		end
		
		local rx, _, ry = this:getRealFOV(true)
		local sx, sy = this:getSize()
		local screenArea = {posX = rx, posY = ry, sizeX = sx, sizeY = sy}
		local cmi = this.cameraMoveInstructions
		local cmir = {x = math.floor(cmi.raw.x), y = math.floor(cmi.raw.y)}
		local x, tx, y, ty = this:getFOV()
		local fov = {posX = x, posY = y, sizeX = sx, sizeY = sy}
		local toRender
		
		if this.firstRender then
			toRender = this.gameObjects
		else
			toRender = global.core.re.toRender
		end
		
		if this.useOwnBackBuffer then
			screenArea = {posX = 1, posY = 1, sizeX = sx, sizeY = sy}
		end
		
		--===== calculate cam move copy instructions =====--
		if cmir.x ~= 0 or cmir.y ~= 0 then
			local fx, fy, sx, sy, tx, ty = 0, 0, 0, 0, -cmir.x, -cmir.y
			local posX, _, posY = this:getRealFOV(true)
			local newClearArea1, newClearArea2 = {0, posY, 0, this.sizeY}, {posX, 0, this.sizeX, 0}
			
			if cmir.x >= 0 then
				fx = posX +cmir.x
				sx = this.sizeX -cmir.x
				newClearArea1[1] = posX + this.sizeX - cmir.x
				newClearArea1[3] = cmir.x
			else
				fx = posX
				sx = this.sizeX +cmir.x
				newClearArea1[1] = posX
				newClearArea1[3] = -cmir.x
			end
			if cmir.y >= 0 then
				fy = posY +cmir.y
				sy = this.sizeY -cmir.y
				newClearArea2[2] = posY + this.sizeY -cmir.y
				newClearArea2[4] = cmir.y
			else
				fy = posY
				sy = this.sizeY +cmir.y
				newClearArea2[2] = posY
				newClearArea2[4] = -cmir.y
			end
			
			cmi.copy = {fx, fy, sx, sy, tx, ty}
			
			if cmir.x ~= 0 then
				cmi.clear[1] = {newClearArea1[1], newClearArea1[2], newClearArea1[3], newClearArea1[4], " "}
			end
			if cmir.y ~= 0 then
				cmi.clear[2] = {newClearArea2[1], newClearArea2[2], newClearArea2[3], newClearArea2[4], " "}
			end
		end
		this.lastCameraPosX = this.cameraPosX
		this.lastCameraPosY = this.cameraPosY
		this.cameraPosX = this.cameraPosX + cmir.x
		this.cameraPosY = this.cameraPosY + cmir.y
		cmi.raw.x = cmi.raw.x - cmir.x
		cmi.raw.y = cmi.raw.y - cmir.y
		
		--[[
		this.cameraPosX, this.cameraPosY = this.cameraPosX + this.cameraMoveInstructions.raw.x, this.cameraPosY + this.cameraMoveInstructions.raw.y
		this.cameraMoveInstructions.raw.x, this.cameraMoveInstructions.raw.y = 0, 0
		]]
		--for go, _ in pairs(this.gameObjects) do
		
		--===== calculate cam move clear instructions =====--
		if cmi.clear[1] ~= nil or cmi.clear[2] ~= nil then
			for go, _ in pairs(this.gameObjects) do
				local x, _, y = this:getFOV()
				local rx, _, ry = this:getRealFOV(true)
				
				if toRender[go] ~= true and 
					cmi.clear[1] ~= nil and 
					go:ngeIsInsideRenderArea({posX = cmi.clear[1][1] + x - rx, posY = cmi.clear[1][2] + y - ry, sizeX = cmi.clear[1][3], sizeY = cmi.clear[1][4]}) or
					cmi.clear[2] ~= nil and 
					go:ngeIsInsideRenderArea({posX = cmi.clear[2][1] + x - rx, posY = cmi.clear[2][2] + y - ry, sizeX = cmi.clear[2][3], sizeY = cmi.clear[2][4]})
				then	
					--this.toRender[go:getLayer()][go] = {posX = cmi.clear[1][1], posY = cmi.clear[1][2], sizeX = cmi.clear[1][3], sizeY = cmi.clear[1][4]} --maybe usefull?
					
					this:ngeAddToRenderQueue(go, screenArea, true, false)
				end
			end
		end
		
		
		
		local function checkOverlapping()
			
		end
		
		
		--===== calculate gameObject render areas =====--
		for go, _ in pairs(toRender) do
			if go:ngeIsInsideRenderArea(fov) then
				
				if this.name == "RA2" then --debug
					this:ngeAddToRenderQueue(go, screenArea, true, true)
				end
				
				this:ngeAddToRenderQueue(go, screenArea, true, true)
				--this:ngeAddToRenderQueue(go, {posX = 3, posY = 3, sizeX = 3, sizeY = 3}, true, true)
			end
		end
		--this:ngeAddToRenderQueue(global.state.reTest.goBigRETest, {posX = 3, posY = 3, sizeX = 3, sizeY = 3}, true, true)
	end
	
	this.ngeClear = function(this) --parent func
		if not this.isVisible then
			return false, "Not visible"
		end
		
		global.gpu.setActiveBuffer(this:getBufferID())
		
		
		if this.name == "RA1" then --debug
			global.gpu.setBackground(0x005500)
			global.gpu.fill(1, 1, this.sizeX, this.sizeY, " ")
		
		end
		
		
		--===== execute cam move =====--
		if #this.cameraMoveInstructions.copy > 0 then
			local cmi = this.cameraMoveInstructions
			global.gpu.copy(cmi.copy[1], cmi.copy[2], cmi.copy[3], cmi.copy[4], cmi.copy[5], cmi.copy[6])
			
			global.oclrl:draw(0, 0, global.oclrl.generateTexture({
				{"b", global.backgroundColor},
				cmi.clear[1],
				cmi.clear[2],
			})--[[, nil, {renderArea.posX, renderArea.posX + renderArea.sizeX -1, renderArea.posY, renderArea.posY + renderArea.sizeY -1}]])
			
		end
		
		this:resetCMI()
		
		--===== execute GameObject clear instructions =====--
		--global.gpu.setBackground(global.backgroundColor)
		global.gpu.setBackground(0x0)
		
		for l, gos in pairs(this.toClear) do
			for go, areas in pairs(gos) do
				local x, y = this:getOffset()
				
				print("[RA]: " .. tostring(this.name) .. ": Clear: " .. tostring(go.ngeAttributes.name) .. ": " .. tostring(go) .. ", frame: " .. tostring(global.currentFrame) .. ".")
				
				go:ngeClear(areas, x -1, y -1)
			end
		end
	end
	
	this.ngeDraw = function(this) --parent func
		if not this.isVisible then
			return false, "Not visible"
		end
		
		for l, gos in pairs(this.toRender) do
			for go, areas in pairs(gos) do
				local x, y = this:getOffset()
				
				print("[RA]: " .. tostring(this.name) .. ": Draw: " .. tostring(go.ngeAttributes.name) .. ": " .. tostring(go) .. ", frame: " .. tostring(global.currentFrame) .. ".")
				
				go:ngeDraw(this, areas, x -1, y -1)
			end
		end
		
		if this.drawBorders then
			global.gpu.setActiveBuffer(global.screenBufferID)
			global.gpu.setBackground(this.borderColor)
			global.gpu.set(this.posX, this.posY -1, global.ut.fillString("", this.sizeX, " "))
			global.gpu.set(this.posX, this.posY + (this.sizeY), global.ut.fillString("", this.sizeX, " "))
			global.gpu.set(this.posX -1, this.posY, global.ut.fillString("", this.sizeY, " "), true)
			global.gpu.set(this.posX + (this.sizeX), this.posY, global.ut.fillString("", this.sizeY, " "), true)
			global.gpu.setActiveBuffer(this.backBufferID)
		end
		
		if this:getBufferID() ~= global.screenBufferID then
			local posX, posY = this:getPos()
			
			if global.conf.useDoubleBuffering then 
				global.gpu.drawChanges()
			end
			
			global.gpu.bitblt(global.screenBufferID, posX, posY, this.sizeX, this.sizeY, this:getBufferID())
		end
		
		this.firstRender = false
	end
	this.ngeClearRenderQueue = function(this)
		if not this.isVisible then
			return false, "Not visible"
		end
		
		for l in pairs(this.toRender) do
			this.toRender[l] = {}
			this.toClear[l] = {}
		end
	end
	
	return this
end

return RenderArea