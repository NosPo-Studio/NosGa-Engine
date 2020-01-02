local serialization = require("serialization")
local ini = require("libs/thirdParty/LIP")

local t = ini.load("controls.ini")
local controls = {c = {}, k = {}, m = {}}

local function parseControls(toParse, target, convert)
	local function addEntry(t, i, e)
		if t[i] == nil then
			t[i] = {}
		end
		table.insert(t[i], e)
	end
	
	for i, c in pairs(toParse) do
		for s in string.gmatch(tostring(c), "[^,]+") do
			if convert then
				addEntry(target, string.byte(s), i)
			else
				addEntry(target, s, i)
			end
		end
	end
end

parseControls(t.code, controls.c)
parseControls(t.string, controls.c, true)
parseControls(t.key, controls.k)
parseControls(t.mouse, controls.m)


print(serialization.serialize(controls))