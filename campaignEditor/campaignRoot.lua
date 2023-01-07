local Tabs = require("ui.tools.tabs")
local Campaign = require("levelhead.campaign.campaign")
local CampaignMisc = require("campaignEditor.misc")
-- local Script = require("script")

local MapEditor = require("campaignEditor.mapEditor")
local LevelsOverview = require("campaignEditor.levelSelector")
-- local ScriptInterface = require("levelEditor.scriptInterface") TODO script interface

--levelRoot was the best name I could come up with, OK?
local UI = Class("CampaignRootUI",require("ui.base.proxy"))

function UI.loadErrorHandler(message)
	message = tostring(message)
	--part of snippet yoinked from default löve error handling
	local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
	print(message)
	print(fullTrace)
	--cut of the part of the trace that goes into the code that calls UI:openEditor()
	local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
	local trace = fullTrace:sub(1,index-1)
	MainUI:displayMessage("Failed to load campaign!","Error message: "..message,trace)
end

function UI:initialize(subpath, overview)
	self.overview = overview
	self.subpath = subpath
	self.path = CampaignMisc.folder..subpath
	self.campaign = Campaign:new(self.path)
	self.campaign:reload()
	
	local tabs = Tabs:new()
	
	self.mapEditor = MapEditor:new(self)
	tabs:addTab(self.mapEditor)
	tabs:setActiveTab(self.mapEditor)
	
	self.levelsOverview = LevelsOverview:new(self)
	tabs:addTab(self.levelsOverview)
	-- self.scriptInterface = ScriptInterface:new(self)
	-- tabs:addTab(self.scriptInterface)
	
	UI.super.initialize(self,tabs)
	self.title = subpath
end

function UI:reload(campaign)
	if campaign then
		self.campaign = campaign
	else
		local success = xpcall(
			function()
				self.campaign:reload()
			end,
			self.loadErrorHandler
		)
		if not success then return end
	end
	self.mapEditor:reload(self.campaign)
end

function UI:save()
	self.campaign:save()
	MainUI:displayMessage("Succesfully saved campaign!")
end

function UI:checkLimits(prefix)
	-- TODO checking for (potential) problems, also maybe add the check to saving again
	-- prefix = prefix or "Level broke limit:\n"
	
	-- for _,v in ipairs(Settings.misc.editor.checkLimits) do
	-- 	local list = LIMITS[v]
	-- 	for _,limit in ipairs(list) do
	-- 		local failed = {limit.check(self.level)}
	-- 		if failed[1] then
	-- 			MainUI:displayMessage(prefix..string.format(limit.message,unpack(failed)))
	-- 			return false
	-- 		end
	-- 	end
	-- end
end

-- function UI:runScript(path,disableSandbox)
-- 	if disableSandbox then
-- 		local sel
-- 		if self.levelEditor.selection then
-- 			sel = {
-- 				mask = self.levelEditor.selection.mask,
-- 				contents = self.levelEditor.selection.contents,
-- 			}
-- 		end
-- 		local level, selectionOrMessage, errTrace = Script.runDangerously(path, self.level, sel)
-- 		if level then
-- 			local selection = selectionOrMessage
-- 			self:reload(level)
-- 			if selection and selection.mask then
-- 				self.levelEditor:newSelection(selection.mask)
-- 			end
-- 			--move to the levelEditor to show the scripts effects
-- 			self.child:setActiveTab(self.levelEditor)
-- 			MainUI:displayMessage("Succesfully ran "..path)
-- 		else
-- 			local message = selectionOrMessage
-- 			MainUI:displayMessage(message, errTrace)
-- 		end
-- 	else
-- 		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
-- 	end
-- end


function UI:setClipboard(cp)
	self.overview.clipboard = cp
end

function UI:getClipboard()
	return self.overview.clipboard
end

function UI:close()
	self.overview:closeEditor(self)
end

-- EVENTS

function UI:onInputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="reload" then
			self:reload()
		elseif name=="save" then
			self:save()
		-- elseif name=="checkLimits" then
		-- 	if self:checkLimits() then
		-- 		MainUI:displayMessage("Level doesn't break any limits!")
		-- 	end
		-- elseif name=="gotoLevelEditor" then
		-- 	self.child:setActiveTab(self.levelEditor)
		-- elseif name=="gotoScripts" then
		-- 	self.child:setActiveTab(self.scriptInterface)
		-- elseif name=="quickRunScript" then
		-- 	if Storage.quickRunScriptPath then
		-- 		self:runScript(Storage.quickRunScriptPath, true)
		-- 	else
		-- 		MainUI:displayMessage("No script bound to the quick run hotkey!")
		-- 	end
		end
	end
end

return UI
