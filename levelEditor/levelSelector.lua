local USER_DATA = require("levelhead.userData")
local LEVEL_DETAILS = require("levelEditor.levelDetails")

local TREE_VIEWER = require("ui.tools.treeViewer")

local UI = Class("LevelSelectorUI",require("ui.base.proxy"))

function UI:initialize(workshop)
	local treeData = {
		getRootEntries = function(self)
			local out = {}
			for _,code in ipairs(USER_DATA.getUserCodes()) do
				table.insert(out,{
					title = code,
					code = code,
					folder = true,
				})
			end
			return out
		end,
		getChildren = function(self,parent)
			local out = {}
			for _,level in ipairs(USER_DATA.getUserData(parent.code):getWorkshopLevels()) do
				table.insert(out,{
					raw = level,
					user = parent.code,
					title = level.name,
					folder = false,
				})
			end
			return out
		end,
		getDetailsUI = function(self,data)
			return LEVEL_DETAILS:new(workshop, data.raw)
		end,
	}
	UI.super.initialize(self,TREE_VIEWER:new(treeData))
	self.title = "Level Selection"
end

return UI
