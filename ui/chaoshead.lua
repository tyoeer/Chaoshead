--local LEVEL_ROOT = require("ui.level.levelRoot")
local TABS = require("ui.layout.tabs")
local WORKSHOP = require("levelEditor.workshop")
local MISC = require("ui.misc")

local UI = Class(require("ui.tools.modal"))

function UI:initialize()
	self.mainTabs = TABS:new()
	
	self.workshop = WORKSHOP:new()
	self.mainTabs:addTab(self.workshop)
	self.mainTabs:setActiveTab(self.workshop)
	
	self.mainTabs:addTab(MISC:new())
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,self.mainTabs)
end

return UI
