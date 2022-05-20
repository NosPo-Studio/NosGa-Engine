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

local global = ...

local luaShell = loadfile("libs/thirdParty/luaShell.lua")(global)
local lastAutoCompBase = ""

global.tbConsole = global.ocui.TextBox.new(global.ocui, {x=1, y=0, sx=global.resX, sy=global.resY - (global.resY - global.conf.consoleSizeY), lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333, managed = {draw = false}})
--global.setConsoleSize()

global.tiConsole = global.ocui.TextInput.new(global.ocui, {x = 6, y = global.resY, s = global.resX -5, 
	colors = {
		0xcccccc,
		0x333333,
		0xeeeeee,
		0x555555,
	},
	
	listedFunction = function(ti) 
		global.print("[LUA]> " .. ti.text)
		luaShell.textInput(ti.text)
	end,
	autoCompFunction = function(ti)
		if ti.autoCompBase ~= lastAutoCompBase then
			lastAutoCompBase = ti.autoCompBase
			ti.autoCompPos = 1
			
			local autoComp = luaShell.readHandler(ti.text, ti.cursorPosition + ti.stringPosition)
			
			if #autoComp == 1 then
				ti.autoCompBase = autoComp[1]
				lastAutoCompBase = ti.autoCompBase
			end
			
			ti.autoComplete = autoComp
		end
	end,
})

global.bConsolePlaceholder = global.ocui.Button.new(global.ocui, {x = 1, y = global.resY, sx = 0, sy = 0, texture0 = global.oclrl.generateTexture({
	{"b", 0x333333},
	{"f", 0xcccccc},
	{0, 0, "lua> "},
})})

global.mConsole = global.ocui.Menu.new(global.ocui, {x = 0, y = 0, managed = {update = false, draw = false}, c = {
	{global.tbConsole, 1, global.resY - global.conf.consoleSizeY}, 
	{global.tiConsole, 6, global.resY}, 
	{global.bConsolePlaceholder, 1,  global.resY},
}})


