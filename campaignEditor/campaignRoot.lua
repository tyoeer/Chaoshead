local Tabs = require("ui.tools.tabs")
local List = require("ui.layout.list")
local Campaign = require("levelhead.campaign.campaign")
local CampaignMisc = require("campaignEditor.misc")
local Checks = require("levelhead.campaign.checks")
-- local Script = require("script")

local Node = require("levelhead.campaign.node")
local Level = require("levelhead.campaign.level")

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
	MainUI:popup("Failed to load campaign!","Error message: "..message,trace)
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
	self.levelsOverview:reload()
end

function UI:save()
	self.campaign:save()
	MainUI:popup("Succesfully saved campaign!")
end

function UI:runChecks(prefix)
	prefix = prefix or "Campaign failed some checks:\n"
	
	local failed = {}
	for _,check in ipairs(Checks) do
		local problems = check.check(self.campaign)
		if problems and #problems>0 then
			table.insert(failed, {
				label = check.label,
				problems = problems,
			})
		end
	end
	
	if #failed>0 then
		local l = List:new(Settings.theme.details.listStyle)
		l:addTextEntry(prefix)
		l:addSeparator(true)
		
		for _,failure in ipairs(failed) do
			l:addTextEntry(failure.label)
			
			for _,problem in ipairs(failure.problems) do
				if type(problem)=="table" then
					if problem:isInstanceOf(Node) then
						l:addButtonEntry(problem:getLabel(), function()
							self:gotoNode(problem)
							MainUI:removeModal()
						end)
					elseif problem:isInstanceOf(Level) then
						l:addButtonEntry(problem:getLabel(), function()
							self:gotoLevel(problem)
							MainUI:removeModal()
						end)
					end
				else
					l:addTextEntry(tostring(problem))
				end
			end
			
			l:addSeparator(true)
		end
		
		MainUI:popup(l)
		return false
	else
		return true
	end
end


function UI:gotoLevel(level)
	self.levelsOverview:selectLevel(level)
	self.child:setActiveTab(self.levelsOverview)
end

function UI:gotoNode(node)
	self.mapEditor:selectNode(node)
	self.child:setActiveTab(self.mapEditor)
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
-- 			MainUI:popup("Succesfully ran "..path)
-- 		else
-- 			local message = selectionOrMessage
-- 			MainUI:popup(message, errTrace)
-- 		end
-- 	else
-- 		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
-- 	end
-- end

---@param level unknown? the level that has changed
---@param detailsOnly boolean? if only stuff displayed in the level details menu has changed
function UI:levelChanged(level, detailsOnly)
	if detailsOnly==nil then
		detailsOnly = false
	end
	if detailsOnly then
		self.levelsOverview:levelChanged(level)
	else
		--the tree list displays the id
		self.levelsOverview:reload()
		self.mapEditor:levelChanged(level)
	end
end

-- function UI:setClipboard(cp)
-- 	self.overview.clipboard = cp
-- end

-- function UI:getClipboard()
-- 	return self.overview.clipboard
-- end

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
		elseif name=="checkLimits" then
			if self:runChecks() then
				MainUI:popup("Campaign passes all checks")
			end
		-- elseif name=="gotoLevelEditor" then
		-- 	self.child:setActiveTab(self.levelEditor)
		-- elseif name=="gotoScripts" then
		-- 	self.child:setActiveTab(self.scriptInterface)
		-- elseif name=="quickRunScript" then
		-- 	if Storage.quickRunScriptPath then
		-- 		self:runScript(Storage.quickRunScriptPath, true)
		-- 	else
		-- 		MainUI:popup("No script bound to the quick run hotkey!")
		-- 	end
		end
	end
end

return UI
