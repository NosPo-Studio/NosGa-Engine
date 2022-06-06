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

--GameEngine
local global = ...
local uh = {
	isUpdated = {},
	signalQueue = {},
	sUpdateQueue = {},
	ocgfUpdateQueue = {},
	newOcgfUpdateQueue = {},
}

--===== local vars =====--
local narrowUpdateExpansion = global.conf.narrowUpdateExpansion
local tableInsert = table.insert
local calcSUpdate = global.conf.calcSUpdate

--===== local functions =====--
local function print(...)
	if global.conf.debug.geDebug then
		global.debug.log(...)
	end
end

local function isInsideArea(ra, go, expansion)
	local x, y = go:getPos()
	local sx, sy = go.ngeAttributes.sizeX, go.ngeAttributes.sizeY
	local fromX, toX, fromY, toY = ra:getFOV()
	local expansion = expansion or {0, 0, 0, 0}
	
	if x +sx > fromX -expansion[1] and x < toX +expansion[2] and y +sy > fromY -expansion[3] and y < toY +expansion[4] then
		return true
	end
	
	return false
end

local function updateGameObjec(renderArea, go, ocgfUpdateQueue, dt)
	local isUpdated = uh.isUpdated

	if type(go) == "number" then
		go = c
		global.fatal("Update handler has unexpectet toUpdate table.") --currently not relevant.
	end

	if not isUpdated[go] then
		for i, s in pairs(uh.signalQueue) do
			global.run(go[s.name], go, s.signal, s.name)
		end
		
		go:ngeUpdate(ocgfUpdateQueue, dt, renderArea)
		if calcSUpdate then
			tableInsert(uh.sUpdateQueue, {go, renderArea})
		end
		isUpdated[go] = true

		return go.gameObject
	end
end

local function checkLoadingStatus(go, updated)
	--global.log(updated, go.ngeAttributes.isLoaded)
	if not updated and go.ngeAttributes.isLoaded then
		global.run(go.ngeUnload, go)
	elseif updated and not go.ngeAttributes.isLoaded then
		global.run(go.ngeLoad, go)
	end
end

local function updateFrame(renderArea, dt)
	local ocgfUpdateQueue = uh.ocgfUpdateQueue
	local newOcgfUpdateQueue = uh.newOcgfUpdateQueue
	local ocgfGameObject = nil
	local expansion = renderArea.narrowUpdateExpansion
	local isUpdated = uh.isUpdated

	if narrowUpdateExpansion ~= false and not renderArea.updateAnything then
		for go in pairs(renderArea.gameObjects) do
			local l = go.ngeAttributes.layer
			
			if 
				renderArea.layerBlacklist[l] ~= true and 
				isInsideArea(renderArea, go, narrowUpdateExpansion) and 
				isUpdated[go] ~= true or
				go.ngeAttributes.updateAlways
			then 
				ocgfGameObject = updateGameObjec(renderArea, go, ocgfUpdateQueue, dt)
				checkLoadingStatus(go, true)
				if not go.ngeAttributes.ignoreOCGFGameObject then
					tableInsert(newOcgfUpdateQueue, ocgfGameObject)
				end
			else
				checkLoadingStatus(go, false)
			end
		end
	else
		for go in pairs(renderArea.gameObjects) do
			ocgfGameObject = updateGameObjec(renderArea, go, ocgfUpdateQueue, dt)
			checkLoadingStatus(go, true)
			if not go.ngeAttributes.ignoreOCGFGameObject then
				tableInsert(newOcgfUpdateQueue, ocgfGameObject)
			end
		end
	end

	renderArea.toUpdate = {}
end

--===== global functions =====--
function uh.init()
	
end

function uh.update(dt)
	dt = dt or global.dt
	
	for ra in pairs(global.renderAreas) do
		if not ra.silent then
			updateFrame(ra, dt)
		end
	end
	
	uh.isUpdated = {}
	uh.signalQueue = {}
	uh.ocgfUpdateQueue = uh.newOcgfUpdateQueue
	uh.newOcgfUpdateQueue = {}
end

function uh.sUpdate(dt)
	dt = dt or global.dt
	
	for i, suq in pairs(uh.sUpdateQueue) do
		suq[1]:ngeSUpdate(suq[2].gameObjects, dt, suq[2])
	end
	uh.sUpdateQueue = {}
end

function uh.insertSignal(s, signalName)
	
	--[[
	local t = s
	
	if signalName ~= nil then
		t = {signalName}
		for i, c in pairs(s) do
			if i > 1 then
				t[i] = c
			end
		end
		
		--uh.signalQueue[#uh.signalQueue][1] = signalName
	end
	]]
	--print(signalName)
	tableInsert(uh.signalQueue, {name = signalName, signal = s})
	
	--global.log(global.currentFrame, signalName)
	--global.slog(uh.signalQueue)
	
end

--===== init =====--
if not calcSUpdate then
	uh.sUpdate = function() end
end

return uh