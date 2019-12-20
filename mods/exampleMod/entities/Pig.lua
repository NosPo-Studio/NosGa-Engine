--[[This is a example class for an entity.
	Currently the the game state is spawing any loaded entity once at start.
]]

local global = ...

Pig = {}
Pig.__index = Pig


function Pig.new(args)
	args.sizeY = 1
	args.texture = "pig"
	
	local this = global.Entity.new(args)
	this = setmetatable(this, Pig)
	
	this.facingLeft = false
	this.toWalk = 0 --time to walk in seconds.
	
	this.acceleraion = 10
	this.maxSpeed = 20 --bug: to high value can cause in glitching through walls/ground (physic/ocgf.RigidBody glitch).
	this.jumpForce = 1
	
	this.update = function(this) --will called on every game tick.
		this.toWalk = this.toWalk - global.dt --dt (delta time) is the time the last gametick has take.
		
		if this.toWalk <= 0 then
			this.toWalk = math.random() * 3
			
			local way = math.random(3)
			if way == 1 then
				this:turn(true)
				this.facingLeft = true
				this.gameObject:playAnimation(-1) --playAnimation(speed: float)
			elseif way == 2 then
				this:turn(false)
				this.facingLeft = false
				this.gameObject:playAnimation(1) --playAnimation(speed: float)
			elseif way == 3 then --stand still
				this.facingLeft = nil
				this.gameObject:stopAnimation(1, true) --stopAnimation(frame: float, playTilEnd: bolean)
			end
		end
		
		if this.facingLeft == true then
			this:addForce(- this.acceleraion, 0, this.maxSpeed)
		elseif this.facingLeft == false then
			this:addForce(this.acceleraion, 0, this.maxSpeed)
		end
		
		if math.random() > .98 then --can fly if true multiple time in a row, will fixed after ocgf update.
			this:addForce(0, - this.jumpForce)
		end
	end
	
	this.draw = function(this) --will called every time the entity will drawed.
		
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		
	end
	
	return this
end

return Pig