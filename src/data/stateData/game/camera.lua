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

local global = ...

local camera = {}

function camera.update(game)
	--===== auto camera movement =====--
	local edgeSize = 0
	if game.player.gameObject.posX + (global.texturePack.size *2) + edgeSize *2 > global.resX then
		global.moveCamera(global.resX - ((edgeSize +3) *2) - (global.texturePack.size *2), 0)
	end
	if game.player.gameObject.posX < (edgeSize +2) *2 then
		global.moveCamera(- (global.resX - ((edgeSize +3) *2) - (global.texturePack.size *2)), 0)
	end
	
	if game.player.gameObject.posY + (global.texturePack.size *2) + edgeSize *2 > global.resY then
		global.moveCamera(0, global.resY - ((edgeSize +3) *2) - (global.texturePack.size *2))
	end
	if game.player.gameObject.posY < (edgeSize +2) *2 then
		global.moveCamera(0, - (global.resY - ((edgeSize +3) *2) - (global.texturePack.size *2)))
	end
	
	--===== manual camera movement =====--
	if global.keyboard.isKeyDown(global.controls.cameraUp) then
		global.moveCamera(0, - global.conf.cameraSpeed /2)
	end
	if global.keyboard.isKeyDown(global.controls.cameraDown) then
		global.moveCamera(0, global.conf.cameraSpeed /2)
	end
	if global.keyboard.isKeyDown(global.controls.cameraLeft) then
		global.moveCamera(-global.conf.cameraSpeed, 0)
	end
	if global.keyboard.isKeyDown(global.controls.cameraRight) then
		global.moveCamera(global.conf.cameraSpeed, 0)
	end
end

return camera