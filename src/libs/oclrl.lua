--[[
	OCLRL (OpenComputersLinearRenderLibarry) is a small libarry for linear rendering of textures.
	
    oclrl Copyright (C) 2019-2020 MisterNoNameLP.
	
    This library is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this library.  If not, see <https://www.gnu.org/licenses/>.
]]

--[[ToDo:
	
	Bugs:
		Animation clear not working.

]]
local oclrl = {version = "v1.4.3d"} --! Not compatible to <= v1.4.3 !
oclrl.__index = oclrl


--===== local vars =====--
local tmpTexture = {
	textureFormat = "OCGLT",
	version = "v0.2",
	drawCalls = {},
}
local computer = require("computer")

--===== local functions =====--
local function addFrameTime(this, dt, backwards)
	this.lastFrame = this.currentFrame
	this.currentFrame = (this.currentFrame + (dt * this.speed))
end

local function parseArgs(...) --ripped from UT_v0.6
	for _, a in pairs({...}) do
		if a ~= nil then
			return a
		end
	end
end

local function parseLink(this, posX, posY, v, func, ...)
	if #v == 1 then
		tmpTexture.drawCalls = v[1]
		func(this, posX, posY, tmpTexture, ...)
	else
		tmpTexture.drawCalls = v[3]
		func(this, posX + v[1], posY + v[2], tmpTexture, ...)
	end
	tmpTexture.drawCalls = {}
end

