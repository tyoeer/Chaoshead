return {
	main = {
		click = {
			trigger = "mouse: left",
			isCursorBound = true,
		},
	},
	editor = {
		reload = {
			type = "and",
			triggers = {
				"key: r",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		save = {
			type = "and",
			triggers = {
				"key: s",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		
		selectOnly = {
			type = "and",
			triggers = {
				"mouse: left",
				{
					type = "nor",
					triggers = {
						"key: lctrl",
						"key: rctrl",
						"key: lshift",
						"key: rshift",
					},
				},
			},
			isCursorBound = true,
		},
		selectAdd = {
			type = "and",
			triggers = {
				"mouse: left",
				{
					type = "or",
					triggers = {
						"key: lctrl",
						"key: rctrl",
					},
				},
				{
					type = "nor",
					triggers = {
						"key: lshift",
						"key: rshift",
					},
				},
			},
			isCursorBound = true,
		},
		selectAddArea = {
			type = "and",
			triggers = {
				"mouse: left",
				{
					type = "or",
					triggers = {
						"key: lshift",
						"key: rshift",
					},
				},
				{
					type = "nor",
					triggers = {
						"key: lctrl",
						"key: rctrl",
					},
				},
			},
		},
		deselectSub = {
			type = "and",
			triggers = {
				"mouse: right",
				{
					type = "or",
					triggers = {
						"key: lctrl",
						"key: rctrl",
					},
				},
				{
					type = "nor",
					triggers = {
						"key: lshift",
						"key: rshift",
					},
				},
			},
		},
		deselectSubArea = {
			type = "and",
			triggers = {
				"mouse: right",
				{
					type = "or",
					triggers = {
						"key: lshift",
						"key: rshift",
					},
				},
				{
					type = "nor",
					triggers = {
						"key: lctrl",
						"key: rctrl",
					},
				},
			},
		},
		deselectAll = {
			type = "and",
			triggers = {
				"key: d",
				{
					type = "or",
					triggers = {
						"key: lctrl",
						"key: rctrl",
					},
				},
				{
					type = "nor",
					triggers = {
						"key: lshift",
						"key: rshift",
					},
				},
			},
		},
		
		delete = {
			type = "or",
			triggers = {
				"key: delete",
				"key: backspace",
			}
		},
		resize = {
			isCursorBound = true,
			trigger = "mouse: left"
		},
		checkLimits = {
			type = "and",
			triggers = {
				"key: l",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
	},
	camera = {
		drag = {
			type = "or",
			triggers = {
				"mouse: middle",
				{
					type = "and",
					triggers = {
						"mouse: right",
						{
							type = "nor",
							triggers = {
								"lshift",
								"rshift",
								"lctrl",
								"rctrl",
							},
						},
					},
				},
			},
			isCursorBound = true,
		}
	}
}
