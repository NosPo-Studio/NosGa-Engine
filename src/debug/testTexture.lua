local t2 = {
	{"b", 0xaa770a},
	{"f", 0xbb9933},
	{10, 0, "2222", true},
}

local t = {

	textureFormat = "OCGLT",
	version = "v0.2",
	
	drawCalls = {
		--{0, -1, t2},
		{t2},
		
		{"b", 0xa66330a},
		{"f", 0xa88660a},
		{1, 1, "   o"},
		{1, 2, "   -"},
		
		{"b", 0x133399},
		{"f", 0x0f1155},
		{0, 3, 6, 2, "#"},
		
		{"b", 0xaa1122},
		{"f", 0x660011},
		{1, 5, "L"},
		{4, 5, "L"},
	},
}


return t