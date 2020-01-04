# The NosGa Engine
	is a object oriented in source game engine for OpenComputers with all you need to create a 2D game.

# Features
### Render Engine:
NosGa provides a self managed multi window 2D render engine using the gpu.copy function to move the camera and sprites without rerendering the visible areas/sprites.
Toghether with the slightly modified DoubleBuffering method (by IgorTimofeev) you get the best possible OC graphic performance with very less effort.
		
The render engine is basicly fully functional without DoubleBuffering too (for memory intensive applications) but with lot worse performance is the most cases of course.
	
### Asset loading:
NosGa is loading assets like GameObjects, textures, mods etc. fully automatic at startup or just some asses groups at some point of your code.
	
### Debugging features:
A fully implemented LUA console to get mesasnges or run LUA code at runtime.

Asset reloading. You can reload spesific assed groups on keypress at runntime.
So you do not need to restart the whole engine anytime you change some code.

Layer select. You can acticate and deactivate the visible layers for any RenderArea.
Also you can make a RenderArea "silent" than it will not affect the visible GameObjects in any way.
	
### Event Handling:
The NosGa event handler is processing all signals at the current frame to prevent delayed signal function calling.
	
### Physics:
NosGa proides a very simple physic engine with BoxColliders and RigidBodys but that is in a early state of developing right now.
	
### Trigger:
With the NosGa you easly can attach triggers to your GameObjects calling a spesific function if it is in contact with oher triggers and/or colliders (dependent on the settings).
