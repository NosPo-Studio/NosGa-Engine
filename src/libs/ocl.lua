--[[
    ocl Copyright (C) 2019 MisterNoNameLP.
	
    This library is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this library.  If not, see <https://www.gnu.org/licenses/>.
]]

--ToDo: make it object oriented.

local ocl = { version = "v1.1",
	conf = {
		logFile = "logs/nosGa.log",
		backups = false,
	},
	
	logFile = {},
}

local filesystem = require("filesystem")
local shell = require("shell")
local ut = require("libs/UT")

function ocl.open(path)
	if path ~= nil then
		ocl.conf.logFile = path
	end
	local dir, fileName, fileEnd = ut.seperatePath(ocl.conf.logFile)
	fileEnd = fileEnd or ""
	if string.sub(ocl.conf.logFile, 0, 1) ~= "/" then
		dir = shell.getWorkingDirectory() .. "/" .. dir
	end
	filesystem.makeDirectory(dir)
	
	local file = nil
	if ocl.conf.backups then
		file = io.open(dir .. fileName .. fileEnd, "r")
	end
	if file == nil or not ocl.conf.backups then
		ocl.logFile = io.open(dir .. fileName .. fileEnd, "w")
	else
		file:close()
		local count = 1
		while true do
			file = io.open(dir .. fileName .. "(" .. tostring(count) .. ")" .. fileEnd, "r")
			if file == nil then
				ocl.logFile = io.open(dir .. fileName .. "(" .. tostring(count) .. ")" .. fileEnd, "w")
				break
			end
			file:close()
			count = count +1
		end
	end
end

function ocl.add(...)
	local text = ""
	for _, s in ipairs({...}) do
		text = text .. tostring(s)
	end
	ocl.logFile:write(tostring(text))
	ocl.logFile:write("\n")
	ocl.logFile:flush()
end

function ocl.close()
	ocl.logFile:close()
end

return ocl