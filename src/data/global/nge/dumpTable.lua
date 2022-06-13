local global = ...

local function dumpTable(t, deep, sleepInterval) --Bug, ToDo: deep dumb is iterating itself!
	local s, count = "", 0
	for i, c in pairs(t) do
		s = s .. tostring(i) .. " = " .. tostring(c) .. " | "
		if deep then
			if type(c) == "table" then
				dumpTable(c, true, sleepInterval)
			end
		end
		count = count +1
		if sleepInterval ~= nil and sleepInterval ~= -1 and count > sleepInterval then
			os.sleep()
			count = 0
		end
	end
	return s
end

return dumpTable