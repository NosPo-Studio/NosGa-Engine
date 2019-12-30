local nosGaConf = {
	targetFramerate = 20, --default is "20". set to "-1" for unlimited framerate (can cause in graphical issures).
	maxTickTime = .2, --if a tick need more as the maxTickTime the engine will handle the ticke like it had needs exacly the maxTickTime.
	fpsCheckInterval = 10, --defines what amout of frames the engine use to calculate the avg. fps.
	
	showConsole = true, --can be changes ingame by pressing f1 by default.
	showDebug = true, --can be changes ingame by pressing f3 by default.
	consoleSizeY = 40, --the height of the console.
	
	preferModTextures = true, --if true mods can overwrite texturePack textures.
	
	
	defaultState = "test",
		
	renderLayerAmount = 5,
	useDoubleBuffering = true, --[[ Use the third party doubleBuffering method by IgorTimofeev.
		In the most cases using it causes in a big graphic performance boost but on cost of the memory usage.
		More informations on github.
	]]
	useSmartMove = true, --only available with doubleBuffering active.
	useSmartCameraMove = true, --recommended in any render mode.
	
	forceSmartMove = false, --forces the SmartMove in linear render mode (for render engine debugging purpose).
	
	narrowUpdateExpansion = {0, 0, 0, 0}, --[[ Defines the distance a gameObject can be away from any renderArea but will still updated.
		If it is set to false any gameObject will be updated independent from its position.
		Can be changed in source for any renderArea independently.
		
		{left, right, top, bottom}
	]]
		
	
	debug = { --these options are for developers.
		isDev = true, --activates debug outputs (strongly recommended if you want to mod the game in any way or something goes wrong and you need a detailed log).
		
		dlDebug = true, --print dataLoading debug (only if isDev).
		reDebug = false, --print renderEngine debug (only if isDev).
		raDebug = false, --print renderArea debug (only if isDev).
		uhDebug = false, --print updateHandler debug (only if isDev).
		goDebug = false, --print gameObject management debug (only if isDev).
		ehDebug = false, --print eventHandler debug (only if isDev).
		
		drawCollider = false,
		drawTrigger = false,
		
		onReload = { --defined what data/libs are reloaded at state reload. Press ctrl meanwhine to reload anything independent from this settings.
			conf = true, --should be always true.
			
			--=== core ===--
			re = false, 
			ge = false,
			eh = false,
			GameObject = false,
			RenderArea = false,
			
			--=== data groups ===--
			global = true, --global dir.
			structuredGlobal = true,
			states = true,
			textures = false,
			parents = false,
			gameObjects = false,
			
			mods = false, --just reloads the activated data groups of the mods (if only onReload.blocks = true he only also reloads the blocks from mods). should be always true.
		},
	}
}

return nosGaConf