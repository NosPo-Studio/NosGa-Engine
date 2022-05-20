local computer = require("computer")
local term = require("term")
package.loaded["libs/thirdParty/DoubleBuffering"] = nil
local db = require("libs/thirdParty/DoubleBuffering")
local image = require("libs/thirdParty/image")
local texture = image.load("texturePacks/default/textures/human.pic")
local component = require("component")
local gpu = component.gpu
local shell = require("shell")
local event = require("event")

package.loaded["libs/dbgpu_api"] = nil
local dbgpu = loadfile(shell.getWorkingDirectory() .. "/libs/dbgpu_api.lua")({path = "libs/thirdParty", directDraw = false, forceDraw = false, rawCopy = true})

--===== local vars =====--
local resX, resY = gpu.getResolution()

--===== init =====--
term.clear()
db.flush(resX, resY)


--===== prog start =====--
db.setBufferOnly(true)

db.drawImage(10, 10, texture)

db.semiPixelRawSet(db.getIndex(10, 10), 0xaaaaaa)
db.semiPixelRawSet(db.getIndex(10, 11), 0xaaaaaa, true)

db.semiPixelRawSet(db.getIndex(20, 10), 0xaaaaaa)
db.semiPixelRawSet(db.getIndex(20, 11), 0xaaaaaa, true)

db.drawChanges()

print("wait for input")
print(event.pull("key_down"))

db.drawChanges(true)