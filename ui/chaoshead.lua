local LevelRoot = require("ui.level.levelRoot")

local UI = Class(require("ui.structure.proxy"))

function UI:initialize(w,h)
	self.mainTabs = require("ui.structure.tabs"):new()
	self.modalOverlay = require("ui.structure.overlay"):new(self.mainTabs)
	
	UI.super.initialize(self,self.modalOverlay)
	self:resize(w,h)
	
	self.mainTabs.tabHeight = settings.dim.main.tabHeight
	
	self.nLevels = 0
	self.levels = require("ui.structure.tabs"):new()
	self.levels.title = "Level Editors"
	self.noLevelsUI = require("ui.structure.padding"):new(require("ui.list.text"):new("No levels opened!"),settings.dim.misc.noLevelsPadding)
	self.noLevelsUI.title = "Level Editors"
	self.levelsProxy = require("ui.structure.proxy"):new(self.noLevelsUI)
	self.mainTabs:addChild(self.levelsProxy)
	
	local levelSelector = require("ui.levelSelector"):new()
	self.mainTabs:addChild(levelSelector)
	self.mainTabs:setActive(levelSelector)
	
	self.mainTabs:addChild(require("ui.misc"):new())
end


function UI:openEditor(path)
	local success, editor = xpcall(
		function()
			return LevelRoot:new(path)
		end,
		function(message)
			--print full trace to console
			--snippet yoinked from default löve error handling
			print((debug.traceback("Error loading level: " .. tostring(message), 1):gsub("\n[^\n]+$", "")))
			self:displayMessage("Failed to load level!\n(Probably due to lacking Void Update support)\nError message:\n"..tostring(message))
		end
	)
	if success then
		self.levels:addChild(editor)
		self.levels:setActive(editor)
		self.mainTabs:setActive(self.levelsProxy)
		self.nLevels = self.nLevels + 1
		if self.nLevels == 1 then
			self.levelsProxy:setChild(self.levels)
		end
	end
end

function UI:closeEditor(editorRoot)
	self.levels:removeChild(editorRoot)
	self.nLevels = self.nLevels - 1
	if self.nLevels == 0 then
		self.levelsProxy:setChild(self.noLevelsUI)
	end
end


function UI:displayMessage(text)
	local ui = require("ui.structure.list"):new()
	ui:addTextEntry(text)
	ui:addButtonEntry("Dismiss",function() self:closeModal() end)
	self:setUIModal(ui)
end

function UI:setUIModal(ui)
	local modal = require("ui.utils.modal"):new(
		require("ui.structure.padding"):new(ui, settings.dim.modal.padding)
	)
	self.modalOverlay:setOverlay(modal)
end

function UI:closeModal()
	self.modalOverlay:removeOverlay()
end


return UI
