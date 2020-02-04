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

local version = "v0.1d"

local args = ...
local path = args.path or ""

local buffer = require(path .. "/DoubleBuffering")
local gpu = require("component").gpu

local lastBackground = gpu.getBackground()
local lastForeground = gpu.getForeground()

local function parseArgs(...) --ripped from UT_v0.6
	for _, a in pairs({...}) do
		if a ~= nil then
			return a
		end
	end
end

local dbgpu = {
	directDraw = parseArgs(args.directDraw, true),
	forceDraw = parseArgs(args.forceDraw, false),
	rawCopy = parseArgs(args.rawCopy, false)
}

local function draw()
	if dbgpu.directDraw then
		buffer.drawChanges(dbgpu.forceDraw)
	end
end

function dbgpu.set(x, y, s, v)
	x = math.floor(x)
	y = math.floor(y)
	if v then
		for i = 1, #s do
			buffer.set(x, y +i -1, lastBackground, lastForeground, string.sub(s, i, i))
		end
	else
		for i = 1, #s do
			buffer.set(x +i -1, y, lastBackground, lastForeground, string.sub(s, i, i))
		end
	end
	draw()
end

function dbgpu.fill(x, y, sx, sy, s)
	x = math.floor(x)
	y = math.floor(y)
	sx = math.floor(sx)
	sy = math.floor(sy)
	s = string.sub(s, 0, 1)
	buffer.drawRectangle(x, y, sx, sy, lastBackground, lastForeground, s)
	draw()
end

function dbgpu.copy(x, y, sx, sy, tx, ty)
	x = math.floor(x)
	y = math.floor(y)
	tx = math.floor(tx)
	ty = math.floor(ty)
	local data, rawData = buffer.copy(x, y, sx, sy, dbgpu.rawCopy)
	buffer.paste(tx +x, ty +y, data, rawData)
	
	if dbgpu.rawCopy then		
		gpu.copy(x, y, sx, sy, tx, ty)
	else
		draw()
	end
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


return dbgpu