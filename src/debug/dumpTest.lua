package.loaded["libs/UT"] = nil
local ut = require("libs/UT")

local t = {
	t = "TT",
	t2 = {
		t3 = "t3",
		t4 = {t = 3},
		
		"T",
		"T2",
		"T3",
	},
	
	f = function() end,
}

print("--===== start =====--")

--tPrint(t)
print(ut.tostring(t, true))

os.sleep(1)