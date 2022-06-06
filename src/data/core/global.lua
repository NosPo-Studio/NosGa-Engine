--[[
    This file is part of the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019-2020 NosPo Studio

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

local xpcall = xpcall
local freeMemory, totalMemory = require("computer").freeMemory, require("computer").totalMemory
local gpuFreeMemory, gpuTotalMemory

do 
	local gpu = require("component").gpu
	if gpu.freeMemory then
		gpuFreeMemory, gpuTotalMemory = gpu.freeMemory, gpu.totalMemory
	else
		gpuFreeMemory, gpuTotalMemory = freeMemory, totalMemory
	end
end

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
	
	backgroundColor = 0x00409f,
	
	resX = 0,
	resY = 0,
	currentVBuffer,
	screenBufferID = 0,
	
	debugDisplayPosY = 1,
	
	--=== content ===--
	state = {}, 
	texture = {}, --textures.
	texturePack = nil, --texture back informations.
	animation = {},
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
	renderAreas = {},
	alreadyLoaded = {},
	loadedMods = {},
	
	--=== debug ===--
	debug = {},
	debugString = "",
}

--===== global functions =====--
function nge_getGlobal()
	return global
end

function global.print(...)
	local t = {...}
	local s = ""
	local lastIndex = 1
	
	for i, c in pairs(t) do		
		if lastIndex +1 < i then
			for count = lastIndex +1, i -1 do
				s = s .. "nil "
			end
		end
		s = s .. tostring(c) .. " "
		lastIndex = i
	end
	
	global.tbConsole:add(s)
	global.ocl.add(s)
	
	if global.conf.showConsole and global.conf.debug.isDev and global.conf.directConsoleDraw and global.conf.useDoubleBuffering then
		global.ocui.oclrl.gpu = global.realGPU
		global.tbConsole:draw()
		global.ocui.oclrl.gpu = global.gpu
	end	
end

function cprint(...)
	global.print("[CPRINT] ", ...)
end

function global.log(...)
	global.print("[INFO] ", ...)
end

function global.warn(...)
	global.print("[WARN] ", ...)
end

function global.error(...)
	global.print("[ERROR] ", ...)
end

function global.fatal(...)
	global.print("[FATAL] ", ...)
	global.isRunning = false
	global.orgPrint(..., debug.traceback())
end

function global.debug.log(...)
	if global.isDev then
		global.print("[DEBUG] ", ...)
	end
end

function global.slog(...)
	local t = {...}
	global.print("[SINFO]: Start: ", ...)
	for i, s in ipairs(...) do
		local ss = global.serialization.serialize(t[i]) .. ";"
		global.print(ss)
	end
	global.print("[SINFO]: End.")
end

function global.debug.renderDebugInformations()
	if global.conf.showDebug then
		global.gpu.setForeground(0xaaaaaa)
		global.gpu.setBackground(0x333333)
		global.gpu.set(1, global.debugDisplayPosY, "NosGa Engine: " .. global.version .. 
			" | RAM: " .. tostring(math.floor(100 - (freeMemory() / totalMemory() * 100) +.5)) .. "%" ..
			" | VRAM: " .. tostring(math.floor(100 - (gpuFreeMemory() / gpuTotalMemory() * 100) +.5)) .. "%" ..
			" | FPS: " .. tostring(math.floor((global.fps) +.5) .. 
			" | Frame: " .. tostring(global.currentFrame)
		) .. global.debugString .. string.rep(" ", global.resX))
		
		global.debugString = ""
	end
end

function global.setConsoleSize(size) --obsolete
	size = size or global.conf.consoleSizeY
	global.tbConsole.sizeX = global.resX
	global.tbConsole.sizeY = global.resY - (global.resY - size)
	global.tbConsole.posY = global.resY - size
end

function global.run(func, ...)
	if func ~= nil then
		local suc, err
		if conf.debug.isDev then
			suc, err = xpcall(func, debug.traceback, ...)
		else
			suc, err = pcall(func, ...)
		end
		if suc == false then
			global.error("[GE]: Failerd to run " .. tostring(func) .. "\n", err, debug.traceback())
		end
	end
end

function global.load(args)
	args.global = global
	return loadfile("data/core/dataLoading.lua")(args)
end

function global.loadData(target, dir, func, logFuncs, overwrite, subDirs, structured, loadFunc, initFile)
	local id = 1
	if target.info ~= nil and target.info.amout ~= nil then
		id = target.info.amout +1
	end
	local path = global.shell.getWorkingDirectory() .. "/" .. dir .. "/"
	logFuncs = logFuncs or {}
	local print = logFuncs.log or global.log
	local warn = logFuncs.warn or global.warn
	local onError = logFuncs.error or global.error
	
	subDirs = global.ut.parseArgs(subDirs, true)
	
	for file in global.fs.list(path) do
		local p, name, ending = global.ut.seperatePath(file)
		
		if name ~= "gitignore" and name ~= "gitkeep" then
			if string.sub(file, #file) == "/" and subDirs then
				if structured then
					if target[string.sub(p, 0, #p -1)] == nil or target[string.sub(p, 0, #p -1)].structured == true or overwrite and not structured then
						target[string.sub(p, 0, #p -1)] = {structured = true}
						global.loadData(target[string.sub(p, 0, #p -1)], dir .. "/" .. p, func, logFuncs, overwrite, subDirs, structured)
					else
						onError("[DLF]: Target already existing!: " .. p .. " :" .. tostring(target))
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
				
				local suc, err 
				if loadFunc ~= nil then
					suc, err = loadFunc(path .. file)
				elseif ending == ".pic" then
					suc, err = global.image.load(path .. file)
					if suc ~= false then
						suc.format = "pic"
						suc.resX, suc.resY = suc[1], suc[2]
					end
				else
					suc, err = loadfile(path .. file)
				end
				
				if global.isDev then
					if suc == nil then
						warn("[DLF] Failed to load file: " .. dir .. "/" .. file .. ": " .. tostring(err))
					else
						print(debugString .. tostring(suc))
					end
				end
				
				if type(suc) == "function" then
					target[name or string.sub(p, 0, #p -1)] = suc(global)
				elseif type(suc) == "table" then
					target[name or string.sub(p, 0, #p -1)] = suc
				end
				
				local obj = target[name or string.sub(p, 0, #p -1)]
				if type(obj) == "table" and initFile == true then
					global.run(obj.init, obj)
				end
				
				if func ~= nil then
					func(name, id)
				end
				
				id = id +1
			end
		end
	end
	return id
end

return global