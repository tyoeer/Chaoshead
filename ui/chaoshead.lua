local UI = Class(require("ui.structure.proxy"))

function UI:initialize()
	local tabs = require("ui.structure.tabs"):new()
	tabs.tabHeight = settings.dim.main.tabHeight
	
	self.nLevels = 0
	self.levels = require("ui.structure.tabs"):new()
	self.levels.title = "Level Editors"
	self.noLevelsUI = require("ui.list.text"):new("No levels opened!")
	self.noLevelsUI.title = "Level Editors"
	self.levelsProxy = require("ui.structure.proxy"):new(self.noLevelsUI)
	tabs:addChild(self.levelsProxy)
	
	local levelSelector = require("ui.levelSelector"):new()
	tabs:addChild(levelSelector)
	tabs:setActive(levelSelector)
	
	tabs:addChild(require("ui.misc"):new())
	
	UI.super.initialize(self,tabs)
end

function UI:openEditor(path,name)
	local editor = require("ui.level.levelRoot"):new(path)
	editor.title = name
	self.levels:addChild(editor)
	self.levels:setActive(editor)
	self.child:setActive(self.levelsProxy)
	self.nLevels = self.nLevels + 1
	if self.nLevels == 1 then
		self.levelsProxy:setChild(self.levels)
	end
end

function UI:closeEditor(editorRoot)
	self.levels:removeChild(editorRoot)
	self.nLevels = self.nLevels - 1
	if self.nLevels == 0 then
		self.levelsProxy:setChild(self.noLevelsUI)
	end
end

return UI
