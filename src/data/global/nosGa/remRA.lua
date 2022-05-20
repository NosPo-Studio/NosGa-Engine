local global = ...

return function(ra)
	print("[Global]: Removing renderArea: " .. tostring(id) .. "\"" .. ra.name .. "\".")
	global.renderAreas[ra] = nil
end