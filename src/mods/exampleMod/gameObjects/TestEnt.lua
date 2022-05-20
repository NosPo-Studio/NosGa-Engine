--[[This is a example class for an entity.
	Currently the the game state is spawing any loaded entity once at start.
]]

local texture = "pinkstone"

local global = ...

TestEnt = {}
TestEnt.__index = TestEnt

function TestEnt.init(this) --will calles when the block become loaded/reloaded.
	--global.log("TESTENT: init")
end

function TestEnt.new(args)
	args.sizeY = 1
	--args.texture = texture
	local this = global.Entity.new(args)
	this = setmetatable(this, TestEnt)
	
	
	this.spawn = function(this) --will called if entity become spawned.
		--global.log("TESTENT: spawned")
	end
	
	this.despawn = function(this) --will called if entity become despawned (not implemented yet).
		global.log("TESTENT: despawned")
	end
	
	this.start = function(this) --will called everytime a new object of the entity is created.
		--global.log("TESTENT: start")
	end
	
	this.stop = function(this) --will called when entity object becomes deloaded (e.g. out of screen)
		--global.log("TESTENT: stop")
	end
	
	this.update = function(this) --will called on every game tick.
		--global.log("TESTENT: update")
	end
	
	this.draw = function(this) --will called every time the entity will drawed.
		--global.log("TESTENT: draw")
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		--global.log("TESTENT: clear")
	end
	
	this.activate = function(this) --will called when the entity get activated by player or signal (not implemented yet).
		global.log("TESTENT: activate")
	end
	
	return this
end

return TestEnt