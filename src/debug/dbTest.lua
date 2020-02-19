local computer = require("computer")
local term = require("term")
package.loaded["libs/thirdParty/DoubleBuffering"] = nil
local db = require("libs/thirdParty/DoubleBuffering")
local image = require("libs/thirdParty/image")
local texture = image.load("texturePacks/default/textures/test.pic")
local component = require("component")
local gpu = component.gpu
local shell = require("shell")

package.loaded["libs/dbgpu_api"] = nil

local dbgpu = loadfile(shell.getWorkingDirectory() .. "/libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})

local chars = "▀▄█"

term.clear()
db.drawRectangle(1, 1, 1000, 1000, 0x000000, 0x000000, " ")
db.drawChanges()


if true then
	dbgpu.setBackground(0x000000)
	dbgpu.setForeground(0xaaaaaa)
	dbgpu.set(10, 10, chars)
	dbgpu.set(10, 12, chars)
	dbgpu.set(10, 14, chars)
end

--local pd, rpd = db.copy(8, 8, 10, 10)
--db.paste(20, 10, pd)

--db.directCopy(8, 8, 10, 10, 20, 10)


--[[
	befor:
		with paste == ~ 3.2
		without paste == ~ 2.7
	after == 
]]

local ptime = computer.uptime()

for c = 0, 100 do
	--local cd, rcd = db.copy(5, 5, 100, 60, true)
	--db.paste(10, 10, cd, rdc)
	
	db.directCopy(5, 5, 100, 60, 10, 10, true)
end

db.drawChanges()

gpu.setForeground(0xaaaaaa)

print()
print()

print(db.getIndex(50, 0))
print(computer.uptime() -ptime)