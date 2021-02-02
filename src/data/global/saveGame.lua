local global = ...

return function()
	local path = global.conf.saveGame
	local dir, fileName, fileEnd = global.ut.seperatePath(path)
	local saveGame
	fileEnd = fileEnd or ""
	
	if string.sub(path, 0, 1) ~= "/" then
		dir = global.shell.getWorkingDirectory() .. "/" .. dir
	end
	global.filesystem.makeDirectory(dir)
	
	saveGame = io.open(dir .. fileName .. fileEnd, "w")
	
	saveGame:write(global.serialization.serialize(global.stats.player))
	
	saveGame:close()
end