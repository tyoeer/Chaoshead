local TABS = require("ui.tools.tabs")
local WORKSHOP = require("levelEditor.workshop.workshop")
local CAMPAIGNS = require("campaignEditor.overview.overview")
local DATA_EXPLORER = require("dataExplorer.overview")
local MISC = require("ui.misc")
local LH_MISC = require("levelhead.misc")
local NFS = require("libs.nativefs")

local UI = Class(require("ui.tools.modal"))

function UI:initialize()
	self.mainTabs = TABS:new()
	
	self.workshop = WORKSHOP:new()
	self.mainTabs:addTab(self.workshop)
	
	if VERSION=="DEV" then
		self.campaigns = CAMPAIGNS:new()
		self.mainTabs:addTab(self.campaigns)
	end
	
	self.dataExplorer = DATA_EXPLORER:new()
	self.mainTabs:addTab(self.dataExplorer)
	
	self.mainTabs:addTab(MISC:new())
	
	self.mainTabs:setActiveTab(self.workshop)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,self.mainTabs)
	
	self:verifyDataFound()
end

function UI:verifyDataFound()
	if not NFS.getInfo(LH_MISC.getDataPath(),"directory") then
		self:displayMessage("Could not find Levelhead data at "..LH_MISC.getDataPath())
	end
end

function UI:toggleFullscreen()
	local fullscreen = not love.window.getFullscreen()
	Storage.fullscreen = fullscreen
	Storage.save()
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
