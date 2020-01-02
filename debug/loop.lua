local shell = require("shell")

local args, opts = shell.parse(...)

local stop = args[2]

local oprint = print
local function print(...)
	if not opts.s then
		oprint(...)
	end
end

while true do
	print("Start " .. args[1] .. " =================================")
	local value = dofile(shell.getWorkingDirectory() .. "/" .. args[1])
	print(args[1] .. " has stoped =================================")
	
	if value ~= nil and value == stop then
		break
	end
	os.sleep(.1)
end