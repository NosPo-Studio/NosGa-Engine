--[[
    UT Copyright (C) 2019 MisterNoNameLP.
	
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

--[[UsefullThings libary
	
]]
local UT = {version = "v0.6.1"}

function UT.parseArgs(...) --returns the first non nil value.
	for _, a in pairs({...}) do
		if a ~= nil then
			return a
		end
	end
end

function UT.seperatePath(path) --seperates a data path ["./DIR/FILE.ENDING"] into the dir path ["./DIR/"], the file name ["FILE"], and the file ending [".ENDING" or nil]
	if string.sub(path, #path) == "/" then
		return path
	end
	
	local dir, fileName, fileEnd = "", "", nil
	local tmpLatest = ""
	for s in string.gmatch(tostring(path), "[^/]+") do
		tmpLatest = s
	end
	dir = string.sub(path, 0, #path -#tmpLatest)
	for s in string.gmatch(tostring(tmpLatest), "[^.]+") do
		fileName = fileName .. s
		tmpLatest = s
	end
	if fileName == tmpLatest then
		fileName = tmpLatest
	else
		fileEnd = "." .. tmpLatest
		fileName = string.sub(fileName, 0, #fileName - #fileEnd +1)
	end
	
	return dir, fileName, fileEnd
end

function UT.getChars(s) --returns a array with the chars of the string.
	local chars = {}
	for c = 1, #s do
		chars[c] = string.sub(s, c, c)
	end
	return chars
end

function UT.makeString(c) --genetares a string from and array of chars/strings.
	local s = ""
	for c, v in ipairs(c) do
		s = s ..v
	end
	return s
end

function UT.inputCheck(m, c) --checks if a array (m) contains a value (c).
	for _, v in pairs(m) do
		if v == c then
			return true
		end
	end
	return false
end

function UT.fillString(s, amout, c) --fills a string (s) up with a (amout) of chars/strings (c).
	local s2 = s
	for c2 = 1, amout, 1 do
		s2 = s2 .. c
	end
	return s2
end

return UT