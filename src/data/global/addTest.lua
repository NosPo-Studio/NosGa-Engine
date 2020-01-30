local global = ...

return function(id, x, y)
	local name = "test" .. tostring(id)
	x = x or 0
	y = y or 0
	global.state.test[name] = global.state.test.ra1:addGO("Test", {posX = 20 +100 +x, posY = 3 +y, layer = 3, name = name})
end