local t = {
	version = "v0.1",
	textureFormat = "OCGLT",

	format = "OCGLT",
	--version = "v1.0",
	resX = 10,
	resY = 10,
	
	drawCalls = {
		--{"b", 0x333333},
		{"b", 0x993333},
		{"f", 0xaaaaaa},
		
		{0, 0, 10, 10, " "},
		{0, 0, "0123456789"},
		{0, 0, "0123456789", true},
		{0, 9, "0123456789"},
		{9, 0, "0123456789", true},
	},
}


return t
