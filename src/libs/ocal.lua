--[[
	OCAL (OpenComputersAnimationLibarry) is a small libarry for playing animations.
	It was originaly a part of OCLRL wich is licensed under the GPLv3.
	
	oclrl Copyright (C) 2019 MisterNoNameLP.
    ocal Copyright (C) 2020 NosPo Studio.
	
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
local ocal = {version = "v0.1.2d"} --OpenComputersGraphicLibary
ocal.__index = ocal


--===== local vars =====--
local computer = require("computer")
local shell = require("shell")
local fs = require("filesystem")
local ut = require("libs/UT")
local image = nil

--===== local functions =====--
local function addFrameTime(this, dt, backwards)
	this.lastFrame = this.currentFrame
	this.currentFrame = (this.currentFrame + (dt * this.speed))
end

local function clearDBBlack(this, x, y, frame, color, area)
	local resX, resY = this.ocal.gpu.getResolution()
	area = area or {0, resX, 0, resY}
	
	this.ocal.db.setDrawLimit(area[1], area[3], area[2], area[4])
	this.ocal.db.drawRectangle(math.floor(x +.5), math.floor(y +.5), frame[1], frame[2], color or 0x000000, 0x000000, " ")
	this.ocal.db.resetDrawLimit()
end

--===== global functions =====--
function ocal.initiate(args)
	local this = setmetatable({}, ocal)
	args = args or {}
	
	this.oclrl = args.oclrl
	this.db = ut.parseArgs(args.db, args.doubleBuffering, args.DoubleBuffering)
	this.image = args.image
	
	if this.oclrl ~= nil and this.oclrl.gpu ~= nil then
		this.gpu = this.oclrl.gpu
	else
		this.gpu = component.gpu
	end
	
	if type(this.db) == "string" then
		this.db = require(this.db)
	elseif this.db == nil then
		this.db = require(ut.parseArgs(args.libs, args.libPath, "") .. "/DoubleBuffering")
	end
	if type(this.image) == "string" then
		this.image = require(this.dimage)
	elseif this.image == nil then
		this.image = require(ut.parseArgs(args.libs, args.libPath, "") .. "/image")
	end
	
	image = this.image

	return this
end

function ocal.load(path)
	if string.sub(path, 0, 1) ~= "/" then
		path =shell.getWorkingDirectory() .. "/" .. path .. "/"
	end
	
	local info = dofile(path .. "info.lua")
	local animation = {
		frames = {},
	}
	
	for i, c in pairs(info) do
		animation[i] = c
	end
	
	for file in fs.list(path .. "frames") do
		local p, name, ending = ut.seperatePath(file)
		
		animation.frames[tonumber(name)] = image.load(path .. "frames/" .. file)
	end
	
	return animation
end

--===== Animation =====--
ocal.Animation = {version = "v0.0d"} --OpenComputersGraphicLibary
ocal.Animation.__index = ocal.Animation

function ocal.Animation.new(ocal, animation, args)
	local this = setmetatable({}, ocal.Animation)
	
	args = args or {}
	this.ocal = ocal
	
	this.speed = args.speed or 1
	this.useDt = ut.parseArgs(args.dt, true)
	this.clearTexture = ut.parseArgs(args.clear, true)
	this.background = args.background
	this.halt = ut.parseArgs(args.halt, false)
	this.tmpHalt = false
	
	this.currentFrame = args.frame or 1
	this.lastFrame = this.currentFrame
	this.lastCall = 0 --time in sec.
	
	this.animation, this.useDB = nil, nil
	
	if type(animation) == "string" then
		this.animation = this.ocal:load(animation)
	elseif animation.format == "pan" then
		this.animation = animation
		this.useDB = true
	elseif animation.format == "OCGLA" then
		this.animation = animation
	end
	
	
	return this
end

function ocal.Animation.draw(this, posX, posY, dt, clear, background, area)
	if ut.parseArgs(clear, this.clearTexture) then
		background = ut.parseArgs(background, this.background)
		if background == nil or type(background) == "number" then
			this:clearBlack(posX, posY, false, background, area)
		else
			this:clearBlack(posX, posY, false, background, area)
			--this:clear(posX, posY, background, true, false)
		end
	end
	
	if this.useDB then
		local resX, resY = this.ocal.gpu.getResolution()
		area = area or {0, resX, 0, resY}
		
		this.ocal.db.setDrawLimit(area[1], area[3], area[2], area[4])
		this.ocal.db.drawImage(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)])
		this.ocal.db.resetDrawLimit()
	else
		if this.animation.frames[math.floor(this.currentFrame)] ~= nil then
			this.ocal.oclrl:draw(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)], nil, area)
		end
	end
	
	if ut.parseArgs(dt, this.dt) == false then
		addFrameTime(this, 1, backwards)
		return
	end
	
	if dt == nil or dt == true then
		dt = computer.uptime() - this.lastCall
		this.lastCall = computer.uptime()
	end
	
	addFrameTime(this, (dt / this.animation.frameTime), backwards)
	
	if math.floor(this.currentFrame) > #this.animation.frames then
		this.currentFrame = 1
		if this.halt or this.tmpHalt then
			this.speed = 0
			this.tmpHalt = false
		end
	elseif math.floor(this.currentFrame) < 1 then
		this.currentFrame = #this.animation.frames +.9
		if this.halt or this.tmpHalt then
			this.speed = 0
			this.currentFrame = 1
			this.tmpHalt = false
		end
	end
end

function ocal.Animation.clearBlack(this, posX, posY, current, color, area)
	if current == true then
		if this.useDB then
			clearDBBlack(this, math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)], color, area)
		else
			this.ocal.oclrl:clearBlack(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)], color, area)
		end
	elseif current == false then
		if this.useDB then
			clearDBBlack(this, math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.lastFrame)], color, area)
		else
			this.ocal.oclrl:clearBlack(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.lastFrame)], color, area)
		end
	else
		if this.useDB then
			clearDBBlack(this, math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)], color, area)
			clearDBBlack(this, math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.lastFrame)], color, area)
		else
			this.ocal.oclrl:clearBlack(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)], color, area)
			this.ocal.oclrl:clearBlack(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.lastFrame)], color, area)
		end
	end
end

function ocal.Animation.clear(this, posX, posY, textures, checkOverlap, current) --useless yet (not supporting "OCGLT_v0.2"/"OCGLA_v0.1".)
	if current then
		this.ocal.oclrl:clear(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.currentFrame)], textures, checkOverlap)
	else
		this.ocal.oclrl:clear(math.floor(posX +.5), math.floor(posY +.5), this.animation.frames[math.floor(this.lastFrame)], textures, checkOverlap)
	end
end

function ocal.Animation.start(this, speed, frame)
	this.speed = speed or 1
	this.currentFrame = frame or 1
	this.tmpHalt = false
end

function ocal.Animation.stop(this, frame, playTilEnd)
	if playTilEnd then
		this.tmpHalt = true
	else
		this.speed = 0
		this.frame = frame or 1
	end
end

function ocal.Animation.pause(this)
	this.speed = 0
end

function ocal.Animation.play(this, speed)
	this.speed = speed or 1
	this.tmpHalt = false
end


return ocal

--print(string.sub("1234567890", 0, #"1234567890" -3))
--print(string.sub("1234567890", #"1234567890" -3 +1))





