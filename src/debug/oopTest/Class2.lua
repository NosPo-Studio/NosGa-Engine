local Class1 = dofile("Class1.lua")

Class2 = {}
Class2.__index = Class2

function Class2.new(oclrl)
	local this = setmetatable(Class1.new(oclrl), Class2)
	
	this.test2 = 2
	
	return this
end

return Class2