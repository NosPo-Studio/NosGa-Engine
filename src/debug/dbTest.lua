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
--db.drawChanges()


if true then
	dbgpu.setBackground(0x000000)
	dbgpu.setForeground(0xaaaaaa)
	dbgpu.set(10, 10, chars)
	dbgpu.set(10, 12, chars)
	dbgpu.set(10, 14, chars)
end


--dbgpu.copy(8, 8, 10, 10, 20, 0)
--dbgpu.copy(8, 8, 10, 10, 30, 0)

--db.semiPixelSet(10, 10, 0xffffff)
--db.semiPixelSet(10, 11, 0xffffff)
--db.semiPixelSet(10, 12, 0xffffff)

if false then
	db.set(10, 10, 0x000000, 0xaaaaaa, "▀")
	db.set(11, 10, 0x000000, 0xaaaaaa, "▄")
	db.set(12, 10, 0x000000, 0xaaaaaa, "█")
	db.set(10, 12, 0x000000, 0xaaaaaa, "▀")
	db.set(11, 12, 0x000000, 0xaaaaaa, "▄")
	db.set(12, 12, 0x000000, 0xaaaaaa, "█")
	db.set(10, 14, 0x000000, 0xaaaaaa, "▀")
	db.set(11, 14, 0x000000, 0xaaaaaa, "▄")
	db.set(12, 14, 0x000000, 0xaaaaaa, "█")
end

--dbgpu.copy(8, 8, 10, 10, 21, 3)
--dbgpu.copy(8, 8, 10, 10, 30, 0)

local pd, rpd = db.copy(8, 8, 30, 30)
db.paste(20, 10, pd)

db.drawChanges()

--gpu.copy(8, 8, 5, 5, 10, 0)