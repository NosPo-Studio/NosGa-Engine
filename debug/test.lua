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

local ocgl = dofile("libs/ocgl.lua").initiate(gpu)
ocgl.name = "OCGL_1"

--===== Variables =====--
local consoleSizeY = 20

local orgPrint = print
local texture = dofile("debug/benchmarkTexture.lua")
local animation = dofile("debug/testAnimation.lua")
local background = dofile("texturePacks/default/textures/grass.lua")

local tbConsole = ocui.TextBox.new(ocui, {x=1, y=10, sx=0, sy=0, lineBreak = true, foregroundColor=0xcccccc, backgroundColor=0x333333})

local anim = ocgl.Animation.new(ocgl, animation, {})

local posX, posY = 10, 10

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

gpu.setBackground(0x000000)
term.clear()
local resX, resY = gpu.getResolution()
tbConsole.sizeX = resX
tbConsole.sizeY = resY - (resY - consoleSizeY)
tbConsole.posY = resY - consoleSizeY


--===== test start =====--
--db.clear()
--db.drawChanges(true)

local function copy(x, y, sx, sy, tx, ty)
	local fromX, toX, fromY, toY = 13, 28, 13, 28 --real fov
	local ax, ay, asx, asy, atx, aty = x, y, sx, sy, tx, ty
	local x1, y1, x2, y2 = x, y, x + sx -1, y + sy -1
	
	fromX = fromX - math.min(tx, 0)
	fromY = fromY - math.min(ty, 0)
	toX = toX - math.max(tx, 0)
	toY = toY - math.max(ty, 0)
	
	--print(x1, y1, x2, y2, "|", fromX, fromY, toX, toY)
	
	x1 = math.max(x1, fromX)
	y1 = math.max(y1, fromY)
	x2 = math.min(x2, toX)
	y2 = math.min(y2, toY)
	
	ax = x1
	ay = y1
	asx = x2 - x1
	asy = y2 - y1
	
	
	gpu.fill(ax, ay, asx, asy, "#")
	gpu.setBackground(0x33aa94)
	gpu.set(x1, y1, "1")
	gpu.set(x2, y2, "2")
	
	
	if false then
		gpu.setBackground(0xcc7994)
		gpu.set(fromX, fromY, "C")
		gpu.set(toX, fromY, "C")
		gpu.set(fromX, toY, "C")
		gpu.set(toX, toY, "C")
	end
	if true then
		local fromX, toX, fromY, toY = 13, 28, 13, 28 --real fov
		gpu.setBackground(0xFF69B4)
		gpu.set(fromX, fromY, "R")
		gpu.set(toX, fromY, "R")
		gpu.set(fromX, toY, "R")
		gpu.set(toX, toY, "R")
	end
end

copy(10, 10, 30, 25, -20, 3)


while true do
	local _, _, key = event.pull("key_down")
	if key == 3 then --ctrl+c
		break
	end
end





