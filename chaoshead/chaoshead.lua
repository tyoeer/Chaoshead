local TABS = require("ui.tools.tabs")
local WORKSHOP = require("levelEditor.workshop.workshop")
local CAMPAIGNS = require("campaignEditor.overview.overview")
local DATA_EXPLORER = require("dataExplorer.overview")
local MISC = require("chaoshead.misc")
local WikiData = require("levelhead.wikiData")

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
	
	self:setFancyGraphics(Storage.fancyGraphics)
	
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

function UI:setFancyGraphics(fancy)
	if WikiData.error and self:inTree() then
		self:popup(
			"Error loading LH wiki game data export, fancy graphics disabled:",
			WikiData.error
		)
	end
	WikiData:setImagesEnabled(fancy)
end

function UI:preDraw()
	love.graphics.clear(Settings.theme.main.background)
end

function UI:onInputActivated(name,group,isCursorBound)
	if group=="main" then
		if name=="toggleFullscreen" then
			self:toggleFullscreen()
		elseif name=="toggleFancyGraphics" then
			Storage.fancyGraphics = not Storage.fancyGraphics
			self:setFancyGraphics(Storage.fancyGraphics)
			Storage:save()
		end
	else
		UI.super.onInputActivated(self, name,group,isCursorBound)
	end
end

return UI
