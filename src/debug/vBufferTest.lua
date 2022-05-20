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

backBuffer = dbgpu.allocateBuffer(20, 20)

buffer1 = dbgpu.allocateBuffer(20, 10)
--===== prog start =====--

gpu.setActiveBuffer(buffer1)
dbgpu.drawImage(1, 1, texture)
dbgpu.drawChanges()

gpu.bitblt(backBuffer, 1, 1, 20, 10, buffer1)
gpu.bitblt(0, 10, 10, nil, nil, backBuffer)


gpu.setActiveBuffer(backBuffer)
gpu.set(1, 1, "T")

gpu.bitblt(backBuffer, 12, 1, 20, 10, buffer1)
gpu.bitblt(0, 10, 10, nil, nil, backBuffer)


gpu.setActiveBuffer(0)

--debug/vBufferTest.lua > logs/test.log