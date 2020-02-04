local Class3 = dofile("Class3.lua")

Class1 = {}
Class1.__index = Class1

function Class1.new(oclrl)
	local this = setmetatable({}, Class1)
	
	this.test = 1
	this.testObj = Class3.new(oclrl)
	
	this.draw = function(this, x)
		this.testObj:draw(x)
	end
	
	return this
end

return Class1