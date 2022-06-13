local global = ...

return function(args)
	local ra = global.core.RenderArea.new(args)
	global.renderAreas[ra] = true
	print("[Global]: Adding renderArea: " .. tostring(id) .. "\"" .. args.name .. "\".")
	return ra
	
	--[[
	local id = #global.renderAreas +1
	args.id = id
	global.renderAreas[id] = global.core.RenderArea.new(args)
	print("[Global]: Adding renderArea: " .. tostring(id) .. "\"" .. args.name .. "\".")
	return global.renderAreas[id]
	]]
end