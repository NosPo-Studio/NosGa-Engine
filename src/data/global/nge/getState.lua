local global = ...

return function()
	return global.state[global.currentState]
end