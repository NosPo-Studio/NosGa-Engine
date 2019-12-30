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

--GameEngine
local global = ...
local uh = {
	isUpdated = {},
	signalQueue = {},
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	if global.conf.debug.geDebug then
		global.debug(...)
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

local function calculateFrame(renderArea)
	local expansion = renderArea.narrowUpdateExpansion
	
	if global.conf.narrowUpdateExpansion ~= false then
		renderArea.updateAnything = false
		local fromX, toX, fromY, toY = renderArea:getFOV()
		
		for i, go in pairs(renderArea.gameObjects) do
			local l = go.ngeAttributes.layer
			
			if renderArea.layerBlacklist[l] ~= true and 
				isInsideArea(renderArea, go, global.conf.narrowUpdateExpansion) and 
				renderArea.toUpdate[go] == nil 
			then 
				renderArea.toUpdate[go] = true
			end
		end
	else
		renderArea.updateAnything = true
	end
end

local function updateFrame(renderArea, dt)
	local toUpdate = renderArea.toUpdate
	
	if renderArea.updateAnything then
		toUpdate = renderArea.gameObjects
	end
	
	for go in pairs(toUpdate) do
		if not uh.isUpdated[go] then
			for i, s in pairs(uh.signalQueue) do
				--print(s[1], go[s[1]], global.currentFrame)
				
				global.run(go[s.name], s.signal, s.name)
			end
			
			go:ngeUpdate(global.gameObjects, dt, renderArea)
			uh.isUpdated[go] = true
		end
	end
	
	renderArea.toUpdate = {}
end

--===== global functions =====--
function uh.init()
	
end

function uh.update(dt)
	dt = dt or global.dt
	
	for i, ra in pairs(global.renderAreas) do
		if not ra.silent then
			calculateFrame(ra)
			updateFrame(ra, dt)
		end
	end
	
	uh.isUpdated = {}
	uh.signalQueue = {}
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
	table.insert(uh.signalQueue, {name = signalName, signal = s})
	
	--global.log(global.currentFrame, signalName)
	--global.slog(uh.signalQueue)
	
end

--===== init =====--

return uh