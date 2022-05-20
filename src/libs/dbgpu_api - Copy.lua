--[[
	!The api is not complete yet!
	
	This is a little api to make the DoubleBuffering libarry by IgorTimofeev acting like a normal OC gpu.
	
	With the default settings it is acting (nearly) exacly like a normal OC gpu (so its basicly useless).
	To get the full effect of the DoubleBuffering you should deactivate directDraw but then you manually need to use the drawChanges function.
	
	DoubleBuffering source: <https://github.com/IgorTimofeev/DoubleBuffering>
	DoubleBuffering Copyright (c) 2018 Igor Timofeev
	
	dbgpu_api Copyright (c) 2019 NosPo Studio
	
    dbgpu_api is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    dbgpu_api is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with dbgpu_api.  If not, see <https://www.gnu.org/licenses/>.	
]]

local version = "v0.2d"

local args = ...
local path = args.path or ""

local buffer = require(path .. "/DoubleBuffering")
local gpu = require("component").gpu
local unicode = require("unicode")

local ut = require("libs/UT")

local lastBackground = gpu.getBackground()
local lastForeground = gpu.getForeground()

local currentVBuffer = gpu.getActiveBuffer()
local cpuBuffers = {}

local function flushBuffer(id, w, h)
	cpuBuffers[id] = {
		drawLimit = {1, 1, w, h},
		current = {{}, {}, {}, w, h},
		new = {{}, {}, {}, w, h},
	}
	
	for y = 1, h do
		for x = 1, w do
			table.insert(cpuBuffers[id].current[1], 0x010101)
			table.insert(cpuBuffers[id].current[2], 0xFEFEFE)
			table.insert(cpuBuffers[id].current[3], " ")
	
			table.insert(cpuBuffers[id].new[1], 0x010101)
			table.insert(cpuBuffers[id].new[2], 0xFEFEFE)
			table.insert(cpuBuffers[id].new[3], " ")
		end
	end
end
local function setBuffer(id)
	cpuBuffers[currentVBuffer].drawLimit = {buffer.getDrawLimit()}
	
	buffer.setCurrentFrameTables(cpuBuffers[id].current[1], cpuBuffers[id].current[2], cpuBuffers[id].current[3], cpuBuffers[id].current[4], cpuBuffers[id].current[5])
	buffer.setNewFrameTables(cpuBuffers[id].new[1], cpuBuffers[id].new[2], cpuBuffers[id].new[3], cpuBuffers[id].new[4], cpuBuffers[id].new[5])
	buffer.setDrawLimit(cpuBuffers[id].drawLimit[1], cpuBuffers[id].drawLimit[2], cpuBuffers[id].drawLimit[3], cpuBuffers[id].drawLimit[4])
	
	currentVBuffer = id
end

local function parseArgs(...) --ripped from UT_v0.6
	for _, a in pairs({...}) do
		if a ~= nil then
			return a
		end
	end
end

local function getSubFunc(s)
	if #s ~= unicode.len(s) then
		return unicode.sub
	else
		return string.sub
	end
end

local dbgpu = {
	directDraw = parseArgs(args.directDraw, true),
	forceDraw = parseArgs(args.forceDraw, false),
	rawCopy = parseArgs(args.rawCopy, false),
	actualRawCopy = parseArgs(args.actualRawCopy, args.rawCopy),
	version = version,
	buffer = buffer,
}

local function draw()
	if dbgpu.directDraw then
		buffer.drawChanges(dbgpu.forceDraw)
	end
end

function dbgpu.set(x, y, s, v)
	s = tostring(s)
	local sub = getSubFunc(s)
	x = math.floor(x)
	y = math.floor(y)
	if v then
		for i = 1, unicode.len(s) do
			buffer.set(x, y +i -1, lastBackground, lastForeground, sub(s, i, i))
		end
	else
		for i = 1, unicode.len(s) do
			buffer.set(x +i -1, y, lastBackground, lastForeground, sub(s, i, i))
		end
	end
	draw()
end

function dbgpu.fill(x, y, sx, sy, s)
	s = tostring(s)
	local sub = getSubFunc(s)
	x = math.floor(x)
	y = math.floor(y)
	sx = math.floor(sx)
	sy = math.floor(sy)
	s = sub(s, 0, 1)
	buffer.drawRectangle(x, y, sx, sy, lastBackground, lastForeground, s)
	draw()
end

function dbgpu.copy(x, y, sx, sy, tx, ty)
	x = math.floor(x)
	y = math.floor(y)
	tx = math.floor(tx)
	ty = math.floor(ty)
	
	if sx * sy > 3200 then
		buffer.directCopy(x, y, sx, sy, tx +x, ty +y, dbgpu.rawCopy)
	else
		local data, rawData = buffer.copy(x, y, sx, sy, dbgpu.rawCopy)
		buffer.paste(tx +x, ty +y, data, rawData)
	end
	
	if dbgpu.rawCopy and dbgpu.actualRawCopy then		
		gpu.copy(x, y, sx, sy, tx, ty)
	end	
	draw()
end

function dbgpu.getBackground()
	return lastBackground
end
function dbgpu.getForeground()
	return lastForeground
end

function dbgpu.setBackground(c)
	lastBackground = c
	--return gpu.setBackground(c)
end
function dbgpu.setForeground(c)
	lastForeground = c
	--return gpu.setForeground(c)
end

function dbgpu.setResolution(x, y)
	buffer.setResolution(x, y)
end
function dbgpu.getResolution()
	return buffer.getResolution()
end

function dbgpu.drawChanges(f)
	buffer.drawChanges(f)
end

function dbgpu.drawImage(x, y, image)
	buffer.drawImage(x, y, image)
end

function dbgpu.getActiveBuffer()
	return currentVBuffer
end
function dbgpu.setActiveBuffer(id, force)
	if id == currentVBuffer or force then
		return false, "Buffer is set already"
	else
		local suc = gpu.setActiveBuffer(id)
		
		if suc ~= nil then
			
			setBuffer(id)
			
			do
				local b = buffer.getNewFrameTables()
				local b2 = cpuBuffers[id].new[1]
				
				--print(b, b2, b == b2)
			end
			
			--print("T", id)
			--print(cpuBuffers[0], cpuBuffers[1])
			--print(#cpuBuffers[0].new[1], #cpuBuffers[1].new[1], cpuBuffers[id].new[4], cpuBuffers[id].new[5])
		end
		return id
	end
end
--debug/dbgpuVBufferTest.lua > logs/test.log
function dbgpu.allocateBuffer(w, h)
	local id = gpu.allocateBuffer(w, h)
	if type(id) == "number" then
		flushBuffer(id, w, h)
	end
	return id
end
function dbgpu.freeBuffer(id)
	cpuBuffers[id] = nil
	return gpu.freeBuffer(id)
end
function dbgpu.bitblt(...)
	return gpu.bitblt(...)
end
function dbgpu.freeAllBuffers()
	currentVBuffer = 0
	return gpu.freeAllBuffers()
end

--===== init =====--
local resX, resY = gpu.getResolution()
flushBuffer(0, resX, resY)
setBuffer(0)


return dbgpu