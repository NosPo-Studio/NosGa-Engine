local global = ...

ParticleTestContainer = {}
ParticleTestContainer.__index = ParticleTestContainer

function ParticleTestContainer.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("ParticleTestContainer: init")
end

function ParticleTestContainer.new(args)
	--===== gameObject definition =====--
	args = args or {}
	--args.particle = "TestParticle2"
	args.type = 1
	args.useCollision = false
	args.updateAlways = true
	
	--===== default stuff =====--
	local this = global.parent.ParticleContainer.new(args)
	this = setmetatable(this, ParticleTestContainer)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		
	end
	
	this.draw = function(this) --will called every time the gameObject will drawed.
		
	end
	
	this.clear = function(this, acctual) --will called when the sntity graphics are removed.
		
	end
	
	this.activate = function(this) --will called when the gameObject get activated by player or signal (not implemented yet).
		
	end
	
	return this
end

return ParticleTestContainer