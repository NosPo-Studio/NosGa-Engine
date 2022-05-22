local computer = require("computer")
local term = require("term")
package.loaded["libs/thirdParty/DoubleBuffering"] = nil
package.loaded["libs/thirdParty/color"] = nil
package.loaded["libs/thirdParty/OCIF"] = nil
package.loaded["libs/thirdParty/image"] = nil
local db = require("libs/thirdParty/DoubleBuffering")
local image = require("libs/thirdParty/image")
local texture = image.load("texturePacks/default/textures/pipipu.pic")
local component = require("component")
local gpu = component.gpu
local shell = require("shell")

package.loaded["libs/dbgpu_api"] = nil

local dbgpu = loadfile(shell.getWorkingDirectory() .. "/libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})

--local tt = image.load("texturePacks/default/textures/barrier1.pic")
local tt = image.load("texturePacks/default/textures/ttest.pic")
--local tt = image.load("debug/ttest2.pic")
local tt2 = image.load("texturePacks/default/animations/test/frames/1.pic")

local tColor = 0x00ffff

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

local function dumpPic(p)
	for i, c in pairs(p) do
		if type(c) == "table" then
			print()
			print("=====" .. tostring(i) .. "=====")
			for i2, c2 in pairs(c) do
				io.write(i2, " ", c2, " | ")
			end
		end
	end
end

term.clear()
db.drawRectangle(1, 1, 1000, 1000, 0x55555, 0x555555, " ")
db.drawChanges()

makeImageTransparent(tt, tColor)

db.drawImage(10, 40, tt)
db.drawImage(30, 40, tt2)

db.drawChanges()


gpu.setBackground(0x000000)
gpu.setForeground(0xaaaaaa)

print(0x00ff00, 0x00ff01)

dumpPic(tt)
print("")
print("")
print("--=====--")
--dumpPic(tt2)