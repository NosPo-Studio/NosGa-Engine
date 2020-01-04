local computer = require("computer")
local event = require("event")

local t = {}
local tgo = loadfile("libs/thirdParty/DoubleBuffering.lua")()

local ptime = computer.uptime()
local pmem = computer.freeMemory()

for i = 0, 100000, 2 do
	
end



print(computer.uptime() - ptime, (pmem - computer.freeMemory()) /1024)