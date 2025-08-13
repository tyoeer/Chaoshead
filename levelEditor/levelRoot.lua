local LHS = require("levelhead.lhs")
local LIMITS = require("levelhead.level.limits")
local TABS = require("ui.tools.tabs")
local Misc = require("levelhead.misc")
local Script = require("script")
local LevelEditor = require("levelEditor.levelEditor")
local ScriptInterface = require("levelEditor.scriptInterface")

---@class LevelRootUI : ProxyUI
---@field super ProxyUI
---@field new fun(self, levelPath: string, workshop: WorkshopUI): self
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
	MainUI:popup("Failed to load level!","Error message: "..message,trace)
end
function UI.saveErrorHandler(message)
	message = tostring(message)
	--part of snippet yoinked from default löve error handling
	local fullTrace = debug.traceback("",2):gsub("\n[^\n]+$", "")
	print(message)
	print(fullTrace)
	--cut of the part of the trace that goes into the code that calls UI:openEditor()
	local index = fullTrace:find("%s+%[C%]: in function 'xpcall'")
	local trace = fullTrace:sub(1,index-1)
	return {message,trace}
end

---@param levelPath string
---@param workshop WorkshopUI
function UI:initialize(levelPath, workshop)
	self.workshop = workshop
	self.levelPath = levelPath
	self.levelFile = LHS:new(levelPath)
	self.levelFile:readAll()
	self.latestHash = self.levelFile:getHash()
	self.level = self.levelFile:parseAll()
	
	if self.level.settings.published and
		levelPath:match(Misc:getDataPath()) and
		levelPath:match("Rumpus")
	then
		error("Can't open published level!")
	end
	
	local tabs = TABS:new()

	
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
	self.title = self.level.settings:getTitle()
end

function UI:save()
	if self:checkLimits("Can't save level:\n") then
		local success, hashOrErr = xpcall(
			function()
				self.levelFile:serializeAll(self.level)
				return self.levelFile:writeWithBackup()
			end,
			self.saveErrorHandler
		)
		if success then
			self.latestHash = hashOrErr
			MainUI:popup("Succesfully saved level!")
		else
			local files = ""
			for _,path in ipairs(self.levelFile.tempFiles) do
				if files~="" then
					files = files .. "\n"
				end
				files = files .. path
			end
			MainUI:popup(
				"Error saving level:",
				hashOrErr[1],
				"\nLeft over files:",
				files,
				"\n",
				hashOrErr[2]
			)
			return
		end
	end
end

function UI:checkLimits(prefix)
	prefix = prefix or "Level broke limit:\n"
	
	for _,v in ipairs(Settings.misc.editor.checkLimits) do
		local list = LIMITS[v]
		for _,limit in ipairs(list) do
			local failed = {limit.check(self.level)}
			if failed[1] then
				MainUI:popup(prefix..string.format(limit.message,unpack(failed)))
				return false
			end
		end
	end
	return true
end

function UI:runScriptOld(path,disableSandbox)
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
			MainUI:popup("Succesfully ran "..path)
		else
			local message = selectionOrMessage
			MainUI:popup(message, errTrace)
		end
	else
		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
	end
end


---@param scriptEnv table
---@param path string
function UI:scriptSuccess(scriptEnv, path)
	local selection = scriptEnv.selection
	self:reload(scriptEnv.level)
	if selection and selection.mask then
		self.levelEditor:newSelection(selection.mask)
	end
	--move to the levelEditor to show the scripts effects
	self.child:setActiveTab(self.levelEditor)
	MainUI:popup("Succesfully ran "..path)
end

---@param errorMessage string
---@param errTrace table
---@param env table
function UI:scriptError(errorMessage, errTrace, env)
	MainUI:popup(errorMessage, errTrace)
end



---@param path string
---@param disableSandbox boolean
function UI:runScript(path, disableSandbox)
	if disableSandbox then
		local scriptEnv = Script.buildLevelEnv(
			self.level,
			self.levelEditor.selection and self.levelEditor.selection.mask,
			self.levelEditor.selection and self.levelEditor.selection.contents
		)
		
		--make closures over self for the callbacks
		
		local this = self
		---@param env table
		---@param path string
		local function success(env, path)
			this:scriptSuccess(env, path)
		end
		---@param errorMessage string
		---@param errTrace table
		---@param env table
		local function err(errorMessage, errTrace, env)
			this:scriptError(errorMessage, errTrace, env)
		end
		
		
		Script.runAsyncDangerously(path,scriptEnv,success,err)
	else
		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
	end
end


---@param cp Clipboard
function UI:setClipboard(cp)
	self.workshop.clipboard = cp
end

---@return Clipboard
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
				-- Prevent repeated asks after a single change that gets dismissed
				self.latestHash = self.levelFile:getHash()
				
				MainUI:popup(
					"Level was edited by external program (probably Levelhead)",
					{"Reload", function()
						MainUI:removeModal()
						self:reload()
					end}
				)
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
				MainUI:popup("Level doesn't break any limits!")
			end
		elseif name=="gotoLevelEditor" then
			self.child:setActiveTab(self.levelEditor)
		elseif name=="gotoScripts" then
			self.child:setActiveTab(self.scriptInterface)
		elseif name=="quickRunScript" then
			if Storage.quickRunScriptPath then
				self:runScript(Storage.quickRunScriptPath, true)
			else
				MainUI:popup("No script bound to the quick run hotkey!")
			end
		end
	end
end

return UI
