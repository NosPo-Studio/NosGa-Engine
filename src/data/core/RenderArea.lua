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
	this.posX = pa(args.x, args.posX)
	this.posY = pa(args.y, args.posY)
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
	
	this.parent = args.parent
	this.gameObjects = {}
	this.gameObjectAttributes = {}
	this.toRender = {}
	this.toClear = {}
	this.toUpdate = {}
	--this.cameraMoveInstructions = {copy = {}, clear = {}, raw = {x = 0, y = 0}}
	this.cameraMoveInstructions = {copy = {}, clear = {}, raw = {x = 0, y = 0}}
	this.copyInstructions = {}

	this.sizeArray = {this.posX, this.posX + this.sizeX -1, this.posY, this.posY + this.sizeY -1}
	
	this.childs = {}
	
	this.visible = true
	
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
					overlappingAreas = {},
					hasBeenRenderedOnce = false,
				}
				
				for c in pairs(this.childs) do
					gameObject.ngeAttributes.responsibleRenderAreas[c] = true
					c.gameObjectAttributes[gameObject] = {
						mustBeRendered = true,
						lastCalculatedFrame = 0,
						wasVisible,
						overlappingAreas = {},
						hasBeenRenderedOnce = false,
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
			
			global.run(go.ngeStop, go)
			this.toRender[go.ngeAttributes.layer][go] = nil			
			this.gameObjectAttributes[go] = nil
			
			go:ngeClear(this)
			global.core.re.checkOverlapping(this, go, go.ngeAttributes.layer)
			for c in pairs(this.childs) do
				c.gameObjectAttributes[go] = nil
				go:ngeClear(c)
				global.core.re.checkOverlapping(c, go, go.ngeAttributes.layer)
			end
			
			this.gameObjects[go] = nil
		end
	end
	this.remAll = function(this)
		for go in pairs(this.gameObjects) do
			this:remGO(go)
		end
	end
	this.move = function(this, x, y)
		
	end
	this.moveTo = function(this, x, y)
		
	end
	this.moveCamera = function(this, x, y)
		local cmir = this.cameraMoveInstructions.raw
		cmir.x = cmir.x +x
		cmir.y = cmir.y -y
	end
	this.moveCameraTo = function(this, x, y)
		local cmir = this.cameraMoveInstructions.raw
		cmir.x = this.cameraPosX +x
		cmir.y = this.cameraPosY -y
	end
	
	this.rerenderAll = function(this)
		global.gpu.setBackground(global.backgroundColor)
		global.gpu.fill(this.posX, this.posY, this.sizeX, this.sizeY, " ")
		
		for i, a in pairs(this.gameObjectAttributes) do
			a.mustBeRendered = true
			a.hasBeenRenderedOnce = false
		end
	end
	this.getFOV = function(this)
		local cmir = this.cameraMoveInstructions.raw
		return - this.cameraPosX + cmir.x, this.sizeX - this.cameraPosX + cmir.x, - this.cameraPosY + cmir.y, this.sizeY - this.cameraPosY + cmir.y
	end
	this.getFOVLegacy = function(this)
		return - this.cameraPosX, this.sizeX - this.cameraPosX, - this.cameraPosY, this.sizeY - this.cameraPosY
	end
	this.getLastFOV = function(this)
		return - this.lastCameraPosX, this.sizeX - this.lastCameraPosX, - this.lastCameraPosY, this.sizeY - this.lastCameraPosY
	end
	this.getRealFOV = function(this)
		return this.posX, this.posX + this.sizeX, this.posY, this.posY + this.sizeY
	end
	this.getPixelPos = function(this, x, y) --returns the renderArea pos from the screen pixel pos.
		return x - this.posX - this.cameraPosX, y - this.posY - this.cameraPosY
	end
	this.getGOPos = function(this, go) --returns the pos on the screen.
		return go.gameObject.posX + this.posX + this.cameraPosX, go.gameObject.posY + this.posY + this.cameraPosY
	end
	
	this.resetCMI = function(this)
		local cmi = this.cameraMoveInstructions
		local subPixelX = cmi.raw.x - math.floor(cmi.raw.x)
		local subPixelY = cmi.raw.y - math.floor(cmi.raw.y)
		
		this.cameraMoveInstructions = {copy = {}, clear = {}, raw = {x = subPixelX, y = subPixelY}}
		this.copyInstructions = {}
	end
	
	--===== engine functions =====--
	this.ngeStart = function(this) --parent func 
		
	end
	this.ngeUpdate = function(this, RenderAreas, dt) --parent func
		
	end
	this.ngeCalculateNewRender = function(this) --parent func
		local cmi = this.cameraMoveInstructions
		local subPixelX = cmi.raw.x - math.floor(cmi.raw.x)
		local subPixelY = cmi.raw.y - math.floor(cmi.raw.y)
		cmi.raw.x = math.floor(cmi.raw.x)
		cmi.raw.y = math.floor(cmi.raw.y)
		
		if global.conf.useSmartCameraMove then
			--===== camera move calculation =====--
			if cmi.raw.x ~= 0 or cmi.raw.y ~= 0 then
				local fromX, toX, fromY, toY = this:getFOV()
				local fx, fy, sx, sy, tx, ty = 0, 0, 0, 0, -cmi.raw.x, -cmi.raw.y
				local newClearArea1, newClearArea2 = {0, this.posY, 0, this.sizeY}, {this.posX, 0, this.sizeX, 0}
				
				if cmi.raw.x >= 0 then
					fx = this.posX +cmi.raw.x
					sx = this.sizeX -cmi.raw.x
					newClearArea1[1] = this.posX + this.sizeX -cmi.raw.x
					newClearArea1[3] = cmi.raw.x
				else
					fx = this.posX
					sx = this.sizeX +cmi.raw.x
					newClearArea1[1] = this.posX
					newClearArea1[3] = -cmi.raw.x
				end
				if cmi.raw.y >= 0 then
					fy = this.posY +cmi.raw.y
					sy = this.sizeY -cmi.raw.y
					newClearArea2[2] = this.posY + this.sizeY -cmi.raw.y
					newClearArea2[4] = cmi.raw.y
				else
					fy = this.posY
					sy = this.sizeY +cmi.raw.y
					newClearArea2[2] = this.posY
					newClearArea2[4] = -cmi.raw.y
				end
				
				cmi.copy = {fx, fy, sx, sy, tx, ty}
				
				if cmi.raw.x ~= 0 then
					cmi.clear[1] = {newClearArea1[1], newClearArea1[2], newClearArea1[3], newClearArea1[4], " "}
				end
				if cmi.raw.y ~= 0 then
					cmi.clear[2] = {newClearArea2[1], newClearArea2[2], newClearArea2[3], newClearArea2[4], " "}
				end
				
				this.lastCameraPosX = this.cameraPosX
				this.lastCameraPosY = this.cameraPosY
				this.cameraPosX = this.cameraPosX + (-cmi.raw.x)
				this.cameraPosY = this.cameraPosY + (-cmi.raw.y)
			end
			
			--===== new frame calculation =====--
			if #cmi.copy > 0 then
				local fromX, toX, fromY, toY = this:getFOV()
				local function addToDraw(go)
					if this.gameObjectAttributes[go].causedByOverlap then
						--this.gameObjectAttributes[go].needsFullRender = true
						--return
					end
					
					this.toRender[go.ngeAttributes.layer][go] = {}
					this.toRender[go.ngeAttributes.layer][go].realArea = this
					
					local function add(i)
						if cmi.clear[i] ~= nil then
							table.insert(this.toRender[go.ngeAttributes.layer][go], {
								posX = cmi.clear[i][1],
								posY = cmi.clear[i][2],
								sizeX = cmi.clear[i][3],
								sizeY = cmi.clear[i][4],
								getFOV = function()
									local fromX, toX, fromY, toY = this:getFOV()
									
									if i == 1 and cmi.copy[5] < 0 then
										fromX = fromX + this.sizeX - cmi.clear[i][3]
									elseif i == 1 and cmi.copy[5] > 0 then
										toX = fromX + cmi.clear[i][3]
									elseif i == 2 and cmi.copy[6] < 0 then
										fromY = fromY + this.sizeY - cmi.clear[i][4]
									elseif i == 2 and cmi.copy[6] > 0 then
										toY = fromY + cmi.clear[i][4]
									end
									
									return fromX, toX, fromY, toY
								end,
							})
						end
					end
					
					if cmi.clear[1] ~= nil then
						add(1)
					end
					if cmi.clear[2] ~= nil then
						add(2)
					end
				end
				local function isInsideArea(ra, go, i, leg)
					local x, y = go:getPos()
					local sx, sy = go.ngeAttributes.sizeX, go.ngeAttributes.sizeY
					--local fromX, toX, fromY, toY = ra:getFOV()
					
					local fromX, toX, fromY, toY = this:getFOVLegacy()
					if i == 1 and cmi.copy[5] < 0 then
						fromX = fromX + this.sizeX - cmi.clear[i][3]
					elseif i == 1 and cmi.copy[5] > 0 then
						toX = fromX + cmi.clear[i][3]
					elseif i == 2 and cmi.copy[6] < 0 then
						fromY = fromY + this.sizeY - cmi.clear[i][4]
					elseif i == 2 and cmi.copy[6] > 0 then
						toY = fromY + cmi.clear[i][4]
					end
					
					local function check(fromX, toX, fromY, toY)
						if x +sx > fromX and x < toX and y +sy > fromY and y < toY then
							return true
						end
					end
					
					return check(fromX, toX, fromY, toY)
				end
				
				for go in pairs(this.gameObjects) do
					if go.ngeAttributes.isVisibleIn[this] then
						if cmi.clear[1] ~= nil and isInsideArea(this, go, 1) or cmi.clear[2] ~= nil and isInsideArea(this, go, 2) then
							addToDraw(go)
						end
					end
				end
			end
			
			cmi.raw.x = subPixelX
			cmi.raw.y = subPixelY
		elseif cmi.raw.x ~= 0 or cmi.raw.y ~= 0 then
			this.lastCameraPosX = this.cameraPosX
			this.lastCameraPosY = this.cameraPosY
			this.cameraPosX = this.cameraPosX + (-cmi.raw.x)
			this.cameraPosY = this.cameraPosY + (-cmi.raw.y)
			this:rerenderAll()
		end
	end
	this.ngeDraw = function(this) --parent func
		if this.drawBorders then
			--[[
			global.gpu.setBackground(this.borderColor)
			global.gpu.set(this.posX, this.posY -1, global.ut.fillString("", this.sizeX -(this.sizeX/2) , " "))
			global.gpu.set(this.posX, this.posY + (this.sizeY), global.ut.fillString("", this.sizeX-(this.sizeX/2), " "))
			global.gpu.set(this.posX -1, this.posY, global.ut.fillString("", this.sizeY-(this.sizeY/2), " "), true)
			global.gpu.set(this.posX + (this.sizeX), this.posY, global.ut.fillString("", this.sizeY-(this.sizeY/2), " "), true)
			]]
			
			global.gpu.setBackground(this.borderColor)
			global.gpu.set(this.posX, this.posY -1, global.ut.fillString("", this.sizeX, " "))
			global.gpu.set(this.posX, this.posY + (this.sizeY), global.ut.fillString("", this.sizeX, " "))
			global.gpu.set(this.posX -1, this.posY, global.ut.fillString("", this.sizeY, " "), true)
			global.gpu.set(this.posX + (this.sizeX), this.posY, global.ut.fillString("", this.sizeY, " "), true)
			
		end
	end
	this.ngeClear = function(this) --parent func
		
	end
	
	return this
end

return RenderArea