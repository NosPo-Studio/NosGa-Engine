local global = ...

return function(...)
	for _, s in pairs({...}) do
		global.debugString = global.debugString .. " | " .. s
	end
end