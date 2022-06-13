local global = ...

return function(sx, sy, bc, fc, t)
	return global.oclrl.generateTexture({
		{"f", fc},
		{"b", bc},
		{0, 0, sx, sy, " "},
		{math.floor(sx / 2 - global.unicode.len(t) / 2), math.floor(sy / 2), t},
	})
end