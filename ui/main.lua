local ui = require("ui.structure.tabs"):new()
ui.tabHeight = settings.dim.main.tabHeight

local hexInspector = require("ui.structure.movableCamera"):new(
	require("ui.hexInspector"):new()
)
ui:addChild(hexInspector)

local levelEditor = require("ui.levelEditor"):new()
ui:addChild(levelEditor)
ui:setActive(levelEditor)

local worldViewer = require("ui.structure.movableCamera"):new(
	require("ui.worldViewer"):new()
)
ui:addChild(worldViewer)

return ui
