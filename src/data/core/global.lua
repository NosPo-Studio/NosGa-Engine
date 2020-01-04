--[[
    This file is part of the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019 NosPo Studio

    The NosGa Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The NosGa Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the NosGa Engine.  If not, see <https://www.gnu.org/licenses/>.
]]

local args = {...}
local conf = args[1]

--===== global vars =====--
local global = {
	--=== vars ===--
	isRunning = true,
	isDev = conf.debug.isDev,
	
	conf = conf,
	controls = {c = {}, k = {}, m = {}},
	
	currentState = "",
	dt = 0, --deltaTime
	lastUptime = 0,
	fps = -1,
	currentFrame = 0,
	
	cameraPosX = 0,
	cameraPosY = 0,
	lastCameraPosX = 0, --regenerated every update.
	lastCameraPosY = 0,--regenerated every update.
	cameraSubPosX = 0,
	cameraSubPosY = 0,
	
	backgroundColor = 0x00409f,
	
	resX = 0,
	resY = 0,
	
	--=== content ===--
	state = {},
	texture = {},
	parent = {
		name = {}, 
		id = {}, 
		info = {amout = 0},
	},
	gameObject = { --gameObject parents.
		name = {}, 
		id = {}, 
		info = {amout = 0},
	},
	
	--=== core ===--
	orgPrint = print,
	
	core = {}, --All core parents.
	gameObjects = {}, --actual generated/calculated/rendered gameObjects.
	objectMatrix = {}, --a 4D matrix of the gameObjects. {layer, x, y, id}
	renderAreas = {},
	alreadyLoaded = {},
	loadedMods = {},
}

--===== global functions =====--
function global.print(...)
	local t = {...}
	local s = tostring(t[1])
	global.tbConsole:add(s, select(2, ...))
	global.ocl.add(s, select(2, ...))
	
	if global.conf.showConsole then
		global.tbConsole:draw()
		
		if global.conf.debug.isDev and global.conf.directConsoleDraw and global.conf.useDoubleBuffering then
			global.ocui.oclrl.gpu = global.realGPU
			global.tbConsole:draw()
			global.ocui.oclrl.gpu = global.gpu
		end
	end
end

function cprint(...)
	local t = {...}
	local s = "[CPRINT] " .. tostring(t[1])
	global.print(s, select(2, ...))
end

function global.log(...)
	local t = {...}
	local s = "[INFO] " .. tostring(t[1])
	global.print(s, select(2, ...))
end

function global.warn(...)
	local t = {...}
	local s = "[WARN] " .. tostring(t[1])
	global.print(s, select(2, ...))
end

function global.error(...)
	local t = {...}
	local s = "[ERROR] " .. tostring(t[1])
	global.print(s, select(2, ...))
end

function global.fatal(...)
	local t = {...}
	local s = "[FATAL] " .. tostring(t[1])
	global.print(s, select(2, ...))
	global.isRunning = false
	global.orgPrint(debug.traceback())
end

function global.debug(...)
	if global.isDev then
		local t = {...}
		local s = "[DEBUG] " .. tostring(t[1])
		global.print(s, select(2, ...))
	end
end

function global.slog(...)
	local t = {...}
	local s = "[SINFO]: Start: " .. tostring(t[1])
	global.print(s, select(2, ...))
	for i, s in ipairs(t) do
		local ss = global.serialization.serialize(t[i]) .. ";"
		global.print(ss)
	end
	global.print("[SINFO]: End.")
end

function global.setConsoleSize(size)
	size = size or global.conf.consoleSizeY
	global.tbConsole.sizeX = global.resX
	global.tbConsole.sizeY = global.resY - (global.resY - size)
	global.tbConsole.posY = global.resY - size
end

function global.run(func, ...)
	if func ~= nil then
		local v = {xpcall(func, debug.traceback, ...)}
		if v[1] == false then
			global.error("[GE]: Failerd to run " .. tostring(func) .. "\n", v[2], debug.traceback())
		end
		
		return v
	end
end

function global.load(args)
	args.global = global
	return loadfile("data/core/dataLoading.lua")(args)
end

function global.loadData(target, dir, func, logFuncs, overwrite, subDirs, structured)
	local id = 1
	if target.info ~= nil and target.info.amout ~= nil then
		id = target.info.amout +1
	end
	local path = global.shell.getWorkingDirectory() .. "/" .. dir .. "/"
	logFuncs = logFuncs or {}
	print = logFuncs.log or global.log
	warn = logFuncs.warn or global.warn
	subDirs = global.ut.parseArgs(subDirs, true)
	
	for file in global.fs.list(path) do
		local p, name, ending = global.ut.seperatePath(file)
		
		if string.sub(file, #file) == "/" then
			if structured then
				if target[string.sub(p, 0, #p -1)] == nil or target[string.sub(p, 0, #p -1)].structured == true or overwrite and not structured then
					target[string.sub(p, 0, #p -1)] = {structured = true}
					global.loadData(target[string.sub(p, 0, #p -1)], dir .. "/" .. p, func, logFuncs, overwrite, subDirs, structured)
				else
					global.error("[DLF]: Target already existing!: " .. p .. " :" .. tostring(target))
				end
			else
				global.loadData(target, dir .. "/" .. p, func, logFuncs, overwrite, subDirs, structured)
			end
		elseif target[name] == nil or overwrite then
			local debugString = ""
			if target[name] == nil then
				debugString = "[DLF]: Loading file: " .. dir .. "/" .. file .. ": "
			else
				debugString = "[DLF]: Reloading file: " .. dir .. "/" .. file .. ": "
			end
		
			local suc, err = loadfile(path .. file)
			if global.isDev then
				if suc == nil then
					warn("[DLF] Failed to load file: " .. dir .. "/" .. file .. ": " .. tostring(err))
				else
					print(debugString .. tostring(suc))
				end
			end
			
			if suc then
				target[name] = suc(global)
			end
			
			if func ~= nil then
				func(name, id)
			end
			
			id = id +1
		end
	end
	return id
end

return global