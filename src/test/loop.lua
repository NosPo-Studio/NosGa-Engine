local version = "v0.1d"

local shell = require("shell")
local gpu = require("component").gpu

local args, opts = shell.parse(...)

local stop = args[2]

local oprint = print
local function print(...)
	if not opts.s then
		oprint(...)
	end
end

local function resetColor()
	gpu.setBackground(0x0)
	gpu.setForeground(0xffffff)
end

--===== prog start =====--
print("Starting loop " .. version)

while true do
	resetColor()
	print("--===== Starting: " .. args[1] .. " =====--")
	local value = dofile(shell.getWorkingDirectory() .. "/" .. args[1])
	resetColor()
	print("--===== " .. args[1] .. " has stoped =====--")
	
	if value ~= nil and value == stop then
		break
	end
	os.sleep(.1)
end