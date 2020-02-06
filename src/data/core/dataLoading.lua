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

--===== local variables =====--
local args = ...
local global = args.global
local toLoad = args.toLoad
local reload = args.reload
local loadMods = args.loadMods
local print = args.print or function(...) global.log(...) end

local baseDir = ""

--===== local functions =====--
local fprint
do 
	local p = print
	fprint = function(...) p(...) end
end
do 
	local p = print
	print = function(...)
		if global.conf.debug.dlDebug then
			p(...)
		end
	end
end

local function reloadFile(target, path, ...)
	local debugString = "[DL]: Reloading file: " .. path .. ": "
	
	local suc, err = loadfile(path)
	if suc == nil then
		print(debugString .. tostring(err))
	else
		print(debugString .. tostring(suc))
		return suc(...)
	end
end

local function loadFiles(target, name, func, directPath, subDirs, structured, loadFunc)
	local path = baseDir .. name
	subDirs = global.ut.parseArgs(subDirs, true)
	
	if directPath then
		path = directPath
	end
	
	if global.alreadyLoaded[path] ~= true or reload then
		if global.alreadyLoaded[path] ~= true then
			print("[DL]: Loading data group: " .. name .. ".")
		elseif reload then
			print("[DL]: Reloading data group: " .. name .. ".")
		end
		global.loadData(target, path, func, {log = print, warn = global.warn}, reload, subDirs, structured, loadFunc)
		global.alreadyLoaded[path] = true
	else
		print("[DL]: Data group already loaded: " .. name .. ".")
	end
end

--===== init =====--
local reloadString = ""
for i, c in pairs(toLoad) do
	if c then
		if #reloadString > 0 then
			reloadString = reloadString .. ", " .. i
		else
			reloadString = reloadString .. i
		end
	end
end
if loadMods then
	fprint("[DL]: Loading mod data groups: " .. reloadString .. ".")
	baseDir = "mods/"
else
	fprint("[DL]: Loading data groups: " .. reloadString .. ".")
	baseDir = "data/"
end



--===== core reloadings =====--
if toLoad.conf then
	local savedSettings = {
		showConsole = global.conf.showConsole,
	}
	
	global.conf = loadfile("nosGaConf.lua")(global)
	
	for i, c in pairs(loadfile("conf.lua")(global)) do
		global.conf[i] = c
	end
	
	global.controls = {c = {}, k = {}, m = {}}
	local controlsINI = global.LIP.load("controls.ini")
	
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
					addEntry(target, tonumber(string.byte(s)), i)
				else
					addEntry(target, tonumber(s), i)
				end
			end
		end
	end

	parseControls(controlsINI.code, global.controls.c)
	parseControls(controlsINI.string, global.controls.c, true)
	parseControls(controlsINI.key, global.controls.k)
	parseControls(controlsINI.mouse, global.controls.m)
	
	for i, c in pairs(savedSettings) do
		global.conf[i] = c
	end
end

if toLoad.re then
	global.core.re = reloadFile(global.core.re, "data/core/re.lua", global)
end

if toLoad.uh then
	global.core.updateHandler = reloadFile(global.core.updateHandler, "data/core/updateHandler.lua", global)
end

if toLoad.eh then
	global.core.eventHandler.stop()
	global.core.eventHandler = reloadFile(global.core.eventHandler, "data/core/eventHandler.lua", global)
end

if toLoad.RenderArea then
	global.core.RenderArea = reloadFile(global.core.RenderArea, "data/core/RenderArea.lua", global)
end
if toLoad.GameObject then
	global.core.GameObject = reloadFile(global.core.GameObject, "data/core/GameObject.lua", global)
end

--===== asset loading =====--
if toLoad.global then
	loadFiles(global, "global")
end
if toLoad.structuredGlobal then
	loadFiles(global, "structuredGlobal", nil, nil, nil, true)
end
if toLoad.states then
	loadFiles(global.state, "states")
end
if toLoad.textures then
	loadFiles(global.texture, "textures", nil, "texturePacks/" .. global.conf.texturePack .. "/textures")
end
if toLoad.animations then
	
	
	loadFiles(global.animation, "animations", nil, "texturePacks/" .. global.conf.texturePack .. "/animations", false, false, global.ocal.load)
end
if toLoad.parents then
	loadFiles(global.parent, "parents")
end
if toLoad.gameObjects then
	loadFiles(global.gameObject, "gameObjects")
end


return true









