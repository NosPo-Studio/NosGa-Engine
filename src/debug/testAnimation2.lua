local body = {
	{"b", 0xaa770a},
	{"f", 0xbb9933},
	{1, 0, "2222"},
	
	{"b", 0xa66330a},
	{"f", 0xa88660a},
	{1, 1, "   o"},
	{1, 2, "   -"},
	
	{"b", 0x993311},
	{"f", 0x0f1155},
	{0, 3, 6, 2, "#"},
}

local colors = {
	legs = {
		{"b", 0xaa1122},
		{"f", 0x000000},
	},
}

local legs = {
	{
		{colors.legs},
		{1, 5, " "},
		{4, 5, " "},
	},
	{
		{colors.legs},
		{1, 5, "▄"},
		{4, 5, " "},
	},
	{
		{colors.legs},
		{2, 5, "▄"},
		{3, 5, " "},
	},
	{
		{colors.legs},
		{3, 5, "▄"},
		{2, 5, " "},
	},
	{
		{colors.legs},
		{4, 5, "▄"},
		{1, 5, " "},
	},
}

local t = {
	format = "OCGLA",
	version = "v0.1",
	frameTime = .1,
	
	frames = {
		{
			{body},
			{legs[1]},
		},
		{
			{body},
			{legs[2]},
		},
		{
			{body},
			{legs[3]},
		},
		{
			{body},
			{legs[4]},
		},
		{
			{body},
			{legs[5]},
		},
	},
}


return t