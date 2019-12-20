--===== Requires =====--
local component = require("component")
local computer = require("computer")
local shell = require("shell")
local event = require("event")
local term = require("term")
local serialization = require("serialization")
local gpu = component.gpu
local mainOcgl = dofile("libs/ocgl.lua").initiate(gpu)
local ocui = dofile("libs/ocui.lua").initiate(mainOcgl)

local db = require("libs/thirdParty/DoubleBuffering")
local dbgpu = loadfile(shell.getWorkingDirectory() .. "/libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})

local ocgl = dofile("libs/ocgl.lua").initiate(dbgpu, {checkColor = false})
--local ocgl = dofile("libs/ocgl.lua").initiate(gpu)
ocgl.name = "OCGL_1"

--===== Variables =====--
local consoleSizeY = 30

local orgPrint = print
--local texture = dofile("debug/benchmarkTexture.lua")
local texture = dofile("texturePacks/default/textures/grass.lua")
--local texture = dofile("debug/testTexture.lua")
local animation = dofile("debug/testAnimation.lua")
local background = dofile("texturePacks/default/textures/grass.lua")

local tbConsole = ocui.TextBox.new(ocui, {x=1, y=10, sx=0, sy=0, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})

local anim = ocgl.Animation.new(ocgl, animation, {})

local posX, posY = 10, 10

local logFile = "debug/tlog.log"

--===== Functions =====--
local function print(...)
	tbConsole:add(...)
	ocui:draw()
end
function cprint(...)
	tbConsole:add(...)
	ocui:draw()
end
function sprint(...)
	tbConsole:add(serialization.serialize(...))
	ocui:draw()
end
function lprint(...)
	local args = {...}
	local s = ""
	
	for i, c in pairs(args) do
		s = s .. "\t" .. tostring(c)
	end
	
	os.execute("echo " .. s .. " >> " .. logFile)
end

term.clear()
local resX, resY = gpu.getResolution()
tbConsole.sizeX = resX
tbConsole.sizeY = resY - (resY - consoleSizeY)
tbConsole.posY = resY - consoleSizeY
os.execute("echo Test start >" .. logFile)

--===== test start =====--
db.clear()
--ocgl:draw(10, 2, texture)
db.drawChanges(true)
local pTime = computer.uptime()




for i = 0, 20 do
	gpu.setBackground(0x000000)
	gpu.fill(0, 0, 100, 100, " ")
	
	
	--[[
	local x, y = 0, 0
	for i = 0, 1000 do
		db.set(10 +x, 3 +y, 0x333333, 0xaaaaaa, "T")
		db.set(10 +x, 4 +y, 0xaaaaaa, 0x333333, "T")
		if x > 50 then
			y = y +2
			x = 0
		end
		x = x +1
	end
	]]
	
	ocgl:draw(10, 2, texture)
	ocgl:draw(15 +i, 2, texture)
	
	--[[
	db.drawRectangle(10, 3, 6, 3, 0x441100, 0x501800, "#")
	db.set(10, 3, 0x005600, 0x003400, "/")
	db.set(11, 3, 0x005600, 0x003400, "/")
	db.set(12, 3, 0x005600, 0x003400, "/")
	db.set(13, 3, 0x005600, 0x003400, "/")
	db.set(14, 3, 0x005600, 0x003400, "/")
	db.set(15, 3, 0x005600, 0x003400, "/")
	]]
	--[[
	dbgpu.setBackground(0x441100)
	dbgpu.setForeground(0x501800)
	dbgpu.fill(10, 3, 6, 3, "#")
	dbgpu.setBackground(0x005600)
	dbgpu.setForeground(0x003400)
	dbgpu.set(10, 3, "//////")
	]]
	--[[
	dbgpu.set(11, 3, "/")
	dbgpu.set(12, 3, "/")
	dbgpu.set(13, 3, "/")
	dbgpu.set(14, 3, "/")
	dbgpu.set(15, 3, "/")
	]]
	
	db.drawChanges()
	os.sleep(.01)
	
	--[[
	--gpu.copy(10, 2, 24, 24, 30 +i, 0)
	dbgpu.copy(10, 2, 24, 24, 30 +i, 0)
	db.drawChanges()
	--ocgl:draw(10, 2, texture)
	--ocgl:draw(10, 2, texture)
	]]
end

db.drawChanges()



print(computer.uptime() - pTime)













