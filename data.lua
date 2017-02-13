data:extend(
{
	{
		type = "technology",
		name = "auto-deconstruct-loot-tech",
		icon = "__DeconstructNearbyLoot__/graphics/auto-deconstruct-loot-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"automated-construction",
			"personal-roboport-equipment",
			"character-logistic-slots-1",
		},
		unit =
		{
			count = 400,
			ingredients =
			{
				{"alien-science-pack", 1},
				{"science-pack-1", 1},
				{"science-pack-2", 1},
				{"science-pack-3", 1}
			},
			time = 30
		},
		order = "c-k-b-b",
	}
})
