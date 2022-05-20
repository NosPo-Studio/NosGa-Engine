local global = ...

return function(id)
	global.warn("global.setActiveBuffer !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	if id == global.currentVBuffer then
		return false, "Buffer is set already"
	else
		local suc = global.realGPU.setActiveBuffer(id)
		if suc ~= nil then
			global.currentVBuffer = suc
		end
		return suc
	end
end