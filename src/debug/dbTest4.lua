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

local tt = image.load("texturePacks/default/textures/ttest.pic")

term.clear()
db.drawRectangle(1, 1, 1000, 1000, 0x000000, 0x666666, ".")
db.drawChanges()


db.setDrawAreas({{3, 3, 6, 6}, {9, 9, 12, 12}})
--db.setNonDrawAreas({{3, 3, 6, 6}, {9, 9, 12, 12}})

db.setDrawAreaOffset(1, 1)

db.drawRectangle(1, 1, 40, 20, 0x000000, 0x8888, ",")

db.resetDrawAreas()

db:drawChanges()

os.sleep(1)
