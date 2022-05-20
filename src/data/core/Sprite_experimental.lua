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

local Sprite = {}
Sprite.__index = Sprite

local pa = global.ut.parseArgs

function Sprite.new(args)
	args = args or {}
	local this = setmetatable({}, Sprite)
	
	this.posX = pa(args.x, args.posX, args.offsetX, 0)
	this.posY = pa(args.y, args.posY, args.offsetY, 0)
	
	if type(args.texture) == "string" then
		this.texture = global.texture[args.texture]
	else
		this.texture = args.texture
	end
	
	return this, this.texture, this.posX, this.posY
end

function Sprite.clear(this, renderArea, area, offsetX, offsetY, setBackground)
	--[[
	if this.noClear then
		return false, "noClear is set to true."
	end
	if setBackground or setBackground == nil then
		global.gpu.setBackground(0x0)
	end
	global.gpu.fill(this.posX + offsetX, this.posY + offsetY, this.texture.resX, this.texture.resY, " ")
	]]
end

function Sprite.draw(this, renderArea, area, offsetX, offsetY)
	if this.texture.bufferID ~= nil then
		local posX, posY, resX, resY = this.posX + offsetX, this.posY + offsetY, this.texture.resX, this.texture.resY
		local textureBufferPosX, textureBufferPosY = 1, 1
		local overLapPrositiveX, overLapNegativeX, overLapPrositiveY, overLapNegativeY = 0, 0, 0, 0
		
		overLapNegativeX = math.max(area.posX - posX, 0)
		overLapPrositiveX = math.max((posX + resX) - (area.posX + area.sizeX), 0)
		overLapNegativeY = math.max(area.posY - posY, 0)
		overLapPrositiveY = math.max((posY + resY) - (area.posY + area.sizeY), 0)
		
		resX = resX - overLapPrositiveX - overLapNegativeX
		textureBufferPosX = overLapNegativeX +1
		posX = posX + overLapNegativeX
		resY = resY - overLapPrositiveY - overLapNegativeY
		textureBufferPosY = overLapNegativeY +1
		posY = posY + overLapNegativeY
		
		global.gpu.bitblt(renderArea:getBufferID(), math.floor(posX +.5), math.floor(posY +.5), math.floor(resX +.5), math.floor(resY +.5), this.texture.bufferID,  textureBufferPosY, textureBufferPosX)
		
		global.db.setBufferOnly(true)
	end
	
	if this.texture.format == "pic" and global.conf.useDoubleBuffering then
		global.db.setDrawLimit(area.posX, area.posY, area.posX + area.sizeX -1, area.posY + area.sizeY -1)
		
		global.db.drawImage(math.floor(this.posX + offsetX +.5), math.floor(this.posY + offsetY +.5), this.texture)
		
		global.db.resetDrawLimit()
	elseif this.texture.format == "OCGLT" and global.conf.useDoubleBuffering then
		global.oclrl:draw(this.posX + offsetX, this.posY + offsetY, this.texture, nil, {area.posX,  area.posX + area.sizeX -1, area.posY, area.posY + area.sizeY -1})
	end
	
	global.db.setBufferOnly(false)
end















return Sprite
