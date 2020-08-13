local LevelUtils = require("utils.levelUtils")
local LHS = require("levelhead.lhs")
--levelRoot was the best name I could come up with, OK?

local UI = Class(require("ui.structure.proxy"))

function UI:initialize(levelPath)
	self.levelPath = levelPath
	self.levelFile = LHS:new(levelPath)
	self.levelFile:readAll()
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
		self.levelFile:reload()
		self.levelFile:readAll()
		self.level = self.levelFile:parseAll()
	end
	self.levelEditor:reload(self.level)
	self.hexInspector:reload(self.levelFile)
end

function UI:save()
	self.levelFile:serializeAll(self.level)
	self.levelFile:writeAll()
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
end


function UI:close()
	ui:closeEditor(self)
end


function UI:focus(focus)
	if focus then
		self:reload()
	end
	self.child:focus(focus)
end

function UI:inputActivated(name,group, isCursorBound)
	if name=="reload" and group=="misc" then
		self:reload()
	elseif name=="save" and group=="editor" then
		self:save()
	else
		self.child:inputActivated(name,group, isCursorBound)
	end
end

return UI
