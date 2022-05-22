local computer = require("computer")
local term = require("term")
--package.loaded["libs/thirdParty/DoubleBuffering"] = nil
--local db = require("libs/thirdParty/DoubleBuffering")
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
local buffer1

--===== init =====--
term.clear()
dbgpu.freeAllBuffers()

buffer1 = dbgpu.allocateBuffer(20, 10)

--===== prog start =====--

dbgpu.setActiveBuffer(buffer1)
dbgpu.drawImage(1, 3, texture)
dbgpu.drawChanges()

dbgpu.copy(1, 1, 10, 100, 6, 0)

print("wait for input")
print(event.pull("key_down"))

dbgpu.bitblt(0, 20, 10, 100, 100, buffer1)
dbgpu.bitblt(0, 30, 10, 100, 100, buffer2)

dbgpu.setActiveBuffer(0)
dbgpu.drawImage(1, 3, texture)
dbgpu.drawChanges()


gpu.setActiveBuffer(0)