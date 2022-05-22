--[[
    ocui Copyright (C) 2019 MisterNoNameLP.
	
    This library is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this library.  If not, see <https://www.gnu.org/licenses/>.
]]

local OCUI = {version = "v1.6.1"} --! not compatible to <= v1.5 !--
OCUI.__index = OCUI

--[[ToDo:
	add color check arg on draw calls.
	rework the initialisation routines (better args etc.).
	add dynamic ui generation (no texture).
]]--

local UT = require("libs/UT")
local xpcall = xpcall

function OCUI.initiate(oclrl, onError)
	local this = setmetatable({}, OCUI)
	this.event = require("event")
	this.oclrl = oclrl
	
	this.updateList = {} --list of managed buttons
	this.updateCount = 0
	this.drawList = {} --list of managed buttons
	this.drawCount = 0
	this.stopList = {}
	this.stopCount = 0
	
	this.globalStop = false --to avoid stopList cleaning by iterate it.
	
	this.onError = onError or function() end
	
	return this
end

function OCUI.stop(this) --dont ignor
	this.globalStop = true
	for c, v in ipairs(this.stopList) do
		if v ~= nil then
			v:stop()
		end
	end
	this.globalStop = false
end

function OCUI.update(this, x, y)
	for c, v in ipairs(this.updateList) do
		v:update(x, y)
	end
end

function OCUI.draw(this)
	for c, v in ipairs(this.drawList) do
		v:draw(x, y)
	end
end

function OCUI.listAutoManage(object, args) --ToDo: needs to work with value index instead of numeretic index.
	local managed = {}
	managed[1] = args.update
	managed[2] = args.draw
	managed[3] = args.stop
	
	if managed[1] or managed[1] == nil then
		object.ocui.updateCount = object.ocui.updateCount +1
		object.ocui.updateList[object.ocui.updateCount] = object
		object.updateListPos = object.ocui.updateCount
	end
	if managed[2] or managed[2] == nil then
		object.ocui.drawCount = object.ocui.drawCount +1
		object.ocui.drawList[object.ocui.drawCount] = object
		object.drawListPos = object.ocui.drawCount
	end
	if managed[3] or managed[3] == nil then
		object.ocui.stopCount = object.ocui.stopCount +1
		object.ocui.stopList[object.ocui.stopCount] = object
		object.stopListPos = object.ocui.stopCount
	end
end

function OCUI.ignoreAutoManage(object)
	if object.updateListPos ~= nil then
		table.remove(object.ocui.updateList, object.updateListPos)
		object.ocui.updateCount = object.ocui.updateCount -1
		for c = object.updateListPos, #object.ocui.updateList, 1 do
			object.ocui.updateList[c].updateListPos = object.ocui.updateList[c].updateListPos -1
		end
	end
	if object.drawListPos ~= nil then
		table.remove(object.ocui.drawList, object.drawListPos)
		object.ocui.drawCount = object.ocui.drawCount -1
		for c = object.drawListPos, #object.ocui.drawList, 1 do
			object.ocui.drawList[c].drawListPos = object.ocui.drawList[c].drawListPos -1
		end
	end
	if object.stopListPos ~= nil then
		if object.ocui.globalStop == false then
			table.remove(object.ocui.stopList, object.stopListPos)
			object.ocui.stopCount = object.ocui.stopCount -1
			for c = object.stopListPos, #object.ocui.stopList, 1 do
				object.ocui.stopList[c].stopListPos = object.ocui.stopList[c].stopListPos -1
			end
		end
	end
end

--===== Bar =====--
OCUI.Bar = {widgetType = "Bar"}
OCUI.Bar.__index = OCUI.Bar

function OCUI.Bar.new(ocui, args)
	local this = setmetatable({}, OCUI.Bar)
	
	args = args or {}
	
	this.posX = args.posX or args.x
	this.posY = args.posY or args.y
	this.sizeX = args.sizeX or args.sx
	this.sizeY = args.sizeY or args.sy
	this.status = math.min(args.status or 0, 1) --0 == empty, 1 == full.
	this.cfg_activeForegroundColor = args.activeForegroundColor or 0xaaaaaa
	this.cfg_activeBackgroundColor = args.activeBackgroundColor or 0x777777
	this.cfg_inactiveForegroundColor = args.inactiveForegroundColor or 0x888888
	this.cfg_inactiveBackgroundColor = args.inactiveBackgroundColor or 0x333333
	this.cfg_vertical = args.vertical or false
	this.cfg_foregroundChar = args.foregroundChar or " "
	this.cfg_backgroundChar = args.backgroundChar or " "
	this.clickable = args.clickable == true or args.clickable == nil
	
	this.ocui = ocui
	
	if this.clickable then
		this.button = ocui.Button.new(ocui, this.posX, this.posY, this.sizeX, this.sizeY, {
			managed = {update = false, draw = false},
			listedFunction = function(_, x, y)
				if this.cfg_vertical then
					this.status = math.min((y +1 - this.posY) / this.sizeY, 1)
				else
					this.status = math.min((x +1 - this.posX) / this.sizeX, 1)
				end
			end,
		})
	end
	
	if this.sizeX == nil or this.sizeY == nil then
		return false, "No sizeX or sizeY given"
	end
	if this.posX == nil or this.posY == nil then
		return false, "No posX or posY given"
	end
	
	if args.managed ~= nil then
		args.managed.update = false
	end
	ocui.listAutoManage(this, args.managed or {})
	
	return this
