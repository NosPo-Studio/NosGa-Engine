local t2 = {
	{0, 0, "T"},
	{2, 0, "T"},
	{4, 0, "T"},
	{6, 0, "T"},
	{8, 0, "T"},
	{10, 0, "T"},
	
	{0, 2, "T"},
	{2, 2, "T"},
	{4, 2, "T"},
	{6, 2, "T"},
	{8, 2, "T"},
	{10, 2, "T"},
	
	{0, 4, "T"},
	{2, 4, "T"},
	{4, 4, "T"},
	{6, 4, "T"},
	{8, 4, "T"},
	{10, 4, "T"},
	
	{0, 6, "T"},
	{2, 6, "T"},
	{4, 6, "T"},
	{6, 6, "T"},
	{8, 6, "T"},
	{10, 6, "T"},
	
	{0, 8, "T"},
	{2, 8, "T"},
	{4, 8, "T"},
	{6, 8, "T"},
	{8, 8, "T"},
	{10, 8, "T"},
	
	{0, 10, "T"},
	{2, 10, "T"},
	{4, 10, "T"},
	{6, 10, "T"},
	{8, 10, "T"},
	{10, 10, "T"},
	
}

local t = {

	textureFormat = "OCGLT",
	version = "v0.2",
	test = true,
	
	drawCalls = {
		{"b", 0x000000},
		{"f", 0xffffff},
		{0, 0, t2},
		{"b", 0x333333},
		{"f", 0xcccccc},
		{12, 0, t2},
		{"b", 0x666666},
		{"f", 0x999999},
		{0, 12, t2},
		{"b", 0x999999},
		{"f", 0x666666},
		{12, 12, t2},		
		{"b", 0x999999},
		{"f", 0x666666},
		{1, 0, t2},
		{"b", 0x666666},
		{"f", 0x999999},
		{13, 0, t2},
		{"b", 0x333333},
		{"f", 0xcccccc},
		{1, 12, t2},
		{"b", 0x000000},
		{"f", 0xffffff},
		{13, 12, t2},
		
		
		{"b", 0x000000},
		{"f", 0xffffff},
		{1, 1, t2},
		{"b", 0x333333},
		{"f", 0xcccccc},
		{13, 1, t2},
		{"b", 0x666666},
		{"f", 0x999999},
		{1, 13, t2},
		{"b", 0x999999},
		{"f", 0x666666},
		{13, 13, t2},		
		{"b", 0x999999},
		{"f", 0x666666},
		{2, 1, t2},
		{"b", 0x666666},
		{"f", 0x999999},
		{14, 1, t2},
		{"b", 0x333333},
		{"f", 0xcccccc},
		{2, 13, t2},
		{"b", 0x000000},
		{"f", 0xffffff},
		{14, 13, t2},
		
	},
}


return t