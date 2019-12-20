local controls = {
	--=== mouse ===--
	place = 0, --u can hold alt to switch these keys.
	broke = 1, --u can hold alt to switch these keys.
	
	--=== keys ===--
	left = "a",
	right = "d",
	jump = "w",
	sneak = "s",
	
	inv = 18,
	
	cameraUp = 200, --arrow up
	cameraDown = 208, --arrow down
	cameraLeft = 203, --arrow left
	cameraRight = 205, --arrow right
	
	debug = {
		showConsole = 59, --default: 59 (f1)
		showDebug = 61, --default: 61 (f3)
		reloadState = 63, --reloadrs the current state and all data groups defined in the config. default: 63 (f5)
		rerenderScreen = 64, --rerenders the screen (removes graphic errors). default: 64 (f6)
	}
}

return controls