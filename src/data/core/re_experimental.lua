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
local re = {
	toRender = {}
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	if global.conf.debug.reDebug then
		global.debug.log(...)
	end
end

local function bufferTexture(t, resetBuffer)
	local texture = t
	local textureBufferID
	local currentBufferID = global.gpu.getActiveBuffer()
	resetBuffer = global.ut.parseArgs(resetBuffer, true)
	
	if type(t) == "string" then
		texture = global.texture[t]
	end
	
	if texture.id ~= nil then
		print("[RE]: [BT]: Texture: " .. tostring(t) .. " is buffered already.")
		return false, "Texture is buffered already"
	end
	
	if texture.format == "pic" then
		--[[
		textureBufferID = global.gpu.allocateBuffer(texture.resX, texture.resY)
		
		global.gpu.setActiveBuffer(textureBufferID)
		global.db.drawImage(1, 1, texture)
		global.db.drawChanges()
		]]
		
		local cfb, cff, cfs, bw, bh = global.db.getCurrentFrameTables()
		local nfb, nff, nfs = global.db.getNewFrameTables()
		textureBufferID = global.gpu.allocateBuffer(texture.resX, texture.resY)
		
		global.gpu.setActiveBuffer(textureBufferID)
		global.db.flush(texture.resX, texture.resY)
		global.db.drawImage(1, 1, texture)
		global.db.drawChanges()
		
		global.db.flush(bw, bh)
		global.db.setCurrentFrameTables(cfb, cff, cfs, bw, bh)
		global.db.setNewFrameTables(nfb, nff, nfs, bw, bh)
		
	elseif texture.format == "OCGLT" then
		local oclrlInternGPU = global.oclrl.gpu
		textureBufferID = global.gpu.allocateBuffer(texture.resX, texture.resY)
		
		global.gpu.setActiveBuffer(textureBufferID)
		global.oclrl.gpu = global.realGPU
		
		global.oclrl:draw(1, 1, texture)
		
		global.oclrl.gpu = oclrlInternGPU
	else
		global.warn("[RE]: [BT]: Invalid format, texture: " .. tostring(t) .. ": " .. tostring(texture.format))
		return false, "Ivalid format", texture.format
	end
	
	texture.bufferID = textureBufferID
	
	print("[RE]: [BT]: Texture: " .. tostring(t) .. " loaded into buffer: " .. tostring(textureBufferID))
	
	if resetBuffer then
		global.gpu.setActiveBuffer(currentBufferID)
	end
	
	return textureBufferID
end

--===== global functions =====--
function re.init()
	print("[RE]: [INIT]: bufferTexturesOnInit: " .. tostring(global.conf.bufferTexturesOnInit) .. ", useBufferWhitelist: " .. tostring(global.texturePack.useBufferWhitelist))
	
	if global.conf.useDoubleBuffering and false then
		global.gpu.freeAllBuffers()
		
		global.gpu = loadfile("libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true, actualRawCopy = true, global = global})
		--[[
		global.gpu = global.realGPU
		global.gpu.drawChanges = function() end
		]]
		--global.oclrl.gpu = global.gpu
		global.oclrl.gpu = global.realGPU
		
		
	end
	
	global.gpu.freeAllBuffers()
	
	--global.db = nil
	--global.db = dofile("libs/thirdParty/DoubleBuffering.lua")
	
	--print(xpcall(global.db.setCurrentFrameTables, debug.traceback, {}, {}, {}))
	
	--debug.traceback()
	
	
	if global.conf.bufferTexturesOnInit then
		print("[RE]: [INIT]: Buffer textures")
		
		if global.texturePack.useBufferWhitelist then
		
		else
			for i, c in pairs(global.texture) do
				if global.texturePack.bufferBlacklist[i] == nil then
					bufferTexture(i)
				end	
			end
		end
	end
	--gpu.bitblt(0, 1, 1, nil, nil, 6)
	--os.sleep(1)
	
	--global.oclrl = nil
end

function re.draw()
	print("[RE]: New frame: " .. tostring(global.currentFrame))
	
	for ra, _ in pairs(global.renderAreas) do
		if global.renderAreas[ra] then
			ra:ngeCalculateNewRender()
			ra:ngeClear()
			ra:ngeDraw()
			ra:ngeClearRenderQueue()
			
			--global.realGPU.fill(1, 1, 100, 100, " ")
		end
	end
	
	global.gpu.setActiveBuffer(global.screenBufferID)
	
	if global.conf.useDoubleBuffering then
		--global.core.re.executeCopyOrders()
		--global.gpu.drawChanges()
	end
	
	re.toRender = {}
end

function re.newDraw()
	
end

function re.test()
	
end


--===== init =====--


return re