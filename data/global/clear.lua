local global = ...

return function()
	global.gpu.setBackground(global.backgroundColor)
	global.gpu.fill(1, 1, global.resX, global.resY, " ")
	for i, ra in pairs(global.renderAreas) do
		ra:rerenderAll()
	end
	global.re.newDraw()
	if global.conf.debug.useDoubleBuffering then
		global.gpu.drawChanges(true)
	end
end