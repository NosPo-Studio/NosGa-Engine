local global = ...

TestParent = {}
TestParent.__index = TestParent

function TestParent.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestParent: init")
end

function TestParent.new(args)
	args = args or {}
	
	--===== default stuff =====--
	local this = global.core.GameObject.new(args)
	this = setmetatable(this, TestParent)
	
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this, t)
		
	end	
	
	this.update = function(this, dt, ra) --will called on every game tick.
		global.log("1")
	end
	
	return this
end

return TestParent