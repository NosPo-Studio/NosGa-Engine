--This is a compressed animation file (OCGLA_v0.1).
--its acting almost same as a compressed texture (OCGLT_v0.2).

local global = ...

--===== textures =====--
local colors = {
	legs = {
		{"f", 0x802820},
		--{"b", global.backgroundColor}, --WIP (ocCraft.lua_ToDo)(dynamic color system)
	},
}

local face = {
	{"f", 0x7F2944},
	{0, 0, "o"},
	{0, 1, "-"},
}

local body = {
	{"b", 0xbF4984},
	{"f", 0x501810},
	{0, 0, 5, 2, " "},
}

local left = {
	{1, 0, body},
	{0, 0, face}, --takes background color from "body".
	{5, 1, "Ɔ"}, --takes colors from "face".
	
	{"b", global.backgroundColor},
	{"f", 0xbF4984},
	{6, 0, "&"},
}

local right = {
	{body},
	{5, 0, face}, --takes background color from "body".
	{0, 1, "C"}, --takes colors from "face".
	
	{"b", global.backgroundColor},
	{"f", 0xbF4984},
	{-1, 0, "&"},
}

local legs = { --takes background color from "right".
	{
		{colors.legs},
		{1, 2, "█"},
		{4, 2, "█"},
	},
	{
		{colors.legs},
		{1, 2, "▀"},
		{4, 2, "█"},
	},
	{
		{colors.legs},
		{2, 2, "▀"},
		{3, 2, "█"},
	},
	{
		{colors.legs},
		{3, 2, "▀"},
		{2, 2, "█"},
	},
	{
		{colors.legs},
		{4, 2, "▀"},
		{1, 2, "█"},
	},
}

--===== animation =====--

--any entity can have a normal texture (OCGLT_v0.1+), a normal animation (OCGLA_v0.1) or a table that stores a texture/animation for left and right facing.
--tha facing can be changed with Entity:turn(turnToLeft: boolean) (see "Pig.lua").

local t = {
	left = {
		format = "OCGLA",
		version = "v0.1",
		
		frameTime = .1, --here you define how long a songle frame are shown (frames can be skipped if a tick need to long or the frame time is to low).
		
		frames = { --here you store all the single frames (OCGLT_v0.1+)
			{
				{left},
				{legs[1]},
			},
			{
				{left},
				{legs[2]},
			},
			{
				{left},
				{legs[3]},
			},
			{
				{left},
				{legs[4]},
			},
			{
				{left},
				{legs[5]},
			},
		},
	},
	
	right = {
		format = "OCGLA",
		version = "v0.1",
		frameTime = .1,
		
		frames = {
			{
				{right},
				{legs[1]},
			},
			{
				{right},
				{legs[2]},
			},
			{
				{right},
				{legs[3]},
			},
			{
				{right},
				{legs[4]},
			},
			{
				{right},
				{legs[5]},
			},
		},
	},
}


return t