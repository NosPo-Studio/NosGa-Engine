# The NosGa Engine
is a object oriented in source game engine for OpenComputers with all you need to create a 2D game.
The engine is in a early state of development so thre are some bugs left over as well as improvement potential of course but it sould be in a usable state right now.
New features will come at the point there are needed to realize projects in the engine.

# Features

More informations about the single features you can get in the wiki.

### Render Engine:
NosGa provides a self managed multi window 2D render engine using the gpu.copy function to move the camera and sprites without rerendering the visible areas/sprites.
Toghether with the slightly modified DoubleBuffering method (by IgorTimofeev) you get the best possible OC graphic performance with very less effort.
		
The render engine is basicly fully functional without DoubleBuffering too (for memory intensive applications) but with lot worse performance is the most cases of course.
	
### Asset loading:
NosGa is loading assets like GameObjects, textures, mods etc. fully automatic at startup or just some asses groups at some point of your code.
	
### Debugging features:
A fully implemented LUA console to get mesasnges or run LUA code at runtime.

Asset reloading: you can reload spesific assed groups on keypress at runntime.
So you do not need to restart the whole engine anytime you change some code.

Layer select: you can acticate and deactivate the visible layers for any RenderArea.
Also you can make a RenderArea "silent" than it will not affect the visible GameObjects in any way.
	
### Event Handling:
The NosGa event handler is processing all signals at the current frame to prevent delayed signal function calling.
	
### Physics:
NosGa proides a very simple physic engine with BoxColliders and RigidBodys but that is in a early state of developing right now.
	
### Trigger:
With the NosGa you easly can attach triggers to your GameObjects calling a spesific function if it is in contact with oher triggers and/or colliders (dependent on the settings).

# License
### NosGa Engine (GPLv3)
The NosGa Engine is a engine fork of ocCtaft (v0.1.2) <<https://github.com/MisterNoNameLP/ocCraft>>
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

### Third party (MIT)
The NosGa Engine is using third party libaries for some functionalities.  
More informations in the source files ("./libs/thirdParty/").

DoubleBuffering Copyright (c) 2018 Igor Timofeev  
Image Copyright (c) 2018 Igor Timofeev  
OCIF Copyright (c) 2018 Igor Timofeev  
Color Copyright (c) 2018   
AdvancedLua Copyright (c) 2018 Igor Timofeev  

OpenComputers (OpenOS LUA shell) Copyright (c) 2013-2015 Florian "Sangar" Nücke  

LIP (ini file parser) Copyright (c) 2012 Carreras Nicolas  

DoubleBuffering (raw copy feature) Copyright (c) 2019 NosPo Studio  
LUA shell (NosGa version) (c) 2019 NosPo Studio  

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
