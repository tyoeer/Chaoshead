local USER_DATA = require("levelhead.userData")
local LEVEL_DETAILS = require("levelEditor.workshop.levelDetails")

local UI = Class("LevelSelectorUI",require("ui.tools.treeViewer"))

function UI:initialize(workshop)
	self.workshop = workshop
	UI.super.initialize(self)
	self.title = "Level Selection"
end

function UI:getRootEntries()
	local out = {}
	for _,code in ipairs(USER_DATA.getUserCodes()) do
		table.insert(out,{
			title = code,
			code = code,
			folder = true,
		})
	end
	return out
end

function UI:getChildren(parent)
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
end

function UI:getDetailsUI(data)
	return LEVEL_DETAILS:new(self.workshop, data.raw)
end

return UI
