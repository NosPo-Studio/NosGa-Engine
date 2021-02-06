local global = ...

return function()
	local path = global.conf.saveGame
	local dir, fileName, fileEnd = global.ut.seperatePath(path)
	local saveGame
	fileEnd = fileEnd or ""
	
	if string.sub(path, 0, 1) ~= "/" then
		dir = global.shell.getWorkingDirectory() .. "/" .. dir
	end
	
	saveGame = io.open(dir .. fileName .. fileEnd, "r")
	
	if saveGame ~= nil then
		global.stats.player = global.serialization.unserialize(saveGame:read())
		
		saveGame:close()
	end
end