local t2 = {
	{"b", 0xaa770a},
	{"f", 0xbb9933},
	{1, 2, "2222"},
}

local t = {

	textureFormat = "OCGLT",
	version = "v0.2",
	
	drawCalls = {
		--{0, -1, t2},
		--{t2},
		
		{"b", 0xa66330a},
		{"f", 0xa88660a},
		
		{0, 0, 10, 10, "#"},
		
		--{0, 0, "0123456789"},
		--{0, 0, "0123456789", true},
		
	},
}


return t