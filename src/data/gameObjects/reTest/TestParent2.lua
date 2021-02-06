local global = ...

TestParent2 = {}
TestParent2.__index = TestParent2

function TestParent2.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestParent2: init")
end

function TestParent2.new(args)
	args = args or {}
	
	--===== default stuff =====--
	local this = global.gameObject.TestParent.new()
	this = setmetatable(this, TestParent2)
	
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this, t)
		
	end	
	
	this.update = function(this, dt, ra) --will called on every game tick.
		global.log("2")
	end
	
	return this
end

return TestParent2