end

function OCUI.Bar.update(this, x, y)
	if this.clickable then
		this.button:update(x, y)
	end
end

function OCUI.Bar.draw(this)
	local gpu = this.ocui.oclrl.gpu
	
	gpu.setForeground(this.cfg_inactiveForegroundColor)
	gpu.setBackground(this.cfg_inactiveBackgroundColor)
	
	gpu.fill(this.posX, this.posY, this.sizeX, this.sizeY, this.cfg_backgroundChar)
	
	gpu.setForeground(this.cfg_activeForegroundColor)
	gpu.setBackground(this.cfg_activeBackgroundColor)
	if this.cfg_vertical then
		gpu.fill(this.posX, this.posY, this.sizeX, math.floor(this.sizeY * this.status +.5), this.cfg_foregroundChar)
	else
		gpu.fill(this.posX, this.posY, math.floor(this.sizeX * this.status +.5), this.sizeY, this.cfg_foregroundChar)
	end
end

function OCUI.Bar.setStatus(this, status)
	this.status = math.min(status, 1)
end

function OCUI.Bar.getStatus(this)
	return this.status
end

function OCUI.Bar.move(this, x, y)
	this.posX, this.posY = x, y
end

function OCUI.Bar.stop(this)	
	this.ocui.ignoreAutoManage(this)
end

--===== TextBox =====--
OCUI.TextBox = {widgetType = "TextBox"}
OCUI.TextBox.__index = OCUI.TextBox

function OCUI.TextBox.new(ocui, args)
	local this = setmetatable({}, OCUI.TextBox)
	
	args = args or {}
	
	this.posX = args.posX or args.x
	this.posY = args.posY or args.y
	this.sizeX = args.sizeX or args.sx
	this.sizeY = args.sizeY or args.sy
	this.lineBreak = args.lineBreak or false
	this.cfg_foregroundColor = args.foregroundColor or 0xaaaaaa
	this.cfg_backgroundColor = args.backgroundColor or 0x555555
	this.content = {}
	OCUI.TextBox.addContent(this, OCUI.TextBox.getContent(this, args.content, args.sizeX, this.lineBreak))
	--[[ or OCUI.TextBox.getContent(
		{args.text or ""},
		args.sizeX,
		args.lineBreak or false
	)]]
	
	this.ocui = ocui
	
	if this.sizeX == nil or this.sizeY == nil then
		return false, "No sizeX or sizeY given"
	end
	if this.posX == nil or this.posY == nil then
		return false, "No posX or posY given"
	end
	
	if args.managed ~= nil then
		args.managed.update = false
	end
	ocui.listAutoManage(this, args.managed or {update = false})
	
	return this
end

