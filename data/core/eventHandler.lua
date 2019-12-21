local global = ...
local eh = {}

--===== local variables =====--
local pressedKeys = {}
local specialPressedKeys = {}

--===== local functions =====--
local function print(...)
	if global.conf.debug.ehDebug then
		global.debug(...)
	end
end

local function parseSignal(signal)
	if #signal == 0 then return false end
	
	global.run(global.core.eventHandler[signal[1]], signal)
	
	if signal[1] ~= "key_down" then
		global.run(global.state[global.currentState][signal[1]], signal)
	end
	
	return true
end

--===== global functions =====--
function eh.init()
	
end

function eh.update(sleepTime)	
	local signal = {true}
	
	while parseSignal({global.event.pull(0)}) do
		--print(global.currentFrame)
	end
	
	local maxDT = 1 / global.conf.targetFramerate
	
	global.dt = global.computer.uptime() - global.lastUptime
	global.lastUptime = global.computer.uptime()
	
	if global.conf.targetFramerate ~= -1 and global.dt < maxDT then
		print("SLP", (1 / global.conf.targetFramerate) - math.max(global.dt - (1 / global.conf.targetFramerate), 0), global.currentFrame)
		
		
		parseSignal({global.event.pull((1 / global.conf.targetFramerate) - math.max(global.dt - (1 / global.conf.targetFramerate), 0))})
	end
	
	for i, s in pairs(pressedKeys) do
		global.run(global.state[global.currentState].key_pressed, s)
	end
	for i, s in pairs(specialPressedKeys) do
		global.run(global.state[global.currentState].key_pressed, s)
	end
end

local function touch(_, _, x, y, b, p)
	global.ocui:update(x, y)
	--run(global.state[global.currentState].touch, x, y, b, p)
end

function eh.key_down(s)
	local c, k, p = s[3], s[4], s[5] 
	
	if c == 3 then --ctrl + c
		print("[EH]: Program stopped by user.")
		global.isRunning = false
	end
	
	if k == global.controls.debug.showConsole then
		global.conf.showConsole = not global.conf.showConsole
		if not global.conf.showConsole then
			global.clear()
		end
	end
	
	if k == global.controls.debug.showDebug then --f3
		global.conf.showDebug = not global.conf.showDebug
		if not global.conf.showDebug then
			global.clear()
		end
	end
	if k == global.controls.debug.reloadState and global.isDev then --f5
		global.log("--========== RELOAD STAGE ==========--")
		global.run(global.state[global.currentState].stop)
		global.state[global.currentState] = nil
		
		global.gameObjects = {}
		global.renderAreas = {}
		
		if global.conf.debug.onReload.conf then
			global.conf = dofile("conf.lua")
		end
		global.conf.debug.onReload.reload = true
		if global.keyboard.isControlDown() then
			local reloadList = {}
			
			for i, c in pairs(global.conf.debug.onReload) do
				reloadList[i] = true
			end
			
			global.load(reloadList)
		else
			global.load(global.conf.debug.onReload)
		end
		
		global.conf.debug.onReload.reload = nil
		
		global.state[global.currentState] = loadfile("data/states/" .. global.currentState .. ".lua")(global)
		global.run(global.state[global.currentState].init)
		global.run(global.state[global.currentState].start)
		
		global.clear()
	end
	if k == global.controls.debug.rerenderScreen then --f6
		global.clear()
	end
	
	if pressedKeys[0] == nil and pressedKeys[c] == nil then
		global.run(global.state[global.currentState][s[1]], s)
		pressedKeys[c] = s
	elseif pressedKeys[0] ~= nil and specialPressedKeys[c] == nil then
		global.run(global.state[global.currentState][s[1]], s)
		specialPressedKeys[c] = s
	end
end

function eh.key_up(s)
	if s[3] == 0 then
		for i, c in pairs(specialPressedKeys) do
			global.run(global.state[global.currentState][s[1]], c)
			specialPressedKeys[i] = nil
		end
	end
	
	pressedKeys[s[3]] = nil
	specialPressedKeys[s[3]] = nil
end

function eh.stop()
	pressedKeys = {}
	specialPressedKeys = {}
end

return eh