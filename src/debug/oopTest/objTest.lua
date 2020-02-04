local Class2 = dofile("Class2.lua")
local oclrl = dofile("oclrl.lua").initiate(require("component").gpu)

local obj1 = Class2.new(oclrl)
local obj2 = Class2.new(oclrl)
local obj3 = Class2.new(oclrl)

obj1.test = "t"
obj2.test = "t2"

obj1.testObj.test3 = "t3"

obj1:draw(10)
obj2:draw(20)
obj3:draw(30)


for i, c in pairs(obj1) do
	print(i, c)
end
print(obj1.testObj.test3)

for i, c in pairs(obj2) do
	print(i, c)
end
print(obj2.testObj.test3)