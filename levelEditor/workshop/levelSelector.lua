local UserData = require("levelhead.userData")
local LevelDetails = require("levelEditor.workshop.levelDetails")
local LhMisc = require("levelhead.misc")
local NFS = require("libs.nativefs")

local UI = Class("LevelSelectorUI",require("ui.tools.treeViewer"))

function UI:initialize(workshop)
	self.workshop = workshop
	UI.super.initialize(self)
	self.title = "Level Selection"
end

function UI:getRootEntries()
	local out = {}
	if Storage.lastLevelOpened then
		table.insert(out,{
			title = Storage.lastLevelOpened.name,
			action = function()
				self.workshop:openEditor(Storage.lastLevelOpened.path)
			end
		})
	end
	for _,code in ipairs(UserData.getUserCodes()) do
		table.insert(out,{
			title = code,
			code = code,
			folder = true,
		})
	end
	return out
end

function UI:getChildren(parent)
	local userData = UserData.getUserData(parent.code)
	if userData then
		local out = {}
		for _,level in ipairs(userData:getWorkshopLevels()) do
			table.insert(out,{
				raw = level,
				user = parent.code,
				title = level.name,
				folder = false,
			})
		end
		return out
	else
		local out = {}
		for _,item in ipairs(NFS.getDirectoryItems(LhMisc.getUserDataPath()..parent.code)) do
			if item:match("%.(.+)$") == "lhs" then
				table.insert(out,{
					raw = {
						path = LhMisc.getUserDataPath()..parent.code.."/"..item,
						name = item,
						id = item:match("^(.+)%."),
					},
					title = item,
					folder = false,
				})
			end
		end
		return out
	end
end

function UI:getDetailsUI(data)
	return LevelDetails:new(self.workshop, data.raw)
end

return UI
