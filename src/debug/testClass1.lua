local global = ...

local Entity = {}
Entity.__index = Entity

function Entity.new(args)
	local this = setmetatable({}, Entity)
	
	this.test = function()
		cprint("test")
	end
	
	return this
end

function Entity.test2()
	cprint("test2")
end

return Entity