local global = ...

return function(state)
	if global.state[state] == nil then
		global.fatal("[GE]: State not found: \"" .. state .. "\".")
	else
		global.log("[GE]: Change state to: \"" .. state .. "\".")
		if global.state[global.currentState] ~= nil then --To avoid crash at init phase.
			global.run(global.state[global.currentState].stop)
		end
		
		if not global.state[state].isInitialized then
			global.run(global.state[state].init)
			global.state[state].isInitialized = true
		end
		global.run(global.state[state].start)
		
		global.currentState = state
	end
end