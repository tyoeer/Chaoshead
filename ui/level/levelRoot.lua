local LHS = require("levelhead.lhs")
local LIMITS = require("levelhead.level.limits")

--levelRoot was the best name I could come up with, OK?

local UI = Class(require("ui.structure.proxy"))

function UI:initialize(levelPath)
	self.levelPath = levelPath
	self.levelFile = LHS:new(levelPath)
	self.levelFile:readAll()
	self.latestHash = self.levelFile:getHash()
	self.level = self.levelFile:parseAll()
	
	tabs = require("ui.structure.tabs"):new()
	
	self.hexInspector = require("ui.level.hexInspector"):new(self.levelFile)
	tabs:addChild(require("ui.utils.movableCamera"):new(self.hexInspector))
	
	self.levelEditor = require("ui.level.levelEditor"):new(self.level, self)
	tabs:addChild(self.levelEditor)
	tabs:setActive(self.levelEditor)
	
	self.scriptInterface = require("ui.level.scriptInterface"):new(self)
	tabs:addChild(self.scriptInterface)
	
	UI.super.initialize(self,tabs)
	self.title = levelPath
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
			function(message)
				--print full trace to console
				--snippet yoinked from default löve error handling
				print((debug.traceback("Error loading level: " .. tostring(message), 1):gsub("\n[^\n]+$", "")))
				ui:displayMessage("Failed to load level!\n(Probably due to lacking Void Update support)\nError message:\n"..tostring(message))
			end
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
		local level = require("script").runDangerously(path, self.level)
		self:reload(level)
	else
		error("Tried to run script in sandboxed mode, which is currently not yet implemented.")
	end
	--move to the levelEditor to show the scripts effects
	self.child:setActive(self.levelEditor)
	ui:displayMessage("Succesfully ran script!")
end


function UI:close()
	ui:closeEditor(self)
end


function UI:focus(focus)
	if focus then
		self.levelFile:reload()
		if self.latestHash ~= self.levelFile:getHash() then
			self:reload()
		end
	end
	self.child:focus(focus)
end

function UI:inputActivated(name,group, isCursorBound)
	if group=="editor" then
		if name=="reload" then
			self:reload()
		elseif name=="save" then
			self:save()
		elseif name=="checkLimits" then
			if self:checkLimits() then
				ui:displayMessage("Level doesn't break any limits!")
			end
		else
			self.child:inputActivated(name,group, isCursorBound)
		end
	else
		self.child:inputActivated(name,group, isCursorBound)
	end
end

return UI
