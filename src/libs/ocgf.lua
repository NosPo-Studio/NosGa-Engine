--[[
    ocgf Copyright (C) 2019 MisterNoNameLP.
	
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

--[[OpenComputersGamingFramework:
	ToDo:
	
	WIP:
]]

local OCGF = {version = "v1.1.3d"} 
OCGF.__index = OCGF

--===== local vars =====--
local ut = require("libs/UT")
local serialization = require("serialization")

--===== Functions =====--
local function posSizeCheck(this)
	if this.sizeX == nil or this.sizeY == nil then
		return false, "No sizeX or sizeY given"
	end
	if this.posX == nil or this.posY == nil then
		return false, "No posX or posY given"
	end
	return this
end

local function posEqualizer(args, x, y)
	local posX = ut.parseArgs(args.x, args.posX, 0) +x
	local posY = ut.parseArgs(args.y, args.posY, 0) +y
	return posX, posY
end

local function calculateStiffness(speed, stiffness)
	if speed > 0 then
		return math.max(speed - stiffness, 0)
	else
		return math.min(speed + stiffness, 0)
	end
end

local function calculateCollision(this, oc, c) --ownCollider, (other) collider
	local sides = {false, false, false, false} -- -x, x, -y, y
	local disMap = {0, 0, 0, 0}
	
	disMap[1] = (c.posX + c.sizeX) - oc.posX
	disMap[2] = (oc.posX + oc.sizeX) - c.posX
	disMap[3] = (c.posY + c.sizeY) - oc.posY
	disMap[4] = (oc.posY + oc.sizeY) - c.posY
	
	local nearest, dis = 0, 2^32
	for i, d in ipairs(disMap) do
		if d <= dis then --change <= to == if you want x collision "priorized".
			dis = d
			nearest = i
		end
	end
	sides[nearest] = true
	
	if sides[1] then
		this.speedX = math.max(0, this.speedX)
		this.gameObject:move(disMap[nearest], 0, false)
	elseif sides[2] then
		this.speedX = math.min(0, this.speedX)
		this.gameObject:move(-disMap[nearest], 0, false)
	elseif sides[3] then
		this.speedY = math.max(0, this.speedY)
		this.gameObject:move(0, disMap[nearest], false)
	elseif sides[4] then
		this.speedY = math.min(0, this.speedY)
		this.gameObject:move(0, -disMap[nearest], false)
	end
	
	return sides
	
	--print(serialization.serialize({math.floor(disMap[1]), math.floor(disMap[2]), math.floor(disMap[3]), math.floor(disMap[4])}))
	--print(serialization.serialize(sides))
end

local function setLastPos(this, slp, x, y)
	x = x or this.posX
	y = y or this.posY
	slp = ut.parseArgs(slp, true)
	if slp then
		this.lastPosX, this.lastPosY = this.posX, this.posY
	end
end

--===== MainClass =====--
function OCGF.initiate(args)
	local this = setmetatable({}, OCGF)
	args = args or {}
	
	this.component = require("component")
	this.gpu = args.gpu or this.component.gpu
	this.db = ut.parseArgs(args.db, args.doubleBuffering, args.DoubleBuffering)
	this.ut = require("libs/UT")
	this.oclrl = args.oclrl or require(
		args.ocglPath or "libs/oclrl"
	).initiate(
		this.gpu
	)
	this.ocal = args.ocal or require(
		args.ocglPath or "libs/ocal"
	).initiate(
		this.ocal
	)
	
	this.resX, this.resY = this.gpu.getResolution()
	
	return this
end


--===== GameObject (parent of other game objects) =====--
OCGF.GameObject = {widgetType = "GameObject"}
OCGF.GameObject.__index = OCGF.GameObject

function OCGF.GameObject.new(ocgf, args)
	local this = setmetatable({}, OCGF.GameObject)
	args = args or {}
	this.ocgf = ocgf
	
	this.drawTrigger = ut.parseArgs(args.dt, args.drawTrigger, false)
	this.drawCollider = ut.parseArgs(args.dc, args.drawCollider, false)
	this.log = args.logFunc or args.logFunction or function() end --WIP
	
	this.posX = ut.parseArgs(args.x, args.posX, 0)
	this.posY = ut.parseArgs(args.y, args.posY, 0)
	this.lastPosX = this.posX
	this.lastPosY = this.posY
	
	this.parent = args.parent
	
	this.attachedTo = nil --Will be the attached GameObject after using GameObject.attach().
	
	this.boxTrigger = {}
	this.boxCollider = {}
	this.rigidBodys = {}
	this.sprites = {}
	
	return this
end

function OCGF.GameObject.setLastPos(this, x, y)
	setLastPos(this, nil, x + (o.posX - this.posX), y + (o.posY - this.posY))
	for i, o in ipairs(this.boxTrigger) do
		setLastPos(o, nil, x + (o.posX - this.posX), y + (o.posY - this.posY))
	end
	for i, o in ipairs(this.boxCollider) do
		setLastPos(o, nil, x + (o.posX - this.posX), y + (o.posY - this.posY))
	end
	for i, o in ipairs(this.sprites) do
		setLastPos(o, nil, x + (o.posX - this.posX), y + (o.posY - this.posY))
	end
end

function OCGF.GameObject.stop(this)
	for _, rb in ipairs(this.rigidBodys) do
		rb.speedX = 0
		rb.speedY = 0
	end
end

function OCGF.GameObject.setSpeed(this, x, y)
	for _, rb in ipairs(this.rigidBodys) do
		rb.speedX = x
		rb.speedY = y
	end
end

function OCGF.GameObject.getSpeed(this)
	for _, rb in ipairs(this.rigidBodys) do
		return rb.speedX, rb.speedY
	end
end

function OCGF.GameObject.addForce(this, x, y, maxSpeed)
	maxSpeed = maxSpeed or 2^32
	for _, rb in ipairs(this.rigidBodys) do
		if x ~= 0 then
			if rb.speedX + x >= maxSpeed then
				rb.speedX = maxSpeed
			elseif rb.speedX + x <= -maxSpeed then
				rb.speedX = -maxSpeed
			else
				rb.speedX = rb.speedX +x
			end
		end
		if y ~= 0 then
			if rb.speedY + y >= maxSpeed then
				rb.speedY = maxSpeed
			elseif rb.speedY + y <= -maxSpeed then
				rb.speedY = -maxSpeed
			else
				rb.speedY = rb.speedY +y
			end
		end
	end
end

function OCGF.GameObject.addSprite(this, args)
	args.x, args.y = posEqualizer(args, this.posX, this.posY)
	local obj = OCGF.Sprite.new(this, args)
	table.insert(this.sprites, obj)
	return obj
end

function OCGF.GameObject.addBoxCollider(this, args)
	args.x, args.y = posEqualizer(args, this.posX, this.posY)
	args.isCollider = true
	local obj = OCGF.BoxTrigger.new(this, args)
	table.insert(this.boxCollider, obj)
	return obj
end

function OCGF.GameObject.addBoxTrigger(this, args)
	args.x, args.y = posEqualizer(args, this.posX, this.posY)
	local obj = OCGF.BoxTrigger.new(this, args)
	table.insert(this.boxTrigger, obj)
	return obj
end

function OCGF.GameObject.addRigidBody(this, args)
	local obj = OCGF.RigidBody.new(this, args)
	table.insert(this.rigidBodys, obj)
	return obj
end

function OCGF.GameObject.onCollision(this, gameObject, selfCall)
	--this.log("GO: Collision: " .. tostring(selfCall))
end

function OCGF.GameObject.onTrigger(this, gameObject, selfCall)
	--this.log("GO: Trigger: " .. tostring(selfCall))
end

function OCGF.GameObject.getPos(this)
	return this.posX, this.posY
end

function OCGF.GameObject.getLastPos(this)
	return this.lastPosX, this.lastPosY
end

function OCGF.GameObject.getSprites(this)
	local sprites = {}
	for _, s in ipairs(this.sprites) do
		table.insert(sprites, s)
	end
	return sprites
end

function OCGF.GameObject.getTrigger(this)
	local trigger = {}
	for _, bt in ipairs(this.boxTrigger) do
		table.insert(trigger, bt:getTrigger()[1])
	end
	return trigger
end

function OCGF.GameObject.getCollider(this)
	local trigger = {}
	for _, bc in ipairs(this.boxCollider) do
		table.insert(trigger, bc:getTrigger()[1])
	end
	return trigger
end

function OCGF.GameObject.getRigidBodys(this)
	local rbs = {}
	for _, s in ipairs(this.rigidBodys) do
		table.insert(rbs, s)
	end
	return rbs
end

function OCGF.GameObject.update(this, gameObjects) --gameObject can be collider table	
	if this.attachedTo ~= nil and #this:getRigidBodys() == 0 then
		local x, y = this.attachedTo:getPos()
		local lx, ly = this.attachedTo:getLastPos()
		this:move(x - lx, y - ly)
	end
	
	for i, c in ipairs(gameObjects) do
		for i, bt in ipairs(this.boxTrigger) do
			bt:update(c:getTrigger())
			bt:update(c:getCollider())
		end
	end
end

function OCGF.GameObject.updatePhx(this, gameObjects, dt) --gameObject can be collider table
	dt = dt or 1
	for _, rb in ipairs(this.rigidBodys) do
		rb:update(gameObjects, dt)
	end
end

function OCGF.GameObject.move(this, x, y, SLP)
	for i, o in ipairs(this.boxTrigger) do
		o:move(x, y, SLP)
	end
	for i, o in ipairs(this.boxCollider) do
		o:move(x, y, SLP)
	end
	for i, o in ipairs(this.sprites) do
		o:move(x, y, SLP)
	end
	setLastPos(this, SLP)
	this.posX = this.posX +x
	this.posY = this.posY +y
end

function OCGF.GameObject.moveTo(this, x, y, SLP) --WIP: bug: ...
	for i, bt in ipairs(this.boxTrigger) do
		bt:moveTo(x + (bt.posX - this.posX), y + (bt.posY - this.posY), SLP)
	end
	for i, bc in ipairs(this.boxCollider) do
		bc:moveTo(x + (bc.posX - this.posX), y + (bc.posY - this.posY), SLP)
	end
	for i, o in ipairs(this.sprites) do
		o:moveTo(x + (o.posX - this.posX), y + (o.posY - this.posY), SLP)
	end
	setLastPos(this, SLP)
	this.posX = x
	this.posY = y
end

function OCGF.GameObject.draw(this, offsetX, offsetY, area, dt, background, color)
	offsetX = offsetX or 0
	offsetY = offsetY or 0
	for i, o in ipairs(this.sprites) do
		o:draw(dt, background, offsetX, offsetY, area)
	end
	if this.drawTrigger then
		for i, bt in ipairs(this.boxTrigger) do
			bt:draw(color, offsetX, offsetY, area)
		end
	end
	if this.drawCollider then
		for i, bc in ipairs(this.boxCollider) do
			bc:draw(color, offsetX, offsetY, area)
		end
	end
end

function OCGF.GameObject.clear(this, offsetX, offsetY, color, actual)
	offsetX = offsetX or 0
	offsetY = offsetY or 0
	if this.drawTrigger then
		for i, bt in ipairs(this.boxTrigger) do
			bt:clear(color, actual, offsetX, offsetY)
		end
	end
	if this.drawCollider then
		for i, bc in ipairs(this.boxCollider) do
			bc:clear(color, actual, offsetX, offsetY)
		end
	end
	for i, o in ipairs(this.sprites) do
		o:clear(color, actual, offsetX, offsetY)
	end
end

function OCGF.GameObject.startAnimation(this, speed, frame)
	for _, s in pairs(this.sprites) do
		s:start(speed, frame)
	end
end

function OCGF.GameObject.stopAnimation(this, frame, playTilEnd)
	for _, s in pairs(this.sprites) do
		s:stop(frame, playTilEnd)
	end
end

function OCGF.GameObject.pauseAnimation(this)
	for _, s in pairs(this.sprites) do
		s:pause()
	end

end
function OCGF.GameObject.playAnimation(this, speed, frame)
	for _, s in pairs(this.sprites) do
		s:play(speed, frame)
	end
end

function OCGF.GameObject.attach(this, gameObject)
	this.attachedTo = gameObject
end

function OCGF.GameObject.detach(this)
	if this.attachedTo == nil then return false, "No GameObject attached to" end
	for _, rb in pairs(this.rigidBodys) do
		rb:detach()
	end
	this.attachedTo = nil
end

--===== Sprite =====--
OCGF.Sprite = {widgetType = "Sprite"}
OCGF.Sprite.__index = OCGF.Sprite

function OCGF.Sprite.new(gameObject, args)
	local this = setmetatable({}, OCGF.Sprite)
	args = args or {}
	this.gameObject = gameObject
	
	this.posX = args.x or args.posX or 0
	this.posY = args.y or args.posY or 0 
	this.texture = ut.parseArgs(args.t, args.texture, this.gameObject.ocgf.oclrl.generateTexture(0, 0, ""))
	this.background = args.background or 0x000000
	
	if this.texture.format == "OCGLA" or this.texture.format == "pan" then
		this.animation = gameObject.ocgf.ocal.Animation.new(gameObject.ocgf.ocal, this.texture, {clear = false})
	elseif this.texture.format == "pic" then
		if this.gameObject.ocgf.db ~= nil then
			this.useDB = true
		else
			this.texture = this.gameObject.ocgf.oclrl.generateTexture({
				{"b", 0xFF69B4},
				{0, 0, this.texture[1], this.texture[2], " "},	
			})
		end
	end
	
	this.lastPosX = this.posX
	this.lastPosY = this.posY
	
	return this
end

function OCGF.Sprite.move(this, x, y, slp)
	setLastPos(this, slp)
	this.posX = this.posX +x
	this.posY = this.posY +y
	return this.posX, this.posY
end

function OCGF.Sprite.moveTo(this, x, y, slp)	
	setLastPos(this, slp)
	this.posX, this.posY = x, y
end

function OCGF.Sprite.draw(this, dt, background, offsetX, offsetY, area)	
	background = background or this.background
	if this.animation ~= nil then
		this.animation.background = background
		this.animation:draw(this.posX + offsetX, this.posY + offsetY, dt, nil, background, area)
	elseif this.useDB then
		this.gameObject.ocgf.db.setDrawLimit(area[1], area[3], area[2], area[4])
		
		this.gameObject.ocgf.db.drawImage(math.floor(this.posX + offsetX +.5), math.floor(this.posY + offsetY +.5), this.texture)
		
		this.gameObject.ocgf.db.resetDrawLimit()
	else
		this.gameObject.ocgf.oclrl:draw(this.posX + offsetX, this.posY + offsetY, this.texture, nil, area)
	end
end

function OCGF.Sprite.clear(this, color, actual, offsetX, offsetY)
	if actual then
		if this.animation ~= nil then
			this.animation:clearBlack(this.posX + offsetX, this.posY + offsetY, nil, color)
		else
			this.gameObject.ocgf.oclrl:clearBlack(this.posX + offsetX, this.posY + offsetY, this.texture, color)
		end
	else
		if this.animation ~= nil then
			this.animation:clearBlack(this.lastPosX + offsetX, this.lastPosY + offsetY, nil, color)
		else
			this.gameObject.ocgf.oclrl:clearBlack(this.lastPosX + offsetX, this.lastPosY + offsetY, this.texture, color)
		end
	end
end

function OCGF.Sprite.start(this, speed, frame)
	if this.animation ~= nil then
		this.animation:start(speed, frame)
	end
end

function OCGF.Sprite.stop(this, frame, playTilEnd)
	if this.animation ~= nil then
		this.animation:stop(frame, playTilEnd)
	end
end

function OCGF.Sprite.pause(this)
	if this.animation ~= nil then
		this.animation:pause()
	end
end

function OCGF.Sprite.play(this, speed, frame)
	if this.animation ~= nil then
		this.animation:play(speed)
	end
end

function OCGF.Sprite.changeTexture(this, newTexture)
	this.texture = newTexture
	if this.texture.format == "OCGLA" then
		if this.animation ~= nil then
			this.animation.animation = this.texture
		else
			this.animation = this.gameObject.ocgf.ocal.Animation.new(this.gameObject.ocgf.ocal, this.texture)
		end
	else
		this.animation = nil
	end
end

--===== RigidBody =====--
OCGF.RigidBody = {widgetType = "RigidBody"}
OCGF.RigidBody.__index = OCGF.RigidBody

function OCGF.RigidBody.new(gameObject, args)
	local this = setmetatable({}, OCGF.RigidBody)
	args = args or {}
	this.gameObject = gameObject
	
	this.calculateHalfPixel = ut.parseArgs(args.hp, args.halfPixel, args.calculateHalfPixel, true) -- if true then is speedY == speedY /2
	this.mass = ut.parseArgs(args.mass, 0)
	this.hardness = ut.parseArgs(args.hardness, 1)
	this.gravitationFactor = ut.parseArgs(args.g, args.gravitation, args.gravitationFactor, 1)
	this.stiffness = ut.parseArgs(args.stiffness, 0) -- 1 == 1 speed loss per update, -1 == unmovable.
	this.speedTakeover = ut.parseArgs(args.speedTakeover, 1) -- 0 == 100% speed loss per update, .1 == 90% speed loss pr update, 1 == 0% speed loss per update.
	this.stickiness = ut.parseArgs(args.stickiness, 1) --1 == enouth to stick stiff, 0 == no stickiness.
	this.speedLoss = ut.parseArgs(args.sl, args.speedLoss, 0) --Slightly dependent from the FPS so only recomended to use on graphical effects.
	
	this.speedX = 0
	this.speedY = 0
	
	return this
end

--function OCGF.RigidBody.update(this, gameObjects, pingTrigger, pingGameObject, callOwnFunction, slp) --ToDo: add realistic physics.

function OCGF.RigidBody.update(this, gameObjects, dt, slp) --ToDo: add realistic physics.
	local g = this.gravitationFactor
	if this.gameObject.attachedTo ~= nil then
		g = g * (1 - this.stickiness)
	end
	this.speedX = calculateStiffness(this.speedX, this.stiffness * dt)
	this.speedY = this.speedY + (g * dt)
	this.speedY = calculateStiffness(this.speedY, this.stiffness * dt)
	
	this.speedX = calculateStiffness(this.speedX, math.abs(this.speedX * this.speedLoss * dt))
	this.speedY = calculateStiffness(this.speedY, math.abs(this.speedY * this.speedLoss * dt))
	
	if this.gameObject.attachedTo ~= nil then
		local x, y = this.gameObject.attachedTo:getPos()
		local lx, ly = this.gameObject.attachedTo:getLastPos()
		
		this.gameObject:move(
			calculateStiffness((x - lx), this.stiffness * (1 - this.stickiness) * dt) * this.speedTakeover,
			calculateStiffness((y - ly), this.stiffness * (1 - this.stickiness) * dt) * this.speedTakeover
		)
	end
	
	local speedX, speedY = this.speedX, this.speedY
	if this.calculateHalfPixel then
		speedY = speedY /2
	end
	
	this.gameObject:move(speedX *dt, speedY *dt, slp)
	
	local collider = {}
	for _, go in ipairs(gameObjects) do
		for _, c in ipairs(go:getCollider()) do
			table.insert(collider, c)
		end
	end
	
	for _, c in ipairs(this.gameObject:getCollider()) do
		for _, collision in ipairs(c:update(collider)) do
			calculateCollision(this, c, collision)
		end
	end
end

function OCGF.RigidBody.detach(this)
	this.speedX = this.speedX + this.gameObject.attachedTo:getRigidBodys()[1].speedX
	this.speedY = this.speedY + this.gameObject.attachedTo:getRigidBodys()[1].speedY
end

--===== BoxTrigger =====--
OCGF.BoxTrigger = {widgetType = "BoxTrigger"}
OCGF.BoxTrigger.__index = OCGF.BoxTrigger

function OCGF.BoxTrigger.new(gameObject, args)
	local this = setmetatable({}, OCGF.BoxTrigger)
	args = args or {}
	this.gameObject = gameObject
	
	this.name = ut.parseArgs(args.n, args.name, nil)
	
	this.posX = args.x or args.posX or 0
	this.posY = args.y or args.posY or 0 
	this.sizeX = args.sx or args.sizeX or 1
	this.sizeY = args.sy or args.sizeY or 1
	this.listedFunction = ut.parseArgs(args.lf, args.listedFunction, function() end)
	this.pingTrigger = ut.parseArgs(args.ping, args.pingTrigger, false)
	this.pingGameObject = ut.parseArgs(args.pingGameObject, false)
	this.callOwnFunction = ut.parseArgs(args.callFunction, args.callOwnFunction, true)
	this.callOwnGameObject = ut.parseArgs(args.callOwn, true)
	this.isCollider = ut.parseArgs(args.isCollider, false)
	this.floatCalculation = ut.parseArgs(args.fc, args.floatCalculation, false)
	
	this.lastPosX = this.posX
	this.lastPosY = this.posY
	
	return posSizeCheck(this)
end

function OCGF.BoxTrigger.update(this, collider, pingTrigger, pingGameObject, callOwnFunction, callOwnGameObject)	
	
	--this.gameObject.log(this.listedFunction, this.callOwnFunction, this.isCollider, this.hass == "!!")
	
	
	pingTrigger = ut.parseArgs(pingTrigger, this.pingTrigger)
	pingGameObject = ut.parseArgs(pingGameObject, this.pingGameObject)
	callOwnFunction = ut.parseArgs(callOwnFunction, this.callOwnFunction)
	callOwnGameObject = ut.parseArgs(callOwnGameObject, this.callOwnGameObject)
	
	local collisions = {}
	local gameObjects = {}
	
	for i, c in ipairs(collider) do
		local x, y, x2, y2 = this.posX, this.posY, c.posX, c.posY
		
		if not this.floatCalculation then
			local f = math.floor
			x, y, x2, y2 = f(x +.5), f(y +.5), f(x2 +.5), f(y2 +.5)
		end
		
		if c ~= this and 
			x + this.sizeX > x2 and x < x2 + c.sizeX and
			y + this.sizeY > y2 and y < y2 + c.sizeY
		then
			table.insert(collisions, c)
			table.insert(gameObjects, c.gameObject)
			if pingTrigger then
				--c.listedFunction(this.gameObject, false, this.gameObject.parent) --other trigger
				c:listedFunction(this, false) --other trigger
			end
			if callOwnFunction then
				--this.gameObject.log(this.listedFunction, this.callOwnFunction, this.isCollider, this.hass == "!!", "CALL")
				--this.listedFunction(c.gameObject, true, this.gameObject.parent) --this trigger
				this:listedFunction(c, true) --this trigger
			end
			if pingGameObject then
				if this.isCollider then
					c.gameObject:onCollision(this.gameObject, false, this.gameObject.parent)
				else
					c.gameObject:onTrigger(this.gameObject, false, this.gameObject.parent)
				end
			end
			if callOwnGameObject then
				if this.isCollider then
					this.gameObject:onCollision(c.gameObject, true, this.gameObject.parent)
				else
					this.gameObject:onTrigger(c.gameObject, true, this.gameObject.parent)
				end
			end
		end
	end
	
	return collisions, gameObjects
end

function OCGF.BoxTrigger.move(this, x, y, slp)
	setLastPos(this, slp)
	this.posX = this.posX +x
	this.posY = this.posY +y
	
	return this.posX, this.posY
end

function OCGF.BoxTrigger.moveTo(this, x, y, slp)	
	setLastPos(this, slp)
	this.posX, this.posY = x, y
end

function OCGF.BoxTrigger.getTrigger(this)
	return {this}
end

function OCGF.BoxTrigger.draw(this, color, offsetX, offsetY, area)
	local gpu = this.gameObject.ocgf.gpu
	local ut = this.gameObject.ocgf.ut
	offsetX, offsetY = offsetX or 0, offsetY or 0
	
	this.gameObject.ocgf.oclrl:draw(0, 0, this.gameObject.ocgf.oclrl.generateTexture({
		{"b", color or 0xFF69B4},
		{this.posX + offsetX, this.posY + offsetY, ut.fillString("", this.sizeX, " ")},
		{this.posX + offsetX, this.posY + (this.sizeY -1) + offsetY, ut.fillString("", this.sizeX, " ")},
		{this.posX + offsetX, this.posY + offsetY, ut.fillString("", this.sizeY, " "), true},
		{this.posX + (this.sizeX -1) + offsetX, this.posY + offsetY, ut.fillString("", this.sizeY, " "), true},
	}), nil, area)
end

function OCGF.BoxTrigger.clear(this, color, actual, offsetX, offsetY)
	local gpu = this.gameObject.ocgf.gpu
	local ut = this.gameObject.ocgf.ut
	offsetX, offsetY = offsetX or 0, offsetY or 0
	gpu.setBackground(color or 0x000000)
	
	if actual then 
		this.gameObject.ocgf.oclrl:clearBlack(0, 0, this.gameObject.ocgf.oclrl.generateTexture({
			{"b", color or 0xFF69B4},
			{this.posX + offsetX, this.posY + offsetY, ut.fillString("", this.sizeX, " ")},
			{this.posX + offsetX, this.posY + (this.sizeY -1) + offsetY, ut.fillString("", this.sizeX, " ")},
			{this.posX + offsetX, this.posY + offsetY, ut.fillString("", this.sizeY, " "), true},
			{this.posX + (this.sizeX -1) + offsetX, this.posY + offsetY, ut.fillString("", this.sizeY, " "), true},
		}), nil, area)
	else
		this.gameObject.ocgf.oclrl:clearBlack(0, 0, this.gameObject.ocgf.oclrl.generateTexture({
			{"b", color or 0xFF69B4},
			{this.lastPosX + offsetX, this.lastPosY + offsetY, ut.fillString("", this.sizeX, " ")},
			{this.lastPosX + offsetX, this.lastPosY + (this.sizeY -1) + offsetY, ut.fillString("", this.sizeX, " ")},
			{this.lastPosX + offsetX, this.lastPosY + offsetY, ut.fillString("", this.sizeY, " "), true},
			{this.lastPosX + (this.sizeX -1) + offsetX, this.lastPosY + offsetY, ut.fillString("", this.sizeY, " "), true},
		}), nil, area)
	end
end

return OCGF





