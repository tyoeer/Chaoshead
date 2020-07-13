local LevelUtils = require("utils.levelUtils")
--levelRoot was the best name I could come up with, OK?

local UI = Class(require("ui.structure.proxy"))

function UI:initialize(levelPath)
	self.levelPath = levelPath
	self.levelFile = require("levelhead.lhs"):new(levelPath)
	self.levelFIle:readAll()
	self.level = self.levelFIle:parseAll()
	
	tabs = require("ui.structure.tabs"):new()
	tabs:addChild(require("ui.levelEditor"):new(self.level, self))
	
	UI.super.initialize(self,tabs)
	self.title = levelPath
end

function UI:reload()
	self.levelFIle:readAll()
	self.level = self.levelFIle:parseAll()
	for c in self.child.children:iterate() do
		if c.reload then
			c:reload(level)
		end
	end
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
