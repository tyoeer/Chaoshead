local LHS = require("levelhead.lhs")
local LIMITS = require("levelhead.level.limits")
local TABS = require("ui.tools.tabs")
local Script = require("script")
local HexInspector = require("levelEditor.hexInspector")
local LevelEditor = require("levelEditor.levelEditor")
local ScriptInterface = require("levelEditor.scriptInterface")

--levelRoot was the best name I could come up with, OK?
local UI = Class("LevelRootUI",require("ui.base.proxy"))

function UI.loadErrorHandler(message)
	message = tostring(message)
	--part of snippet yoinked from default löve error handling
	local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
	print(message)
	print(fullTrace)
	--cut of the part of the trace that goes into the code that calls UI:openEditor()
	local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
	local trace = fullTrace:sub(1,index-1)
	MainUI:displayMessage("Failed to load level!","Error message: "..message,trace)
end

function UI:initialize(levelPath, workshop)
	self.workshop = workshop
	self.levelPath = levelPath
	self.levelFile = LHS:new(levelPath)
	self.levelFile:readAll()
	self.latestHash = self.levelFile:getHash()
	self.level = self.levelFile:parseAll()
	
	local tabs = TABS:new()
	
	self.hexInspector = HexInspector:new(self.levelFile)
	tabs:addTab(self.hexInspector)
	
	self.levelEditor = LevelEditor:new(self.level, self)
	tabs:addTab(self.levelEditor)
	tabs:setActiveTab(self.levelEditor)
	
	self.scriptInterface = ScriptInterface:new(self)
	tabs:addTab(self.scriptInterface)
	
	UI.super.initialize(self,tabs)
	self.title = self.level.settings:getTitle()
end

function UI:reload(level)
	if level then
		self.level = level
		self.hexInspector:reload(false)
	else
		local success, level = xpcall(
			function()
				self.levelFile:reload()
				self.levelFile:readAll()
				
				return self.levelFile:parseAll()
			end,
			self.loadErrorHandler
		)
		if success then
			self.latestHash = self.levelFile:getHash()
			self.level = level
			self.hexInspector:reload(self.levelFile)
		else
			return
		end
	end
	self.levelEditor:reload(self.level)
	self.title = self.level.settings:getTitle()
end

function UI:save()
	if self:checkLimits("Can't save level:\n") then
		self.levelFile:serializeAll(self.level)
		self.levelFile:writeAll()
		self.hexInspector:reload(false)
		MainUI:displayMessage("Succesfully saved level!")
	end
end

function UI:checkLimits(prefix)
	prefix = prefix or "Level broke limit:\n"
	
	for _,v in ipairs(Settings.misc.editor.checkLimits) do
		local list = LIMITS[v]
		for _,limit in ipairs(list) do
			local failed = {limit.check(self.level)}
			if failed[1] then
				MainUI:displayMessage(prefix..string.format(limit.message,unpack(failed)))
				return false
			end
		end
	end
	return true
end

function UI:runScript(path,disableSandbox)
	if disableSandbox then
		local sel
		if self.levelEditor.selection then
			sel = {
				mask = self.levelEditor.selection.mask,
				contents = self.levelEditor.selection.contents,
			}
		end
		local level, selectionOrMessage, errTrace = Script.runDangerously(path, self.level, sel)
		if level then
			local selection = selectionOrMessage
			self:reload(level)
			if selection and selection.mask then
				self.levelEditor:newSelection(selection.mask)
			end
			--move to the levelEditor to show the scripts effects
			self.child:setActiveTab(self.levelEditor)
			MainUI:displayMessage("Succesfully ran "..path)
		else
			local message = selectionOrMessage
			MainUI:displayMessage(message, errTrace)
		end
	else
		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
	end
end


function UI:setClipboard(cp)
	self.workshop.clipboard = cp
end

function UI:getClipboard()
	return self.workshop.clipboard
end

function UI:close()
	self.workshop:closeEditor(self)
end

-- EVENTS

function UI:onFocus(focus)
	if focus then
		local success = xpcall(
			function()
				self.levelFile:reload()
			end,
			self.loadErrorHandler
		)
		if success then
			if self.latestHash ~= self.levelFile:getHash() then
				self:reload()
			end
		end
	end
end

function UI:onInputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="reload" then
			self:reload()
		elseif name=="save" then
			self:save()
		elseif name=="checkLimits" then
			if self:checkLimits() then
				MainUI:displayMessage("Level doesn't break any limits!")
			end
		elseif name=="gotoLevelEditor" then
			self.child:setActiveTab(self.levelEditor)
		elseif name=="gotoScripts" then
			self.child:setActiveTab(self.scriptInterface)
		elseif name=="quickRunScript" then
			if Storage.quickRunScriptPath then
				self:runScript(Storage.quickRunScriptPath, true)
			else
				MainUI:displayMessage("No script bound to the quick run hotkey!")
			end
		end
	end
end

return UI
