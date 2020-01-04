local global = ...

TestGO = {}
TestGO.__index = TestGO

function TestGO.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestGO: init")
end

function TestGO.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.sizeX = 6
	args.sizeY = 3
	args.gameObject = {
		{"BoxCollider", sx = 6, sy = 3},
		{"Sprite", texture = global.texture.stone},
	}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, TestGO)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.speed = 10
	this.isMovingLeft = false
	
	
	--===== global functions =====--
	this.test = function()
		global.log("GG")
	end
	
	--===== default functions =====--
	this.spawn = function(this) --will called if gameObject become spawned.
		--global.log("TestGO: spawned")
	end
	
	this.despawn = function(this) --will called if gameObject become despawned (not implemented yet).
		global.log("TestGO: despawned")
	end
	
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		--global.log("TestGO: start")
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		global.log("TestGO: stop")
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		local x, y = this:getPos()
		if this.isMovingLeft then
			this:move(-this.speed *dt, 0)
		else
			this:move(this.speed *dt, 0)
		end
		if x >= 130 then
			this.isMovingLeft = true
		elseif x <= 100 then
			this.isMovingLeft = false
		end
		
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		--global.log("TestGO(" .. tostring(this.ngeAttributes.name) .. "): draw")
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		--global.log("TestGO: clear")
	end
	
	this.activate = function(this) --will called when the gameObject get activated by player or signal (not implemented yet).
		global.log("TestGO: activate")
	end
	
	return this
end

return TestGO