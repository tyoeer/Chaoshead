--local LEVEL_ROOT = require("ui.level.levelRoot")
local TABS = require("ui.tools.tabs")
local WORKSHOP = require("levelEditor.workshop.workshop")
local DATA_EXPLORER = require("dataExplorer.overview")
local MISC = require("ui.misc")

local UI = Class(require("ui.tools.modal"))

function UI:initialize()
	self.mainTabs = TABS:new()
	
	self.workshop = WORKSHOP:new()
	self.mainTabs:addTab(self.workshop)
	
	self.dataExplorer = DATA_EXPLORER:new()
	self.mainTabs:addTab(self.dataExplorer)
	
	self.mainTabs:addTab(MISC:new())
	
	self.mainTabs:setActiveTab(self.workshop)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,self.mainTabs)
end

function UI:draw()
	love.graphics.clear(Settings.theme.main.background)
	UI.super.draw(self)
end

return UI
