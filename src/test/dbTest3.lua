local computer = require("computer")
local term = require("term")
package.loaded["libs/thirdParty/DoubleBuffering"] = nil
local db = require("libs/thirdParty/DoubleBuffering")
local image = require("libs/thirdParty/image")
local texture = image.load("texturePacks/default/textures/pipipu.pic")
local component = require("component")
local gpu = component.gpu
local shell = require("shell")

package.loaded["libs/dbgpu_api"] = nil

local dbgpu = loadfile(shell.getWorkingDirectory() .. "/libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true, actualRawCopy = false})

local chars = "▀▄█"
local tt = image.load("texturePacks/default/textures/ttest.pic")

local function makeImageTransparent(image, color) --only working with OCIF6 optimized dithering using images.
	for i = 1, #image[3] do
		if image[3][i] == color and image[4][i] == color then
			image[5][i] = 2
		elseif image[3][i] == color then
			image[5][i] = 1
		elseif image[4][i] == color then
			local bc, fc = image[3][i], image[4][i]
			image[3][i], image[4][i] = fc, bc
			image[6][i] = "▀"
			image[5][i] = 1
		end
	end
end

makeImageTransparent(tt, 0x000000)

term.clear()
db.drawRectangle(1, 1, 1000, 1000, 0x000000, 0x000000, " ")
db.drawChanges()


if false then
	dbgpu.setBackground(0x000000)
	dbgpu.setForeground(0xaaaaaa)
	dbgpu.set(10, 10, chars)
	dbgpu.set(10, 12, chars)
	dbgpu.set(10, 14, chars)
end
db.drawChanges()

--local pd, rpd = db.copy(8, 8, 10, 10)

--db.drawImage(10, 10, texture)

db.set(1, 20, 0x333333, 0xaaaaaa, "T")
db.drawRectangle(1, 23, 10, 10, 0x333333, 0xaaaaaa, "T")
db.drawImage(1, 20, tt)
db.drawImage(1, 23, tt)

--db.directCopy(1, 15, 10, 10, 20, 15, false)

local ptime = computer.uptime()

--local cd, rcd = db.copy(1, 3, 50, 25, true)
--db.paste(80, 3, cd)
	
--db.directCopy(1, 20, 50, 25, 80, 20, true, true)

dbgpu.copy(1, 20, 20, 20, 5, 0)
--dbgpu.copy(1, 20, 20, 20, 35, 0)
--dbgpu.copy(1, 20, 20, 20, 40, 0)

db.drawChanges()

gpu.setForeground(0xaaaaaa)
gpu.setBackground(0x000000)

print()
print()

print(db.getIndex(50, 0))
print(computer.uptime() -ptime)