function OCUI.TextBox.getContent(this, text, length, lineBreak)
	local content = {}
	local index = 1
	if type(text) ~= "table" then
		text = {text}
	end
	for _, t in ipairs(text) do
		
		for s in string.gmatch(tostring(t), "[^\r\n]+") do
			s = string.gsub(s, "\t", "     ")
			
			if #s > length then
				if lineBreak then
					table.insert(text, #text +1, string.sub(s, length))
				end
				s = string.sub(s, 0, length)
			end
			
			content[index] = UT.fillString(s, length - #s, " ")
			index = index +1
		end
	end
	
	return content
end

function OCUI.TextBox.addContent(this, content)
	for _, c in ipairs(content) do
		
		for s in string.gmatch(tostring(c), "[^\r\n]+") do
			s = string.gsub(s, "\t", "     ")
			--table.insert(this.content, s)
		end
		table.insert(this.content, c)
	end
	if #this.content > this.sizeY then
		local tmpContent = {}
		for c = #this.content -this.sizeY +1, #this.content do
			table.insert(tmpContent, this.content[c])
		end
		this.content = tmpContent
	end
end

function OCUI.TextBox.add(this, ...)
	local text = ""
	for _, s in ipairs({...}) do
		text = text .. tostring(s) .. "     "
	end
	this:addContent(this:getContent({text}, this.sizeX, this.lineBreak))
end

function OCUI.TextBox.update(this, ...)	
	
end

function OCUI.TextBox.draw(this)
	local gpu = this.ocui.oclrl.gpu
	
	gpu.setForeground(this.cfg_foregroundColor)
	gpu.setBackground(this.cfg_backgroundColor)
	
	if #this.content < this.sizeY then
		gpu.fill(this.posX, this.posY, this.sizeX, this.sizeY, " ")
	end
	
	for c, t in ipairs(this.content) do
		gpu.set(this.posX, this.posY +c -1, t)
	end
end

function OCUI.TextBox.move(this, x, y)
	this.posX, this.posY = x, y
end

function OCUI.TextBox.stop(this)	
	this.ocui.ignoreAutoManage(this)
end


--===== Menu =====--
OCUI.Menu = {widgetType = "menu"}
OCUI.Menu.__index = OCUI.Menu

function OCUI.Menu.new(ocui, args)--posX == [int], posY == [int], content == [numTable], {backgroundTexture == [OCGLTexture], managed == [{update == [bool], draw == [bool], stop == [bool]}]}
	local this = setmetatable({}, OCUI.Menu)
	this.thread = require("thread")
	this.event = require("event")
	this.ocui = ocui
	this.posX = UT.parseArgs(args.x, args.posX)
	this.posY = UT.parseArgs(args.y, args.posY)
	this.content = {}
	this.backgroundTexture = args.backgroundTexture
	this.status = true
	this.markedPos = 0
	this.markingList = {}
	this.internOCUI = ocui.initiate(ocui.oclrl)
	this.inputThread = this.thread.create(function() end)
	
	this.cfg_inputMap = {next = {15}}
	
	this:add(UT.parseArgs(args.c, args.content))
	ocui.listAutoManage(this, args.managed or {})
	
	return this
end

function OCUI.Menu.activate(this)
	for c, v in ipairs(this.markingList) do
		v:activate()
	end
end

function OCUI.Menu.deactivate(this)
	for c, v in ipairs(this.markingList) do
		v:deactivate()
	end
end

function OCUI.Menu.inputManager(this)
	while this.status and this.markingList[this.markedPos].status do
		local _, _, key, code = this.event.pull("key_down")
		if UT.inputCheck(this.cfg_inputMap.next, code) then
			this:next()
		end
	end
end

function OCUI.Menu.add(this, content)
	for c, v in ipairs(content) do
		v[1]:stop()
		v[1]:move(this.posX +v[2], this.posY +v[3])
		
		if UT.inputCheck({"textInput", "list"}, v[1].widgetType) then --WIP
			table.insert(this.markingList, v[1])
			local mp = #this.markingList
			local oldFunction = v[1].update
			
			v[1].update = function(this2, x, y) 
				oldFunction(this2, x, y)
				if this2.status then 
					this.markedPos = mp
				end 
			end
			
			if v[1].widgetType == "textInput" then
				for c2, v2 in ipairs(this.cfg_inputMap.next) do
					table.insert(v[1].cfg_inputMap.forbidden, v2)
				end
			end
		end
		
		v[1].ocui = this.internOCUI
		this.internOCUI.listAutoManage(v[1], {})
		table.insert(this.content, v)
	end
end

function OCUI.Menu.next(this) --WIP
	if this.status and this.markingList[this.markedPos].status then
		if this.markedPos == #this.markingList then
			this.markedPos = 0
		end
		if this.markingList[this.markedPos +1].widgetType == "textInput" then
			this.internOCUI:update(this.markingList[this.markedPos +1].posX +this.markingList[this.markedPos +1].size -1, this.markingList[this.markedPos +1].posY)
		elseif this.markingList[this.markedPos +1].widgetType == "list" then
			this.markingList[this.markedPos +1].pClickTime = 0
			if this.markingList[this.markedPos +1].upButton == nil then
				this.internOCUI:update(this.markingList[this.markedPos +1].posX, this.markingList[this.markedPos +1].posY +this.markingList[this.markedPos +1].markedPosition -1)
			else
				this.internOCUI:update(this.markingList[this.markedPos +1].posX, this.markingList[this.markedPos +1].posY +this.markingList[this.markedPos +1].markedPosition)
			end
		end
	end
end

function OCUI.Menu.move(this, x, y)
	this.posX, this.posY = x, y
	for c, v in ipairs(this.content) do
		v[1]:move(this.posX +v[2], this.posY +v[3])
	end
end

function OCUI.Menu.update(this, x, y)
	if this.status then
		this.internOCUI:update(x, y)
		if this.inputThread:status() ~= "running" then
			this.inputThread = this.thread.create(this.inputManager, this)
		end
	end
end

function OCUI.Menu.draw(this)
	if this.status then
		if this.backgroundTexture ~= nil then
			this.ocui.oclrl:draw(this.posX, this.posY, this.backgroundTexture)
		end
		this.internOCUI:draw()
	end
end

function OCUI.Menu.stop(this)
	this.ocui.ignoreAutoManage(this)
	this.internOCUI:stop()
	this.inputThread:kill()
end

--===== List =====--
OCUI.List = {widgetType = "list"}
OCUI.List.__index = OCUI.List

function OCUI.List.new(ocui, args) --posX == [int], posY == [int], sizeX == [int], sizeY == [int], content == [numTable], {colors == [numTable], listedFunction == [function()], config == [table], managed == [{update == [bool], draw == [bool], stop == [bool]}]}

	local this = setmetatable({}, OCUI.List)
	this.computer = require("computer")
	this.event = require("event")
	this.thread = require("thread") 
	this.listedFunction = args.listedFunction or function() end
	this.ocui = ocui
	this.posX = UT.parseArgs(args.x, args.posX)
	this.posY = UT.parseArgs(args.y, args.posY)
	this.sizeX = UT.parseArgs(args.sx, args.sizeX)
	this.sizeY = UT.parseArgs(args.sy, args.sizeY)
	
	args.colors = args.colors or {}
	this.cfg_normalForegroundColor = args.colors[1] or 0xaaaaaa
	this.cfg_normalBackgroundColor = args.colors[2] or 0x555555
	this.cfg_clickedForegroundColor = args.colors[3] or 0xffffff
	this.cfg_clickedBackgroundColor = args.colors[4] or 0xaaaaaa
	
	this.cfg_inputMap = {up = {200}, down = {208}, enter = {28}, pos1 = {199}, endKey = {207}}
	config = args.config or {}
	this.cfg_pingByEveryClick = config[1] or false
	this.cfg_doubleClickTime = config[2] or .5
	
	this.status = false
	this.tmpStatus = false
	this.markedPosition = 1
	this.pClickPos = 1
	this.pClickTime = 0
	this.content = UT.parseArgs(args.content, {})
	this.internOCUI = ocui.initiate(ocui.oclrl, this.ocui.onError)
	this.buttons = {}
	this.inputThread = this.thread.create(function() end)
	this.backgroundTexture = ocui.oclrl.generateTexture({this.cfg_normalForegroundColor, this.cfg_normalBackgroundColor, this.sizeX, this.sizeY, " "})
	this.listButton = this.ocui.Button.new(this.internOCUI, this.posX, this.posY, this.sizeX, this.sizeY, {listedFunction = function() 
		this.status = true 
		this.tmpStatus = true 
		if this.inputThread:status() ~= "running" then
			this.inputThread = this.thread.create(this.inputManager, this)
		end
	end})
	
	--ButtonGenerating {
	this.scrollPos = nil
	this.buttonCount = 0
	
	local buttonStartPos = 0
	
	if #this.content > this.sizeY then
		this.buttonCount = this.sizeY -2
		this.scrollPos = 0
		buttonStartPos = 1
		
		local function ScrollContent()
			for c, v in ipairs(this.buttons) do
				v.texture0 = ocui.oclrl.generateTexture({this.cfg_normalForegroundColor, this.cfg_normalBackgroundColor, UT.fillString(this.content[this.scrollPos +c], this.sizeX - #this.content[this.scrollPos +c], " ")})
				v.texture1 = ocui.oclrl.generateTexture({this.cfg_clickedForegroundColor, this.cfg_clickedBackgroundColor, UT.fillString(this.content[this.scrollPos +c], this.sizeX - #this.content[this.scrollPos +c], " ")})
			end
		end
		this.upButton = this.internOCUI.Button.new(this.internOCUI, this.posX, this.posY, this.sizeX, 1, {texture0 = this.ocui.oclrl.generateTexture({this.cfg_normalForegroundColor, this.cfg_normalBackgroundColor, "^"}), texture1 = this.ocui.oclrl.generateTexture({this.cfg_clickedForegroundColor, this.cfg_clickedBackgroundColor, UT.fillString("^", this.sizeX -1, " ")}), listedFunction = function(_)
			if this.scrollPos > 0 then
				this.scrollPos = this.scrollPos -1
				ScrollContent()
			end
		end})
		this.downButton = this.internOCUI.Button.new(this.internOCUI, this.posX, this.posY +this.sizeY -1, this.sizeX, 1, {texture0 = this.ocui.oclrl.generateTexture({this.cfg_normalForegroundColor, this.cfg_normalBackgroundColor, "v"}), texture1 = this.ocui.oclrl.generateTexture({this.cfg_clickedForegroundColor, this.cfg_clickedBackgroundColor, UT.fillString("v", this.sizeX -1, " ")}), listedFunction = function(_)
			if this.scrollPos < this.sizeY -2 then
				this.scrollPos = this.scrollPos +1
				ScrollContent()
			end
		end})
	else
		this.buttonCount = #this.content
	end
	
	for c = 1, this.buttonCount, 1 do
		this.buttons[c] = this.internOCUI.Button.new(this.internOCUI, this.posX, this.posY +c -1 +buttonStartPos, this.sizeX, 1, {texture0 = this.ocui.oclrl.generateTexture({this.cfg_normalForegroundColor, this.cfg_normalBackgroundColor, UT.fillString(this.content[c], this.sizeX - #this.content[c], " ")}), texture1 = this.ocui.oclrl.generateTexture({this.cfg_clickedForegroundColor, this.cfg_clickedBackgroundColor, UT.fillString(this.content[c], this.sizeX - #this.content[c], " ")}), listedFunction = function(_) 
			if this.computer.uptime() - this.pClickTime < this.cfg_doubleClickTime and this.pClickPos == c or this.cfg_doubleClickTime == -1 then
				this:buttonPress(c, true)
			else
				this.buttons[this.pClickPos].status = false
				this.buttons[c].status = true
				if this.cfg_pingByEveryClick then
					this:buttonPress(c, false)
				end
			end
			this.pClickTime = this.computer.uptime()
			this.pClickPos = c
			this.markedPosition = c
		end})
		if this.cfg_doubleClickTime ~= -1 then
			this.buttons[c].cfg_clickTime = -1
		end
	end
	--}
	
	ocui.listAutoManage(this, managed or {})
	
	return this
end

function OCUI.List.activate(this)
	this.pClickTime = 0
	if this.upButton ~= nil then
		this:update(this.posX, this.posY +this.markedPosition)
	else
		this:update(this.posX, this.posY)
	end
end

function OCUI.List.deactivate(this)
	this:update(-1, this.posY -1)
end

function OCUI.List.inputManager(this)
	local m = this.cfg_inputMap
	while this.cfg_doubleClickTime ~= -1 and this.status do
		local eventType, _, key, code, direction = this.event.pull()
		if eventType == "key_down" then
			if UT.inputCheck(m.enter, code) then
				this.pClickTime = this.computer.uptime()
				this.buttons[this.markedPosition]:listedFunction()
			elseif UT.inputCheck(m.pos1, code) then
				if this.scrollPos ~= nil then
					this.scrollPos = 1
					this.upButton:listedFunction()
				end
				this.buttons[1]:listedFunction()
			elseif UT.inputCheck(m.endKey, code) then
				if this.scrollPos ~= nil then
					this.scrollPos = #this.content - this.buttonCount -1
					this.downButton:listedFunction()
				end
				this.buttons[this.buttonCount]:listedFunction()
			elseif UT.inputCheck(m.up, code) then
				if this.markedPosition > 1 then
					this.buttons[this.markedPosition -1]:listedFunction()
				elseif this.scrollPos ~= nil then
					this.upButton:listedFunction()
				end
			elseif UT.inputCheck(m.down, code) then
				if this.markedPosition < this.buttonCount then
					this.buttons[this.markedPosition +1]:listedFunction()
				elseif this.scrollPos ~= nil then
					this.downButton:listedFunction()
				end
			end
		elseif eventType == "scroll" then
			if this.scrollPos ~= nil and direction == 1 then
				this.upButton:listedFunction()
			elseif this.scrollPos ~= nil and direction == -1 then
				this.downButton:listedFunction()
			end
		end
	end
end

function OCUI.List.buttonPress(this, pos, isDoubleClicked)
	if this.scrollPos == nil then
		this:listedFunction(this.content[pos], pos, isDoubleClicked, pos)
	else
		this:listedFunction(this.content[pos +this.scrollPos], pos +this.scrollPos, isDoubleClicked, pos)
	end
end

function OCUI.List.update(this, x, y)	
	this.internOCUI:update(x, y)
	if this.tmpStatus == false and #this.buttons > 0 then
		this.status = false
		this.buttons[this.markedPosition].status = false
		if this.inputThread.status ~= nil then
			this.inputThread:kill()
		end
	elseif #this.buttons > 0 then
		this.buttons[this.markedPosition].status = true
	end
	this.tmpStatus = false
end

function OCUI.List.draw(this)
	this.ocui.oclrl:draw(this.posX, this.posY, this.backgroundTexture)
	this.internOCUI:draw()
end

function OCUI.List.move(this, x, y)
	this.posX, this.posY = x, y
	this.listButton:move(x, y)
	if this.upButton ~= nil then
		this.upButton:move(x, y)
		this.downButton:move(x, y +this.sizeY -1)
		for c, v in ipairs(this.buttons) do
			v:move(x, y +c)
		end
	else
		for c, v in ipairs(this.buttons) do
			v:move(x, y +c -1)
		end
	end
end

function OCUI.List.stop(this)
	this.inputThread:kill()
	
	this.ocui.ignoreAutoManage(this)
end



--===== TextInput =====--
OCUI.TextInput = {widgetType = "textInput"}
OCUI.TextInput.__index = OCUI.TextInput

function OCUI.TextInput.new(ocui, args) --posX == [int], posY == [int], size == [int], args == {colors == [numTable], listedFunction == [function()], managed == [{update == [bool], draw == [bool], stop == [bool]}]}

	local this = setmetatable({}, OCUI.TextInput)
	this.computer = require("computer")
	this.event = require("event")
	this.thread = require("thread") 
	this.ocui = ocui
	this.posX = UT.parseArgs(args.x, args.posX)
	this.posY = UT.parseArgs(args.y, args.posY)
	this.size = UT.parseArgs(args.s, args.size)
	this.listedFunction = args.listedFunction or function() end
	this.autoCompFunction = args.autoCompFunction or function() end
	
	args.colors = args.colors or {}
	this.cfg_normalForegroundColor = args.colors[1] or 0xaaaaaa
	this.cfg_normalBackgroundColor = args.colors[2] or 0x555555
	this.cfg_clickedForegroundColor = args.colors[3] or 0xffffff
	this.cfg_clickedBackgroundColor = args.colors[4] or 0xaaaaaa
	this.cfg_cursorForegroundColor = args.colors[5] or 0x444444
	this.cfg_cursorBackgroundColor = args.colors[6] or 0xffffff
	
	this.cfg_showCursor = true
	this.cfg_cursorBlinkTime = .5
	this.cfg_keepText = false
	this.cfg_maxHistoryLength = -1
	this.cfg_hiddenText = args.hiddenText or false
	
	this.cfg_inputMap = {back = {14}, left = {203}, right = {205}, up = {200}, down = {208}, enter = {28}, pos1 = {199}, endKey = {207}, del = {211}, autoComplete = {15}, forbidden = {}, allowed = {}}
	
	this.autoComplete = args.autoComplete or {}
	
	this.status = false
	this.text = ""
	this.stringPosition = 0
	this.cursorPosition = 1
	this.cursorPTime = 0
	this.history = {}
	this.historyPosition = -1
	this.userInput = ""
	this.autoCompBase = "" --for auto complete
	this.autoCompPos = 1
	
	this.inputThread = this.thread.create(function() end)
	
	ocui.listAutoManage(this, args.managed or {})
	
	return this
end

function OCUI.TextInput.activate(this) 
	this:update(this.posX +this.size -1, this.posY)
end

function OCUI.TextInput.deactivate(this)
	this:update(-1, this.posY -1)
end

function OCUI.TextInput.inputManager(this)
	local inputCheck = UT.inputCheck
	local function MoveCursor(c)
		if 0 +c > 0 then
			if this.cursorPosition +c > this.size and #this.text -this.stringPosition >= this.size then
				this.stringPosition = this.stringPosition +(c - (this.size - this.cursorPosition))
				this.cursorPosition = this.size
			elseif this.cursorPosition < this.size and this.cursorPosition <= #this.text then
				this.cursorPosition = this.cursorPosition +c
			end
		else
			if this.cursorPosition +c < 1 and this.stringPosition > 0 then
				this.stringPosition = this.stringPosition +c
				this.cursorPosition = 1
			elseif this.cursorPosition > 1 then
				this.cursorPosition = this.cursorPosition +c
			end
		end
	end
	local function RSC() --reset cursor
		this.cursorPosition = 1
		this.stringPosition = 0
	end
	local m = this.cfg_inputMap
	
	while this.status do
		local _, _, key, code = this.event.pull("key_down")
		this.cursorPTime = this.computer.uptime()
		if key ~= nil then			
			if inputCheck(m.enter, code) then
				if #this.history >= this.cfg_maxHistoryLength and this.cfg_maxHistoryLength ~= -1 and this.cfg_maxHistoryLength ~= 0 then
					for c = 1, this.cfg_maxHistoryLength, 1 do
						this.history[c] = this.history[c +1]
					end
					this.history[this.cfg_maxHistoryLength] = this.text
				elseif this.cfg_maxHistoryLength ~= 0 then
					table.insert(this.history, this.text)
				end
				this.historyPosition = -1
				local success, errorMsg = xpcall(this.listedFunction, debug.traceback, this)
				if success == false then
					this.ocui.onError(this, errorMsg)
				end
				if this.cfg_keepText == false then
					this.text = ""
					this.autoCompBase = this.text
					RSC()
				end
			elseif inputCheck(m.left, code) then
				MoveCursor(-1)
			elseif inputCheck(m.right, code) then
				MoveCursor(1)
			elseif inputCheck(m.pos1, code) then
				RSC()
			elseif inputCheck(m.endKey, code) then
				RSC()
				MoveCursor(#this.text)
			elseif inputCheck(m.back, code) then
				if #this.text > 0 and this.cursorPosition > 1 then
					local ct = UT.getChars(this.text)
					table.remove(ct, this.cursorPosition + this.stringPosition -1)
					this.text = UT.makeString(ct)
					if #this.text >= this.size -1 then
						this.stringPosition = this.stringPosition -1
					else
						MoveCursor(-1)
					end
					this.autoCompBase = this.text
				end
			elseif inputCheck(m.del, code) then
				if #this.text - (this.cursorPosition + this.stringPosition) >= 0 then
					local ct = UT.getChars(this.text)
					table.remove(ct, this.cursorPosition + this.stringPosition)
					this.text = UT.makeString(ct)
					this.autoCompBase = this.text
				end
			elseif inputCheck(m.up, code) then
				if this.historyPosition == -1 and this.cfg_maxHistoryLength ~= 0 and #this.history > 0 then
					this.userInput = this.text
					this.historyPosition = #this.history
					this.text = this.history[this.historyPosition]
				elseif this.historyPosition > 1 then
					this.historyPosition = this.historyPosition -1
					this.text = this.history[this.historyPosition]
				end
				RSC()
				MoveCursor(#this.text)
				this.autoCompBase = this.text
			elseif inputCheck(m.down, code) then
				if this.historyPosition < #this.history and this.historyPosition ~= -1 then
					this.historyPosition = this.historyPosition +1
					this.text = this.history[this.historyPosition]
				elseif #this.history > 0 then
					this.historyPosition = -1
					this.text = this.userInput
				end
				RSC()
				MoveCursor(#this.text)
				this.autoCompBase = this.text
			elseif inputCheck(m.autoComplete, code) then
				local clear = true
				
				local success, errorMsg = xpcall(this.autoCompFunction, debug.traceback, this)
				if success == false then
					this.ocui.onError(this, errorMsg)
				end
				
				if this.autoCompBase ~= string.sub(this.text, 0, #this.autoCompBase) or this.autoCompBase == "" then
					this.autoCompBase = this.text
				end
				for i = this.autoCompPos, #this.autoComplete do
					this.autoCompPos = i +1
					--print(string.sub(this.autoComplete[i], 0, #this.autoCompBase))
					if this.autoCompBase == string.sub(this.autoComplete[i], 0, #this.autoCompBase) then
						this.text = this.autoComplete[i]
						clear = false
						break
					end
				end
				if this.autoCompPos > #this.autoComplete and clear and #this.autoComplete > 0 then
					this.autoCompPos = 1
					this.text = this.autoCompBase
				end
				RSC()
				MoveCursor(#this.text)
			elseif key ~= 0 and inputCheck(m.forbidden, code) == false and #m.allowed == 0 or inputCheck(m.allowed, code) then
				--this.text = this.text .. string.char(key)
				local ct = UT.getChars(this.text)
				table.insert(ct, this.cursorPosition +this.stringPosition, string.char(key))
				this.text = UT.makeString(ct)
				this.cursorPTime = this.computer.uptime()
				MoveCursor(1)
				this.autoCompBase = this.text
			end
		end
	end
end

function OCUI.TextInput.update(this, x, y)	
	if x > this.posX -1 and x < this.posX + this.size and
		y > this.posY -1 and y < this.posY + 1
	then
		this.status = true
		if this.inputThread:status() ~= "running" then
			this.inputThread = this.thread.create(this.inputManager, this)
			this.inputThread:detach()
			this.ocui.stopList[this.stopListPos] = this
		end
		if x - this.posX > #this.text - this.stringPosition then
			this.cursorPosition = #this.text - this.stringPosition +1
		else
			this.cursorPosition = x - this.posX +1
		end
	else 
		this.status = false
		this.inputThread:kill()
	end
end

function OCUI.TextInput.draw(this)
	local function generateTexture(t)
		return {textureFormat = "OCGLT", version = "v0.1", drawCalls = {{"f", t[1]}, {"b", t[2]}, {0, 0, t[3]}}}
	end
	local text = this.text
	if this.cfg_hiddenText then
		text = UT.fillString("", #this.text, "*")
	end
	
	for c = #this.text, this.size -1, 1 do
		text = text .. " "
	end
	if #this.text > this.size -1 then
		local tm = #this.text - (this.size -1)
		tm = tm - this.stringPosition 
		if tm > 0 then
			text = string.sub(this.text, this.stringPosition +1, -tm)
		else
			text = string.sub(this.text, this.stringPosition +1)
			text = text .. " "
		end
	end
	
	if this.status then
		this.ocui.oclrl:draw(this.posX, this.posY, generateTexture({this.cfg_clickedForegroundColor, this.cfg_clickedBackgroundColor, text}))
		local dt = this.computer.uptime() - this.cursorPTime
		if this.cfg_showCursor and dt < this.cfg_cursorBlinkTime then
			this.ocui.oclrl:draw(this.posX +this.cursorPosition -1, this.posY, generateTexture({this.cfg_cursorForegroundColor, this.cfg_cursorBackgroundColor, string.sub(text, this.cursorPosition, this.cursorPosition)}))
		elseif dt > this.cfg_cursorBlinkTime *2 then
			this.cursorPTime = this.computer.uptime()
		end
	else
		this.ocui.oclrl:draw(this.posX, this.posY, generateTexture({this.cfg_normalForegroundColor, this.cfg_normalBackgroundColor, text}))
	end
end

function OCUI.TextInput.move(this, x, y)
	this.posX, this.posY = x, y
end

function OCUI.TextInput.stop(this)
	this.inputThread:kill()
	
	this.ocui.ignoreAutoManage(this)
end



--===== Button/Switch =====--
OCUI.Button = {widgetType = "button"}
OCUI.Button.__index = OCUI.Button

function OCUI.Button.new(ocui, args) --posX == [int], posY == [int], sizeX == [int], sizeY == [int], args == {listedFunction == [function()], managed == [{update == [bool], draw == [bool]}]}

	local this = setmetatable({}, OCUI.Button)
	this.computer = require("computer")
	this.ocui = ocui
	this.posX = UT.parseArgs(args.x, args.posX)
	this.posY = UT.parseArgs(args.y, args.posY)
	this.sizeX = UT.parseArgs(args.sx, args.sizeX)
	this.sizeY = UT.parseArgs(args.sy, args.sizeY)
	this.listedFunction = UT.parseArgs(args.lf, args.listedFunction, function() end)
	
	args.textures = args.textures or {}
	this.texture0 = UT.parseArgs(args.texture0, args.textures[1], ocui.oclrl.generateTexture({}))
	this.texture1 = UT.parseArgs(args.texture1, args.textures[2], ocui.oclrl.generateTexture({}))
	
	this.cfg_clickTime = UT.parseArgs(args.ct, args.clickTime, .3) --Time the button have to be the clicked texture. If this -1 the button is a switch.
	this.clickTime = 0 --Time the button was clicked.
	this.status = false
	
	ocui.listAutoManage(this, args.managed or {})
	
	return this
end

function OCUI.Button.update(this, x, y)	
	if x > this.posX -1 and x < this.posX + this.sizeX and
		y > this.posY -1 and y < this.posY + this.sizeY
	then
		if this.cfg_clickTime ~= -1 then
			this.clickTime = this.computer.uptime()
			this.status = true
		else
			if this.status then
				this.status = false
			else
				this.status = true
			end
		end
		local success, errorMsg = xpcall(this.listedFunction, debug.traceback, this, x, y)
		if success == false then
			this.ocui.onError(this, errorMsg)
		end
	end
end

function OCUI.Button.draw(this)
	local dt = -2
	if this.cfg_clickTime ~= -1 then
		dt = this.computer.uptime() - this.clickTime
	end
	
	if this.status and dt < this.cfg_clickTime then
		this.ocui.oclrl:draw(this.posX, this.posY, this.texture1)
	else
		this.ocui.oclrl:draw(this.posX, this.posY, this.texture0)
		this.status = false
	end
end

function OCUI.Button.move(this, x, y)
	this.posX, this.posY = x, y
end

function OCUI.Button.stop(this)	
	this.ocui.ignoreAutoManage(this)
end

return OCUI
