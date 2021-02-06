local global = ...

TestParent3 = {}
TestParent3.__index = TestParent3

TestParent3.parentClass = "TestParent2"

function TestParent3.init(this) --will calles when the gameObject become loaded/reloaded.
	--global.log("TestParent3: init")
end

function TestParent3.new(args)
	args = args or {}
	
	--===== default stuff =====--
	local this = global.gameObject.TestParent2.new()
	this = setmetatable(this, TestParent3)
	
	--===== init =====--
	
	--===== global functions =====--
	
	--===== default functions =====--
	this.start = function(this, t)
		
	end	
	
	--local orgUpdate = this.update
	this.update = function(this, dt, ra) --will called on every game tick.
		--orgUpdate(this, dt, ra)
		--global.log("3")
	end
	
	return this
end

return TestParent3