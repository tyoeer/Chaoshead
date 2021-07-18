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
			},
			isCursorBound = true,
		},
		selectAreaModifier = {
			type = "or",
			triggers = {
				"key: lshift",
				"key: rshift",
			},
		},
		deselectArea = {
			type = "and",
			triggers = {
				"mouse: right",
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
			trigger = "mouse: middle",
			isCursorBound = true,
		}
	}
}
