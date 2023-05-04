return {
	main = {
		click = {
			trigger = "mouse: left",
			isCursorBound = true,
		},
		toggleFullscreen = "key: f11",
	},
	editor = {
		quickRunScript = {
			type="and",
			triggers = {
				"key: b",
				{
					type="or",
					triggers = {"lctrl","rctrl"}
				}
			}
		},
		gotoLevelEditor = {
			type="and",
			triggers = {
				"key: e",
				{
					type = "or",
					triggers = {"lshift","rshift"}
				},
			}
		},
		gotoScripts = {
			type="and",
			triggers = {
				"key: q",
				{
					type = "or",
					triggers = {"lshift","rshift"}
				},
			}
		},
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
		selectAll = {
			type = "and",
			triggers = {
				"key: a",
				{
					type = "or",
					triggers = {
						"key: lctrl",
						"key: rctrl",
					},
				},
			},
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
		copy = {
			type = "and",
			triggers = {
				"key: c",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		paste = {
			type = "and",
			triggers = {
				"key: v",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		cut = {
			type = "and",
			triggers = {
				"key: x",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		placeAndReleaseHand = {
			type = "and",
			triggers = {
				"mouse: left",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			},
			isCursorBound = true,
		},
		placeHand = {
			type = "and",
			triggers = {
				"mouse: left",
				{
					type = "nor",
					triggers = {"lctrl","rctrl"}
				},
			},
			isCursorBound = true,
		},
		releaseHand = {
			trigger = "mouse: right",
			isCursorBound = true,
		},
	},
	camera = {
		drag = {
			trigger = "mouse: middle",
			isCursorBound = true,
		},
		up = {
			type = "and",
			triggers = {
				{
					type = "or",
					triggers = {
						"key: w",
						"key: up",
					}
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
		down = {
			type = "and",
			triggers = {
				{
					type = "or",
					triggers = {
						"key: s",
						"key: down",
					}
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
		left = {
			type = "and",
			triggers = {
				{
					type = "or",
					triggers = {
						"key: a",
						"key: left",
					}
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
		right = {
			type = "and",
			triggers = {
				{
					type = "or",
					triggers = {
						"key: d",
						"key: right",
					}
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
	},
	modal = {
		cancel = "key: escape",
	},
	textInput = {
		left = "key: left",
		right = "key: right",
		removeLeft = "key: backspace",
		removeRight = "key: delete",
		defocusDetection = "mouse: left",
		gotoFirst = "key: home",
		gotoLast = "key: end",
		
		copy = {
			type = "and",
			triggers = {
				"key: c",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		cut = {
			type = "and",
			triggers = {
				"key: x",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		paste = {
			type = "and",
			triggers = {
				"key: v",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		selectAll = {
			type = "and",
			triggers = {
				"key: a",
				{
					type = "or",
					triggers = {"lctrl","rctrl"}
				},
			}
		},
		
		selectModifier = {
			type = "or",
			triggers = {
				"lshift",
				"rshift",
			},
		},
		wordModifier = {
			type = "or",
			triggers = {
				"lctrl",
				"rctrl",
			},
		}
	},
}
