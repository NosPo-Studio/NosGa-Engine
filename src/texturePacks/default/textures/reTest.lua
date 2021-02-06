local t = {
	version = "v0.1",
	textureFormat = "OCGLT",

	format = "OCGLT",
	--version = "v1.0",
	resX = 6,
	resY = 3,
	
	drawCalls = {
		{"b", 0x333333},
		{"f", 0xaaaaaa},
		
		
		{0, 0, "######"},
		{0, 1, "123456"},
		{0, 2, "######"},
	},
}


return t
