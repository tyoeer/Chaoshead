local ui = require("ui.structure.tabs"):new()
ui.tabHeight = settings.dim.main.tabHeight

local hexInspector = require("ui.structure.movableCamera"):new(
	require("ui.hexInspector"):new()
)
ui:addChild(hexInspector)

local levelEditor = require("ui.levelEditor"):new()
ui:addChild(levelEditor)
ui:setActive(levelEditor)
local treeExplorerTest = require("ui.treeViewer"):new(
	{
		getDetailsUI = function(self,data)
			return require("ui.list.text"):new(data.title,5,0)
		end,
		getChildren = function(self,parent)
			local out = {}
			for i=1,10,1 do
				table.insert(out,{
					title = parent.title.."."..i,
					folder = (i % 2 == 0)
				})
			end
			return out
		end,
		getRootEntries = function(self)
			local out = {}
			for i=1,10,1 do
				table.insert(out,{
					title = i,
					folder = (i % 2 == 0)
				})
			end
			return out
		end,
	}
)

ui:addChild(treeExplorerTest)

return ui
