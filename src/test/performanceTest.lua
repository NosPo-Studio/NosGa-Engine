local computer = require("computer")

local startTime

local traceback = debug.traceback

local t = {test = {}}
local et = {}

local test = {test = 3, tt = {tt2 = 3}}

for c = 0, 1000000 do
    t.test[c] = 2
end

local function tf() return true end

startTime = computer.uptime()

local pairs = pairs

--local test = test.tt

for i, v in pairs(t.test) do
    --local t = test.tt.tt2
end

local xpcall = xpcall
for c = 0, 1000 do
    xpcall(tf(), traceback)
    --pcall(tf)
    --tf()
end

print(computer.uptime() - startTime)