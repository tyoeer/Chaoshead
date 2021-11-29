local LHS = require("levelhead.lhs")
local LIMITS = require("levelhead.level.limits")
local LH_MISC = require("levelhead.misc")
local TABS = require("ui.tools.tabs")

--levelRoot was the best name I could come up with, OK?
local UI = Class("LevelRootUI",require("ui.base.proxy"))

function UI.loadErrorHandler(message)
	message = tostring(message)
	--part of snippet yoinked from default löve error handling
	local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
	print(fullTrace)
	--cut of the part of the trace that goes into the code that calls UI:openEditor()
	local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
	trace = fullTrace:sub(1,index-1)
	ui:displayMessage("Failed to load level!","Error message: "..message,trace)
end

function UI:initialize(levelPath)
	self.levelPath = levelPath
	self.levelFile = LHS:new(levelPath)
	self.levelFile:readAll()
	self.latestHash = self.levelFile:getHash()
	self.level = self.levelFile:parseAll()
	
	tabs = TABS:new()
	
	self.hexInspector = require("levelEditor.hexInspector"):new(self.levelFile)
	tabs:addTab(self.hexInspector)
	
	self.levelEditor = require("levelEditor.levelEditor"):new(self.level, self)
	tabs:addTab(self.levelEditor)
	tabs:setActiveTab(self.levelEditor)
	
	self.scriptInterface = require("levelEditor.scriptInterface"):new(self)
	tabs:addTab(self.scriptInterface)
	
	UI.super.initialize(self,tabs)
	self.title = self.level.settings:getTitle()
end

function UI:reload(level)
	if level then
		self.level = level
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
		else
			return
		end
	end
	self.levelEditor:reload(self.level)
	self.hexInspector:reload(self.levelFile)
	self.title = self.level.settings:getTitle()
end

function UI:save()
	if self:checkLimits("Can't save level:\n") then
		self.levelFile:serializeAll(self.level)
		self.levelFile:writeAll()
		ui:displayMessage("Succesfully saved level!")
	end
end

function UI:checkLimits(prefix)
	prefix = prefix or "Level broke limit:\n"
	
	local toCheck = {"file"}
	if not DISABLE_EDITOR_LIMITS then
		table.insert(toCheck,"editor")
	end
	
	for _,v in ipairs(toCheck) do
		local list = LIMITS[v]
		for _,limit in ipairs(list) do
			local failed = {limit.check(self.level)}
			if failed[1] then
				ui:displayMessage(prefix..string.format(limit.message,unpack(failed)))
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
		local level, selectionOrMessage, errTrace = require("script").runDangerously(path, self.level, sel)
		if level then
			selection = selectionOrMessage
			self:reload(level)
			if selection and selection.mask then
				self.levelEditor:newSelection(selection.mask)
			end
			--move to the levelEditor to show the scripts effects
			self.child:setActiveTab(self.levelEditor)
			ui:displayMessage("Succesfully ran script!")
		else
			message = selectionOrMessage
			ui:displayMessage(message, trace)
		end
	else
		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
	end
end


function UI:close()
	ui:closeEditor(self)
end


function UI:onFocus(focus)
	if focus then
		self.levelFile:reload()
		if self.latestHash ~= self.levelFile:getHash() then
			self:reload()
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
				ui:displayMessage("Level doesn't break any limits!")
			end
		end
	end
end

return UI
