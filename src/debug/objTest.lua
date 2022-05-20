function c1(args) 
	local this = {} 
	
	this.test = "t1"
	
	this = setmetatable(this, GameObjectsTemplate) 
	
	return this
end

function c2(args) 
	local this = c1()
	
	this.test2 = "t2"
	
	this = setmetatable(this, GameObjectsTemplate) 
	
	return this
end


local o1 = c2()
local o2 = c2()

o1.test2 = "t3"

print(o1.test2)
print(o2.test2)


--print(o2.test2)