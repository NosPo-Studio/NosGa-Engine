local global = ...

return function()
	global.gpu.setBackground(global.backgroundColor)
	global.gpu.fill(1, 1, global.resX, global.resY, " ")
	for ra in pairs(global.renderAreas) do
		ra:rerenderAll()
	end
	global.core.re.newDraw()
	if global.conf.useDoubleBuffering then
		global.gpu.drawChanges(true)
	end
end