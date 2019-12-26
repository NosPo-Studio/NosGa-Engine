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

--===== dev =====--
local orgRequire = require
local require = require
if global.isDev then
	require = function(s)
		if io.open(s .. ".lua", "r") == nil then
			return orgRequire(s)
		else
			return dofile(s .. ".lua")
		end
	end
end

local print = function(...)
	if global.conf.debug.isDev then
		print(...)
	end
end

--===== global vars =====--
--global.tl = require("libs/tl") --debug/testing
global.fs = require("filesystem")
global.shell = require("shell")
global.event = require("event")
global.term = require("term")
global.ut = require("libs/UT")
global.ocl = require("libs/ocl")
global.computer = require("computer")
global.keyboard = require("keyboard")
global.serialization = require("serialization")
global.component = require("component")
global.realGPU = global.component.gpu

print("useDoubleBuffering: " .. tostring(global.conf.debug.useDoubleBuffering))
if global.conf.debug.useDoubleBuffering then
	global.gpu = loadfile("libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})
else
	global.gpu = global.component.gpu
end
global.ocgl = require("libs/ocgl").initiate(global.gpu)
global.ocui = require("libs/ocui").initiate(global.ocgl)
global.ocgf = require("libs/ocgf").initiate({gpu = global.gpu})

local func, err = loadfile("data/core/ge.lua")
print("[INIT]: Loading GE: " .. tostring(func) .. " " .. tostring(err))
global.ge = func(global)

local func, err = loadfile("data/core/re.lua")
print("[INIT]: Loading RE: " .. tostring(func) .. " " .. tostring(err))
global.re = func(global)


local func, err = loadfile("data/core/RenderArea.lua")
print("[INIT]: Loading RenderArea: " .. tostring(func) .. " " .. tostring(err))
global.core.RenderArea = func(global)
local func, err = loadfile("data/core/GameObject.lua")
print("[INIT]: Loading GameObject: " .. tostring(func) .. " " .. tostring(err))
global.core.GameObject = func(global)
local func, err = loadfile("data/core/eventHandler.lua")
print("[INIT]: Loading eventHandler: " .. tostring(func) .. " " .. tostring(err))
global.core.eventHandler = func(global)

global.resX, global.resY = global.gpu.getResolution()

--=== debug ===--
global.ocl.open()
local func, err = loadfile("data/core/luaConsole.lua")
print("[INIT]: Loading luaConsole: " .. tostring(func) .. " " .. tostring(err))
func(global)

--=== load data ===--
do --load global data.
	print("[INIT]: Loading global.")
	local path = "/data/global"
	global.loadData(global, path, nil, print)
end

if global.isDev then
	local func, err = loadfile("data/core/dataLoading.lua")
	print("[INIT]: Check dataLoading: " .. tostring(func) .. " " .. tostring(err))
end
global.load({
	toLoad = {
		states = true,
		GameObject = true,
		RenderArea = true,
		eh = true,
	},
	print = global.orgPrint,
})

--===== init engine =====--
global.ge.init()
global.re.init()

global.changeState(global.conf.debug.defaultState)

--====== init end ======--
print("[INIT]: Done.")
return true