local global = ...

local testBiome = {
	barrierChance = 99999999999999,
	--barrierChance = 100,
	--barrierChance = 1,
	barrierGaps = 40,
	
	--fuelContainerChance = 99999999999,
	--fuelContainerChance = 100,
	fuelContainerChance = 1,

	
	streets = {
		{name = "Street1",
			chance = 30,
		},
		{name = "Street2",
			chance = 1,
		},
	},
	
	backgrounds = {
		{name = "Test4",
			chance = 10,
		},
		{name = "Test2",
			chance = 10,
		},
		{name = "Test3",
			chance = 1,
		},
	},
	
	barriers = {
		{name = "BarrierTest",
			chance = 10,
		},
	},
	
	fuelContainers = {
		{name = "TestHuman",
			chance = 10,
		},
	},
	
}

return testBiome