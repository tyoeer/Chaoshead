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

function UI:findLastEditedLevel()
	local lastPath
	local lastTime = 0
	local lastTitle = "$NoLevelFound"
	
	for _,code in ipairs(UserData.getUserCodes()) do
		local userData = UserData.getUserData(code)
		if userData then
			for _,level in ipairs(userData:getWorkshopLevels()) do
				local info = NFS.getInfo(level.path)
				if info.modtime > lastTime then
					lastPath = level.path
					lastTime = info.modtime
					lastTitle = level.name
				end
			end
		else
			for _,item in ipairs(NFS.getDirectoryItems(LhMisc.getUserDataPath()..code)) do
				if item:match("%.(.+)$") == "lhs" then
					local path = LhMisc.getUserDataPath()..code.."/"..item
					local info = NFS.getInfo(path)
					if info.modtime > lastTime then
						lastPath = path
						lastTime = info.modtime
						lastTitle = item
					end
				end
			end
		end
	end
	
	return lastPath, lastTime, lastTitle
end

function UI:getRootEntries()
	local out = {}
	
	local path, when, title = self:findLastEditedLevel()
	if Storage.lastLevelOpened and when < Storage.lastLevelOpened.when then
		local info = NFS.getInfo(Storage.lastLevelOpened.path)
		if info then
			print("Yo", title, Storage.lastLevelOpened.title)
			path = Storage.lastLevelOpened.path
			when = Storage.lastLevelOpened.when
			title = Storage.lastLevelOpened.name
		else
			-- file got deleted
			Storage.lastLevelOpened = nil
			Storage:save()
		end
	end
	
	if path then
		print(path, title)
		table.insert(out,{
			title = title,
			action = function()
				self.workshop:openEditor(path)
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

function UI:onFocus(focus)
	if focus then
		self:reload()
	end
end

return UI
