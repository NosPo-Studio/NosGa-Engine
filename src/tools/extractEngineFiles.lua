local version = "v0.1d"

local extractionList = [[
nosGa.lua
libs
data/core
data/gameObjects/nge
data/global/nge
data/parents/nge

texturePacks/example
data/states/example.lua
mods/example.lua

tools
]]

local fs = require("filesystem")
local ut = require("libs/UT")
local shell = require("shell")

local args, opts = shell.parse(...)
local targetDir = args[1]
local wd = shell.getWorkingDirectory() .. "/"

if targetDir == nil then
    print("No output dir given")
    os.exit(1)
end

if fs.exists(wd .. targetDir) and opts.O ~= true then
    print("Target dir already exists")
    os.exit(2)
end

if not fs.exists(wd .. targetDir) then
    if os.execute("mkdir " .. targetDir) ~= true then
        print("Cant create dir")
        os.exit(3)
    end
end

for s in extractionList:gmatch("[^\r\n]+") do
    local target = targetDir .. "/" .. ut.seperatePath(s)

    if fs.exists(wd .. target) ~= true then
        print("Create dir: '" .. target .. "'")
        os.execute("mkdir " .. target)
    end

    print("Copy: '" .. s .. "' to: '" .. target .. "'")
    os.execute("cp -r " .. s .. " " .. target)
end

print("Done")