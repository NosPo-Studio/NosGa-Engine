local licenseNotice = [[
--===== NosGa Engine (GPLv3) =====--
The NosGa Engine is a engine fork of ocCtaft (v0.1.2) <https://github.com/MisterNoNameLP/ocCraft>
which is licensed under the GPLv3.

ocCtaft Copyright (c) 2019 MisterNoNameLP
NosGa Engine Copyright (C) 2019-2020 NosPo Studio.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

--===== Third party (MIT) =====--
The NosGa Engine is using third party libaries for some functionalities.
More informations in the source files ("./libs/thirdParty/").

DoubleBuffering Copyright (c) 2018 Igor Timofeev
Image Copyright (c) 2018 Igor Timofeev
OCIF Copyright (c) 2018 Igor Timofeev
Color Copyright (c) 2018 
AdvancedLua Copyright (c) 2018 Igor Timofeev
DoubleBuffering (raw copy feature) Copyright (c) 2019 NosPo Studio

OpenComputers (OpenOS LUA shell) Copyright (c) 2013-2015 Florian "Sangar" Nücke
LUA shell (NosGa version) (c) 2019 NosPo Studio

LIP (ini file parser) Copyright (c) 2012 Carreras Nicolas

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.	
]]

--[[NosGa:
	Bugs:
		Animations:
			Not working. Created animations are the GameObject.
			
		EH:
			Worse performance/freeze on signal overflow.
		
		*? Memory leak on game restart/stop.
		
		gameObjects:
			*Speed shouldn't be more as the texturePack size (ocgf.RigidBody).
		
		Console:
			Text input is buggy sometimes (ocui?).
		
		RE:
			Graphic isures on RenderArea leaving GameObjects.
	
	ToDo:	
		GameObject:
			Add automatic "global.extentFunction" functuinality to parents (pUpdate...).
		
		oclrl:
			Add calculateSize(texture) function.
		
		Add dynamic texture color system (oclrl/ocgf).
			
		GameObject/RE:
			Replayce CopyArea with ClearArea .
			
	*left over from ocCraft but still relevant somehow.
]]
local version = "v0.4.6"

--===== prog start =====--
do
	print(licenseNotice)
	print("Starting NosGa Engine " .. version)
	local conf = dofile("nosGaConf.lua")
	
	local func, err = loadfile("data/core/global.lua")
	if conf.debug.isDev then
		print("Load global: ", func, err)
	end
	local global = func(conf)
	global.version = version
	global.licenseNotice = licenseNotice
	
	local func, err = loadfile("data/core/init.lua")
	if conf.debug.isDev then
		print("Initialize: ", func, err)
	end
	local initSuccsess, err = func(global, ...)
	
	print(global.isRunning)
	
	if initSuccsess then
		local core, err = loadfile("data/core/nosGaCore.lua")
		if global.isDev then
			print("Init done, starting program: ", core, err)
		end
		
		local success, returnValues = core(global)
		core = nil
		
		global = nil
		return success, returnValues
	else
		global = nil
		return false, "init failed", err
	end
end

--===== prog end =====--