local function calculateSetRideOut(s, pos, from, to)
	local tmpString = s
	local offset = 0
	
	if pos +#s > to then
		tmpString = string.sub(tmpString, 0, math.floor(-(pos +#s - to) +.5))
	end
	if pos < from then
		offset = -(pos - from)
		tmpString = string.sub(tmpString, math.floor(offset +1 +.5))
	end
	
	return tmpString, offset
end

--===== global functions =====--
function oclrl.initiate(gpu, args)
	local this = setmetatable({}, oclrl)
	args = args or {}
	
	this.gpu = gpu
	this.resX, this.resY = gpu.getResolution()
	this.pFColor, this.pBColor = gpu.getForeground(), gpu.getBackground()
	this.checkColor = args.checkColor
	
	return this
end

function oclrl.draw(this, posX, posY, texture, checkColor, area, clear)
	checkColor = checkColor or this.checkColor
	if checkColor == nil or checkColor == true then
		this.pFColor, this.pBColor = this.gpu.getForeground(), this.gpu.getBackground()
	end
	
	local fromX, toX, fromY, toY = 0, this.resX, 0, this.resY
	if area ~= nil then
		fromX, toX, fromY, toY = area[1], area[2], area[3], area[4]
	end
	
	local posX, posY = math.floor(posX +.5), math.floor(posY +.5)
	
	
	
	for c, v in ipairs(texture.drawCalls or texture) do 
		if #v == 1 or type(v[3]) == "table" then --link
			parseLink(this, posX, posY, v, oclrl.draw, false, area, clear)
		elseif #v == 3 or #v == 4 then --set
			if v[1] +posX <= toX and v[2] +posY <= toY then
				if v[4] and v[1] +posX >= fromX and v[2] +posY +#v[3] >= fromY then
					if area ~= nil then
						local tmpString, offset = calculateSetRideOut(v[3], posY +v[2], fromY, toY)
						this.gpu.set(v[1] +posX, v[2] +posY +offset, tmpString, v[4])
					else
						this.gpu.set(v[1] +posX, v[2] +posY, v[3], v[4])
					end
				elseif not v[4] and v[2] +posY >= fromY and v[1] +posX +#v[3] >= fromX then
					if area ~= nil  then
						local tmpString, offset = calculateSetRideOut(v[3], posX +v[1], area[1], area[2])
						
						this.gpu.set(v[1] +posX +offset, v[2] +posY, tmpString, v[4])
					else
						this.gpu.set(v[1] +posX, v[2] +posY, v[3], v[4])
					end
				end
			end
		elseif #v == 5 then --fill
			if v[1] +posX <= toX and v[2] +posY <= toY and v[1] +v[3] +posX > fromX and v[2] +v[4] +posY > fromY then
				if area ~= nil then
					local fx, fy, sx, sy = v[1] +posX, v[2] +posY, v[3], v[4]
					local minusRideOutX, minusRideOutY, rideOutX, rideOutY = 0, 0, 0, 0
					
					if fx < fromX then
						minusRideOutX = minusRideOutX - (fx - fromX)
					end
					if fy < fromY then
						minusRideOutY = minusRideOutY- (fy - fromY)
					end
					if fx + sx > toX then
						sx = sx + 1 - (fx + sx - (toX - minusRideOutX))
					else
						sx = sx - minusRideOutX
					end
					if fy + sy > toY then
						sy = sy + 1 - (fy + sy - (toY - minusRideOutY))
					else
						sy = sy - minusRideOutY
					end
					
					fx = fx + minusRideOutX
					fy = fy + minusRideOutY
					this.gpu.fill(fx, fy, sx, sy, v[5])
				else
					this.gpu.fill(v[1] +posX, v[2] +posY, v[3], v[4], v[5])
				end
			end
		elseif clear ~= true then --color change
			if v[1] == "b" and v[2] ~= this.pBColor then
				this.gpu.setBackground(v[2])
				this.pBColor = v[2]
			elseif v[1] == "f" and v[2] ~= this.pFColor then
				this.gpu.setForeground(v[2])
				this.pFColor = v[2]
			end
		end
	end
end

function oclrl.clearBlack(this, posX, posY, texture, color, area)
	this.gpu.setBackground(color or 0x000000)
	this.gpu.setForeground(color or 0x000000)
	
	this:draw(posX, posY, texture, false, area, true)
end

function oclrl.generateTexture(...)
	local texture = {
		textureFormat = "OCGLT", 
		version = "v0.1", 
		drawCalls = {}
	}
	local t = {}
	if type(...) ~= "table" then
		t = {{...}}
	else
		t = ...
	end
	
	for i, c in pairs(t) do
		table.insert(texture.drawCalls, c)
	end
	
	return texture
end

function oclrl.getColors(t, n)
	local fColor, bColor = nil, nil
	for c = n, 1, -1 do
		if t.drawCalls[c][1] == "f" and fColor == nil then
			fColor = t.drawCalls[c][2]
		end
		if t.drawCalls[c][1] == "b" and bColor == nil then
			bColor = t.drawCalls[c][2]
		end
	end
	return {"f", fColor or 0x000000}, {"b", bColor or 0x000000}
end

function oclrl.clear(this, posX, posY, texture, backgroundTextures, checkOverlap) --ToDo: add "OCGLT_v0.2" support.
	if backgroundTextures == nil then
		this.clearBlack(this, posX, posY, texture)
		return
	end
	if checkOverlap == nil then
		checkOverlap = true
	end
	
	--local write = function(...) io.write(tostring(...)) end --Debug
	--local serialization = require("serialization") --Debug
	
	local toDraw = {drawCalls = {}}
	local toCheck = {}
	local isCheckt = {}
	local pFColor, pBColor = nil, nil
	local fColor, bColor = nil, nil
	
	for c = 1, #backgroundTextures do
		isCheckt[c] = {}
	end
	
	local function SetCall(btdc, bt, c, c2)
		if toDraw[c] == nil then
			toDraw[c] = {}
			
			for c2 = 1, #bt[3].drawCalls, 1 do
				toDraw[c][c2] = {}
			end
		end
		
		if #btdc == 3 or #btdc == 4 then
			toDraw[c][c2] = {btdc[1] +bt[1], btdc[2] +bt[2], btdc[3], btdc[4]}
		elseif #btdc == 5 then
			toDraw[c][c2] = {btdc[1] +bt[1], btdc[2] +bt[2], btdc[3], btdc[4], btdc[5]}
		end
		
		if checkOverlap then
			table.insert(toCheck, {btdc, bt[1], bt[2]})
		end
		
		isCheckt[c][c2] = true
	end
	
	if checkOverlap then
		local old = SetCall
		SetCall = function(btdc, bt, c, c2)
			old(btdc, bt, c, c2)
			toDraw[c][c2].bc = fColor
			toDraw[c][c2].fc = bColor
		end
	else
		local old = SetCall
		SetCall = function(btdc, bt, c, c2)
			old(btdc, bt, c, c2)
			if fColor ~= pFColor then
				toDraw[c][c2].bc = fColor
				pFColor = fColor
			end
			if bColor ~= pBColor then
				toDraw[c][c2].fc = bColor
				pBColor = bColor
			end
		end
	end
	
	local function CheckOverlab(dc, backgroundTextures, posX, posY)
		for c, bt in ipairs(backgroundTextures) do
			for c2, btdc in ipairs(bt[3].drawCalls or bt[3]) do
				if isCheckt[c][c2] ~= true then
					if #btdc == 3 or #btdc == 4 then
						if #dc == 3 or #dc == 4 then
							if dc[1] +posX < btdc[1] +bt[1] +#btdc[3] and dc[1] +posX +#dc[3] > btdc[1] +bt[1] and dc[2] +posY == btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end
						elseif #dc == 5 then
							if dc[1] +posX < btdc[1] +bt[1] +#btdc[3] and dc[1] +posX +dc[3] > btdc[1] +bt[1] and dc[2] +posY <= btdc[2] +bt[2] and dc[2] +posY +dc[4] > btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end	
						end
					elseif #btdc == 5 then
						if #dc == 3 or #dc == 4 then
							if dc[1] +posX < btdc[1] +bt[1] +btdc[3] and dc[1] +posX +#dc[3] > btdc[1] +bt[1] and dc[2] +posY < btdc[2] +bt[2] +btdc[4] and dc[2] +posY > btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end
						elseif #dc == 5 then
							if dc[1] +posX < btdc[1] +bt[1] +btdc[3] and dc[1] +posX +dc[3] > btdc[1] +bt[1] and dc[2] +posY < btdc[2] +bt[2] +btdc[4] and dc[2] +posY +dc[4] > btdc[2] +bt[2] then
								SetCall(btdc, bt, c, c2)
							end
						end
					else
						if btdc[1] == "f" then
							fColor = btdc
						end
						if btdc[1] == "b" then
							bColor = btdc
						end
					end
				end
			end
		end
	end
	
	for c, dc in ipairs(texture.drawCalls) do
		CheckOverlab(dc, backgroundTextures, posX, posY)
	end
	
	if checkOverlap then
		for c, tc in ipairs(toCheck) do
			CheckOverlab(tc[1], backgroundTextures, tc[2], tc[3])
		end
	end
	
	local graphic = {drawCalls = {}}
	for c, v in pairs(toDraw) do
		for c, v2 in pairs(v) do
			if #v2 ~= 0 then
				table.insert(graphic.drawCalls, v2.fc)
				table.insert(graphic.drawCalls, v2.bc)
				table.insert(graphic.drawCalls, v2)
			end
		end
	end
	
	this:draw(0, 0, graphic)
	this.gpu.setForeground(0xffffff)
	--write(#graphic.drawCalls .. " ")
	
end

function oclrl.convertToPixels(this, g, s) --WIP
	local newG = {}
	local oNewG = {}
	s = s or 1
	
	for c, v in ipairs(g.drawCalls) do
		if #v == 3 or #v == 4 then
			for c = 1, #v[3], s do
				newG[#newG +1] = {v[1] +c, v[2], string.sub(v[3], c, c +s -1), v[4]}
			end
		elseif #v == 5 then
			local fillString = ""
			for c = 1, s, 1 do
				fillString = fillString .. v[5]
			end
			
			for c = 1, v[4], 1 do
				for c2 = 1, v[3], s do
					local tm = c2 +#fillString - v[3]
					if tm < 0 then
						tm = 0
					end
					newG[#newG +1] = {v[1] +c2, v[2] +c -1, string.sub(fillString, tm)}
				end
			end
		else
			newG[#newG +1] = v
		end
	end
	
	local count = 0
	for c, v in ipairs(newG) do
		count = count +1
		if count > 1000 then
			os.sleep()
			count = 0
		end
		
		if #v ~= 2 then
			local set = true
			
			for c2 = c +1, #newG, 1 do
				if #newG[c2] ~= 2 and v[2] == newG[c2][2] then
					if v[1] == newG[c2][1] or v[1] > newG[c2][1] and v[1] +#v[3] < newG[c2][1] +#newG[c2][3] then
						set = false
						break
					end
				end
			end
			
			if set then
				oNewG[#oNewG +1] = v
			end
		else
			oNewG[#oNewG +1] = v
		end
	end 
	
	return {textureFormat = "OCGLT", version = "v0.1", drawCalls = oNewG}
end 

function oclrl.convertToRaster(this, g, s) --WIP
	local newG = {}
	s = s or 1
	
	for c, v in ipairs(g.drawCalls) do
		if #v == 3 or #v == 4 then
			
			
			
		elseif #v == 5 then
			
		else
			
		end
	end
	
	return {textureFormat = "OCGLTT", version = "v0.1", drawCalls = newG}
end

return oclrl


