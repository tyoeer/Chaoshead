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
		select = {
			trigger = "mouse: left",
			isCursorBound = true,
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
				"mouse: left"
			},
			isCursorBound = true,
		}
	}
}
