--[[
    This file is part of the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019-2020 NosPo Studio

    The NosGa Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The NosGa Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the NosGa Engine.  If not, see <https://www.gnu.org/licenses/>.
]]

--Test main class
local global = ...

local Test = {version = "v0.0d"}
Test.__index = Test

function Test.init(this) --parent func
	
end

function Test.new(args)
	local this = setmetatable({}, Test)
	
	this.test = global.oclrl.Animation.new(global.oclrl, global.texture.player.right)
	
	return this
end

return Test