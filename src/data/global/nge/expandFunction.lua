local global = ...

return function(func1, func2)
	return function(...)
		func1(...)
		func2(...)
	end
end