local computer = require("computer")
local term = require("term")
local component = require("component")
local gpu = component.gpu
local shell = require("shell")

package.loaded["libs/oclrl"] = nil
local oclrl = require("libs/oclrl").initiate(gpu)

local texture1 = dofile("texturePacks/default/textures/reTest.lua")

term.clear()

os.sleep(1)
