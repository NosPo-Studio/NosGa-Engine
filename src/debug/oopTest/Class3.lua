Class3 = {}
Class3.__index = Class3

function Class3.new(oclrl)
	local this = setmetatable({}, Class3)
	
	this.test3 = 3
	this.anim = oclrl.Animation.new(oclrl, require("testAnimation2"))
	
	this.draw = function(this, x)
		this.anim:draw(x, 10)
	end
	
	return this
end

return Class3