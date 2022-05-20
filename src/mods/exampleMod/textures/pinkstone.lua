local t = {

	textureFormat = "OCGLT",
	version = "v0.1",
	
	drawCalls = {
		{"b", 0xbF4984}, -- == gpu.setBackground(0xFF69B4)
		{"f", 0x8a3974}, -- == gpu.setBackground(0xaa4984)
		{0, 0, 6, 3, "#"}, -- == gpu.fill(0, 0, 6, 3, "#")
		--{0, 1, "######"}, -- == gpu.set(0, 1, "######")
	},
}


return t