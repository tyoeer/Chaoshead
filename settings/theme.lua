local MAIN_BG = {0.14, 0.14, 0.16}
local BUTTON_BG = {0.2, 0.2, 0.2}
local BUTTON_HOVER = {0.4, 0.4, 0.4}

return {
	main = {
		background = MAIN_BG,
		fontSize = 16,
	},
	editor = {
		level = {
			detailsWorldDivisionStyle = {
				divisionRatio = 0.25,
				dividerColor = {1,1,1},
				dividerWidth = 1,
			},
			rulerStyle = {
				uncenteredTextPadding = 3,
				centeredTextPadding = 2,
				verticalPadding = 2,
				bgColor = {0,0,0, 0.8},
				textColor = {1,1,1},
				cellDividerColor = {0.5,0.5,0.5},
			},
			
			worldBackground = {0.2,0.6,0.6},
			outsideWorld = {0.1, 0.1, 0.2},
			resizeCircles = {0.5,0.5,0.5, 0.5},
			selectingArea = {1,1,1},
			handHighlight = {1,1,1, 0.5},
			hoverHighlight = {1,1,1, 0.5},
			
			foregroundObject = {
				shape = {0,1,0.2, 0.4},
				outline = {0,1,0.2},
				text = {0,0,0},
				selected = {1,1,1},
			},
			backgroundObject = {
				shape = {1,0.2,0, 0.4},
				outline = {1,0.2,0},
				text = {0,0,0},
				selected = {1,1,1},
			},
			pathNode = {
				shape = {0.4,0,0.5, 0.6},
				outline = {0.8,0,1},
				connection = {0.8,0,1, 0.8},
				selected = {1,1,1},
			},
		},
		campaign = {
			detailsWorldDivisionStyle = {
				divisionRatio = 0.3,
				dividerColor = {1,1,1},
				dividerWidth = 1,
			},
			
			background = {0.2, 0, 0.6},
			origin = {0.5,0.5,0.5},
			selection = {1,1,1},
			selectingArea = {1,1,1},
			
			directConnections = {0.8,0,0.4},
			smoothConnections = {1,0.7,0.9},
			
			nodes = {
				colors = {
					level = {0,1,0},
					["icon pack"] = {1,1,0},
					path = {1,0,1},
					presentation = {0,1,1},
					["$UnknownNodeType"] = {0,0,0},
				},
				radii = {
					level = 94,
					["icon pack"] = 60,
					path = 20,
					presentation = 52,
					["$UnknownNodeType"] = 32,
					
				},
			},
		},
	},
	tabs = {
		activeDividerColor = {0.3,0.3,0.3},
		buttonHeight = 30,
		tabButtonStyle = {
			padding = 0,
			border = true,
			normal = {
				backgroundColor = BUTTON_BG,
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
			hover = {
				backgroundColor = BUTTON_HOVER,
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
		},
		activeTabButtonStyle = {
			padding = 0,
			border = true,
			normal = {
				backgroundColor = {0.3,0.3,0.3},
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
			hover = {
				backgroundColor = {0.4,0.4,0.4},
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
		},
	},
	treeViewer = {
		listStyle = {
			textIndentSize = 0,--unused, weird values that can help detect errors but unfortunately can't be saved
			entryMargin = 0,
			smallSeparatorSize = 8,
			bigSeparatorSize = 16,
			
			indentCharacters = 2,
			
			buttonStyle = {
				padding = 6,
				border = false,
				normal = {
					backgroundColor = MAIN_BG,
					textStyle = {
						horAlign = "left",
						verAlign = "center",
						color = {1,1,1},
					},
				},
				hover = {
					backgroundColor = {0.35, 0.35, 0.37},
					textStyle = {
						horAlign = "left",
						verAlign = "center",
						color = {1,1,1},
					},
				},
			},
			actionButtonStyle = {
				padding = 6,
				border = true,
				normal = {
					backgroundColor = BUTTON_BG,
					borderColor = {1,1,1},
					textStyle = {
						horAlign = "left",
						verAlign = "center",
						color = {1,1,1},
					},
				},
				hover = {
					backgroundColor = BUTTON_HOVER,
					borderColor = {1,1,1},
					textStyle = {
						horAlign = "left",
						verAlign = "center",
						color = {1,1,1},
					},
				},
			},
		},
		listDetailsDivisionStyle = {
			divisionRatio = 0.25,
			dividerColor = {1,1,1},
			dividerWidth = 1,
		},
	},
	details = {
		listStyle = {
			textIndentSize = 15,
			entryMargin = 6,
			smallSeparatorSize = 5,
			bigSeparatorSize = 16,
			
			buttonStyle = {
				padding = 6,
				border = true,
				normal = {
					backgroundColor = BUTTON_BG,
					borderColor = {1,1,1},
					textStyle = {
						horAlign = "left",
						verAlign = "center",
						color = {1,1,1},
					},
				},
				hover = {
					backgroundColor = BUTTON_HOVER,
					borderColor = {1,1,1},
					textStyle = {
						horAlign = "left",
						verAlign = "center",
						color = {1,1,1},
					},
				},
			},
		},
		inputStyle = {
			listStyle = {
				textIndentSize = 15,
				entryMargin = 6,
				smallSeparatorSize = 5,
				bigSeparatorSize = 16,

			},
			inputStyle = {
				textColor = {1,1,1},
				caretColor = {1,1,1},
				selectionColor = {0.6,0.6,1},
				selectedTextColor = {0,0,0.2},
				borderColor = {1,1,1},
				backgroundColor = {0.1, 0.1, 0.1},
				padding = 6,
			},
			errorStyle = {
				color = {1,0.2,0.2},
				horAlign = "left",
				verAlign = "center",
			}
		},
		insetSize = 10,
	},
	modal = {
		boxStyle = {
			padding = 10,
			backgroundColor = MAIN_BG,
			borderColor = {1,1,1},
			minMargin = 20,
		},
		inputStyle = {
			textColor = {1,1,1},
			caretColor = {1,1,1},
			selectionColor = {0.6,0.6,1},
			selectedTextColor = {0,0,0.2},
			borderColor = {1,1,1},
			backgroundColor = {0.1, 0.1, 0.1},
			padding = 6,
		},
		listStyle = {
			textIndentSize = 12,
			entryMargin = 8,
			smallSeparatorSize = 5,
			bigSeparatorSize = 16,

			textStyle = {
				horAlign = "left",
				verAlign = "center",
				color = {1,1,1},
			},
			buttonStyle = {
				padding = 5,
				border = true,
				normal = {
					backgroundColor = BUTTON_BG,
					borderColor = {1,1,1},
					textStyle = {
						horAlign = "center",
						verAlign = "center",
						color = {1,1,1},
					},
				},
				hover = {
					backgroundColor = BUTTON_HOVER,
					borderColor = {1,1,1},
					textStyle = {
						horAlign = "center",
						verAlign = "center",
						color = {1,1,1},
					},
				},
			},
		},
		blockStyle = {
			overlayColor = {0,0,0, 0.5},
		},
		widthFactor = 0.57,
	},
	scrollbar = {
		buttonStyle = {
			padding = 0,
			border = true,
			normal = {
				backgroundColor = BUTTON_BG,
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
			hover = {
				backgroundColor = BUTTON_HOVER,
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
		},
		width = 25,
		--not the center button:
		buttonHeight = 35,
	},
}
