local TABS = require("ui.tools.tabs")
local WORKSHOP = require("levelEditor.workshop.workshop")
local CAMPAIGNS = require("campaignEditor.overview.overview")
local DATA_EXPLORER = require("dataExplorer.overview")
local MISC = require("chaoshead.misc")

---@class ChaosheadUI : ModalManagerUI
---@field super ModalManagerUI
local UI = Class("ChaosheadUI",require("ui.tools.modal"))

function UI:initialize()
	self.mainTabs = TABS:new()
	
	self.workshop = WORKSHOP:new()
	self.mainTabs:addTab(self.workshop)
	
	self.campaigns = CAMPAIGNS:new()
	self.mainTabs:addTab(self.campaigns)
	
	self.dataExplorer = DATA_EXPLORER:new()
	self.mainTabs:addTab(self.dataExplorer)
	
	self.mainTabs:addTab(MISC:new())
	
	self.mainTabs:setActiveTab(self.workshop)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,self.mainTabs)
end

function UI:focusModule(module)
	self.mainTabs:setActiveTab(module)
end

function UI:toggleFullscreen()
	local fullscreen = not love.window.getFullscreen()
	Storage.fullscreen = fullscreen
	Storage:save()
	love.window.setFullscreen(fullscreen)
	UiRoot:resize(love.graphics.getWidth(), love.graphics.getHeight())
end


function UI:preDraw()
	love.graphics.clear(Settings.theme.main.background)
end

function UI:onInputActivated(name,group,isCursorBound)
	if group=="main" and name=="toggleFullscreen" then
		self:toggleFullscreen()
	else
		UI.super.onInputActivated(self, name,group,isCursorBound)
	end
end

return UI
