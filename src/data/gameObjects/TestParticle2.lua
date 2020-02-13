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
	args.color = 0x999999
	
	--===== default stuff =====--
	local this = global.parent.Particle.new(args)
	this = setmetatable(this, TestParticle)
	
	--===== init =====--
	local pa = global.ut.parseArgs
	
	this.test = args.test
	
	this.gameObject:addRigidBody({g = -10})
	this.gameObject:addBoxCollider({sx = 1, sy = .5})
	
	--this.name = pa(args.name, "TestParticle")
	
	--===== global functions =====--
	
	
	--===== default functions =====--
	this.start = function(this) --will called everytime a new object of the gameObject is created.
		
	end
	
	this.stop = function(this) --will called when gameObject object becomes deloaded (e.g. out of screen)
		
	end
	
	this.update = function(this, dt, ra) --will called on every game tick.
		if true then
			local speed = 10
			local x = 0
			if math.random() > .5 then
				x = math.random()
			else
				x = -math.random()
			end
			
			if dt > global.conf.maxTickTime then
				global.log(dt, global.dt)
			end
			
			this.gameObject:move(x *speed *dt, 0)
		end
		
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