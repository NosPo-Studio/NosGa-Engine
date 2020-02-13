local global = ...

ParticleTestContainer = {}
ParticleTestContainer.__index = ParticleTestContainer

function ParticleTestContainer.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("ParticleTestContainer: init")
end

function ParticleTestContainer.new(args)
	--===== gameObject definition =====--
	args = args or {}
	args.particle = "TestParticle2"
	args.type = 1
	args.color = 0x666666
	
	--===== default stuff =====--
	local this = global.parent.ParticleContainer.new(args)
	this = setmetatable(this, ParticleTestContainer)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	
	
	--===== global functions =====--
	this.drag = function(this, s) 
		if true then
			local x, y = s[3], s[4]
			--global.log(x, y)
			this:addParticle(x +100, y -3)
		end
	end
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
		if false then
			this:addParticle(1, 1)
			this:addParticle(3, 2)
			this:addParticle(3, 2)
			this:addParticle(3, 2.5)
			this:addParticle(3, 3)
			this:addParticle(4, 2.5)
			this:addParticle(5, 4)
			
			this:addParticle(20, 4)
			
			this:addParticle(3, 2, {test = true})
			this:addParticle(5, 2, {test = true})
			this:addParticle(5, 3, {test = true})
			--this:addParticle(5, 1)
			
			--this:addParticle(-14, 10)
			
			for i = 0, 100 do
				--this:addParticle(10, 10)
			end
			
			--this:addParticle(3, 3)
			--this:addParticle(6, 3.5)
		end
		
		
		--this:addParticle(10, 5)
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