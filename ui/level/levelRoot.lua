local LevelUtils = require("utils.levelUtils")
--levelRoot was the best name I could come up with, OK?

local UI = Class(require("ui.structure.proxy"))

function UI:initialize(levelPath)
	self.levelPath = levelPath
	self.levelFile = require("levelhead.lhs"):new(levelPath)
	self.levelFile:readAll()
	self.level = self.levelFile:parseAll()
	
	tabs = require("ui.structure.tabs"):new()
	
	self.hexInspector = require("ui.level.hexInspector"):new(self.levelFile)
	tabs:addChild(require("ui.utils.movableCamera"):new(self.hexInspector))
	
	self.levelEditor = require("ui.level.levelEditor"):new(self.level, self)
	tabs:addChild(self.levelEditor)
	tabs:setActive(self.levelEditor)
	
	UI.super.initialize(self,tabs)
	self.title = levelPath
end

function UI:reload()
	self.levelFile:readAll()
	self.level = self.levelFile:parseAll()
	
	self.levelEditor:reload(self.level)
	self.hexInspector:reload(self.levelFile)
end

function UI:save()
	self.levelFile:serializeAll(self.level)
	self.levelFile:writeAll()
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
