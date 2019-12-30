local global = ...

local luaShell = loadfile("libs/thirdParty/luaShell.lua")(global)
local lastAutoCompBase = ""

global.tbConsole = global.ocui.TextBox.new(global.ocui, {x=1, y=0, sx=0, sy=0, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333, managed = {draw = false}})
global.setConsoleSize()

global.tiConsole = global.ocui.TextInput.new(global.ocui, 6, global.resY, global.resX -5, {
	colors = {
		0xcccccc,
		0x333333,
		0xeeeeee,
		0x555555,
	},
	
	listedFunction = function(ti) 
		global.log("lua> " .. ti.text)
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

global.bConsolePlaceholder = global.ocui.Button.new(global.ocui, 1, global.resY, 0, 0, {texture0 = global.oclrl.generateTexture({
	{"b", 0x333333},
	{"f", 0xcccccc},
	{0, 0, "lua> "},
})})