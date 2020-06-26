local ui = require("ui.structure.tabs"):new()
ui.tabHeight = settings.dim.main.tabHeight

local hexInspector = require("ui.utils.movableCamera"):new(
	require("ui.hexInspector"):new()
)
ui:addChild(hexInspector)

local levelEditor = require("ui.levelEditor"):new()
ui:addChild(levelEditor)
ui:setActive(levelEditor)

ui:addChild(require("ui.levelSelector"):new())

return ui
