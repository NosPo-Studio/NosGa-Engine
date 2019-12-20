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
local global = args[1]
local toLoad = args[2]
local path = "data"
local loadingMods = false

if args[4] ~= nil then --onay on mod loading.
	path = "mods/" .. args[4]
	loadingMods = true
end
if global.alreadyLoaded[path] == nil then
	global.alreadyLoaded[path] = {}
end

--===== local functions =====--
local print = args[3] or function(...) 
	global.log(...)
	if global.conf.showConsole then
		global.tbConsole:draw()
	end
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
		target = nil
		return loadfile(path)(...)
	end
end

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
if loadingMods then
	global.log("[DL]: Loading mod data groups: " .. reloadString .. ".")
else
	global.log("[DL]: Loading data groups: " .. reloadString .. ".")
end

--===== reloadings =====--
if toLoad.conf then
	global.conf = reloadFile(global.conf, "conf.lua", global)
end

if toLoad.re then
	global.re = reloadFile(global.re, "data/core/re.lua", global)
end

if toLoad.ge then
	global.ge = reloadFile(global.ge, "data/core/ge.lua", global)
end

if toLoad.states then
	global.state = {} 
	global.loadData(global.state, "data/states", nil, print)
end

--===== data loading =====--
if toLoad.global then
	if global.alreadyLoaded[path].global ~= true or toLoad.reload then
		print("[DL]: Loading global.")
		global.loadData(global, path .. "/global", nil, print, true)
		global.alreadyLoaded[path].global = true
	else
		print("[DL]: global are loaded already.")
	end
end
	
if toLoad.textures then
	if global.alreadyLoaded[path].textures ~= true or toLoad.reload then
		if not loadingMods then
			if global.isDev then
				print("[DL]: Loading texturepack info.lua: " .. tostring(loadfile("texturePacks/" .. global.conf.texturePack .. "/info.lua")))
			end
			global.texturePack = loadfile("texturePacks/" .. global.conf.texturePack .. "/info.lua")(global)
			print("[DL]: Loading textures.")
			global.texture = {}
			global.loadData(global.texture, "texturePacks/" .. global.conf.texturePack .. "/textures", nil, print)
		else
			print("[DL]: Loading textures.")
			global.loadData(global.texture, path .. "/textures", nil, print, global.conf.preferModTextures)
		end
		global.alreadyLoaded[path].textures = true
	else
		print("[DL]: Textures are loaded already.")
	end
end

if toLoad.parents then
	if global.alreadyLoaded[path].parents ~= true or toLoad.reload then
		if not loadingMods then
			global.parent = {name = {}, id = {}, info = {amout = 0}}
		end
		print("[DL]: Loading parents.")
		global.loadData(global.parent, path .. "/parents", function(name, id)
			global.parent.id[name] = id
			global.parent.name[id] = name
			global.parent.info.amout = global.parent.info.amout +1
			global.run(global.parent[name].init, id)
		end, print)
		global.alreadyLoaded[path].parents = true
	else
		print("[DL]: parents are loaded already.")
	end
end	

if toLoad.gameObjects then
	if global.alreadyLoaded[path].gameObjects ~= true or toLoad.reload then
		if not loadingMods then
			global.gameObject = {name = {}, id = {}, info = {amout = 0}}
		end
		print("[DL]: Loading gameObjects.")
		global.loadData(global.gameObject, path .. "/gameObjects", function(name, id)
			global.gameObject.id[name] = id
			global.gameObject.name[id] = name
			global.gameObject.info.amout = global.gameObject.info.amout +1
			global.run(global.gameObject[name].init, id)
		end, print)
		global.alreadyLoaded[path].gameObjects = true
	else
		print("[DL]: gameObjects are loaded already.")
	end
end

if toLoad.mods then --WIP
	if global.alreadyLoaded.mods ~= true or toLoad.reload then
		print("[DL]: Loading mods.")
		for file in global.fs.list(global.shell.getWorkingDirectory() .. "/mods/") do
			print("[DL]: Loading mod: " .. file)
			global.load({
				parents = toLoad.parents,
				gameObjects = toLoad.gameObjects,
				textures = toLoad.textures,
				reload = toLoad.reload
			}, print, file)
		end
	else
		print("[DL]: Mods are loaded already.")
	end
end

if loadingMods then
	global.log("[DL]: Mod data loading done.")
else
	global.log("[DL]: Data loading done.")
end

return true