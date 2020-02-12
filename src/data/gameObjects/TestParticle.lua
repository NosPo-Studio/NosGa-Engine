local global = ...

TestParticle = {}
TestParticle.__index = TestParticle

function TestParticle.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestParticle: init")
end

function TestParticle.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.name = "TestParticle"
	
	--===== default stuff =====--
	local this = global.parent.Particle.new(args)
	this = setmetatable(this, TestParticle)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.test = args.test
	
	--this.name = pa(args.name, "TestParticle")
	
	--===== global functions =====--
	
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		if this.test then
			if global.keyboard.isKeyDown("d") then
				this.gameObject:move(1, 0)
			end
			if global.keyboard.isKeyDown("a") then
				this.gameObject:move(-1, 0)
			end
			if global.keyboard.isKeyDown("w") then
				this.gameObject:move(0, -.5)
			end
			if global.keyboard.isKeyDown("s") then
				this.gameObject:move(0, .5)
			end
		end
		
		--this.gameObject:move(math.random(), math.random())
		
		--this.gameObject:move(1 *dt, 0)
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		
	end
	
	this.activate = function(this) --will called when the gameObject get activated by player or signal (not implemented yet).
		
	end
	
	return this
end

return TestParticle