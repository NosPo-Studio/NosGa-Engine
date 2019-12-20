local global = ...

local Test2 = {}
Test2.__index = Test2

function Test2.new(args)
	local this = setmetatable(dofile("debug/testClass1.lua").new(), Test2)
	
	this.test = function()
		cprint("test3")
	end
	
	return this
end

function Test2.test2()
	cprint("test4")
end

return Test2