return {
	tabs = {
		activeDividerColor = {0.6,0.6,0.6, 1},
		buttonHeight = 30,
	},
	treeViewer = {
		listStyle = {
			textIndentSize = 0/0,--unused, NaN to help detect errors
			entryMargin = 0,
			defaultButtonPadding = 5,
			
			indentCharacters = 2,
		},
		listDetailsDivisionStyle = {
			divisionRatio = 0.25,
			dividerColor = {1,1,1},
		},
	},
	details = {
		listStyle = {
			textIndentSize = 15,
			entryMargin = 6,
			defaultButtonPadding = 5,
		},
		insetSize = 10,
	},
	modal = {
		boxStyle = {
			padding = 10,
			backgroundColor = {0,0,0},
			borderColor = {1,1,1},
		},
		listStyle = {
			textIndentSize = 12,
			entryMargin = 8,
			defaultButtonPadding = 5,
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
				backgroundColor = {0,0,0},
				borderColor = {1,1,1},
				textStyle = {
					horAlign = "center",
					verAlign = "center",
					color = {1,1,1},
				},
			},
			hover = {
				backgroundColor = {0.5,0.5,0.5},
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
