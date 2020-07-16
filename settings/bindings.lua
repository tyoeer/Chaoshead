return {
	main = {
		click = {
			trigger = "mouse: left",
			isCursorBound = true,
		},
	},
	misc = {
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
	},
	editor = {
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
