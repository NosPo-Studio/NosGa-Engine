local colors = {
	legs = {
		{"b", 0xaa1122},
		{"f", 0x00409f}, --WIP (OCCC_ToDo)
	},
}

local left = {
	{"b", 0xa66330a},
	{"f", 0xa88660a},
	{1, 1, "o   "},
	{1, 2, "-   "},
}

local right = {
	{"b", 0xa66330a},
	{"f", 0xa88660a},
	{1, 1, "   o"},
	{1, 2, "   -"},
}

local body = {
	{"b", 0xaa770a},
	{"f", 0xbb9933},
	{1, 0, "2222"},
	
	{"b", 0x133399},
	{"f", 0x0f1155},
	{0, 3, 6, 2, "#"},
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
	left = {
		format = "OCGLA",
		version = "v0.1",
		frameTime = .1,
		
		frames = {
			{
				{left},
				{body},
				{legs[1]},
			},
			{
				{left},
				{body},
				{legs[2]},
			},
			{
				{left},
				{body},
				{legs[3]},
			},
			{
				{left},
				{body},
				{legs[4]},
			},
			{
				{left},
				{body},
				{legs[5]},
			},
		},
	},
	
	right = {
		format = "OCGLA",
		version = "v0.1",
		frameTime = 1,
		
		frames = {
			{
				{right},
				{body},
				{legs[1]},
			},
			{
				{right},
				{body},
				{legs[2]},
			},
			{
				{right},
				{body},
				{legs[3]},
			},
			{
				{right},
				{body},
				{legs[4]},
			},
			{
				{right},
				{body},
				{legs[5]},
			},
		},
	},
}


return t