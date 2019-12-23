local controls = {
	
	m = {
		[0] = {"test"},
	},
	c = {
		[32] = {"test", "test2"},
	},
	k = {
		--[57] = {"test"},
	},
	
	debug = { --Do not change yet!
		showConsole = 59, --default: 59 (f1)
		writeInConsole = 60, --default: 60 (f2)
		showDebug = 61, --default: 61 (f3)
		reloadState = 63, --reloadrs the current state and all data groups defined in the config. default: 63 (f5)
		rerenderScreen = 64, --rerenders the screen (removes graphic errors). default: 64 (f6)
	},
}

return controls