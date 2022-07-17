local TABS = require("ui.tools.tabs")
local WORKSHOP = require("levelEditor.workshop.workshop")
local DATA_EXPLORER = require("dataExplorer.overview")
local MISC = require("ui.misc")
local LH_MISC = require("levelhead.misc")
local NFS = require("libs.nativefs")

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
	
	self:verifyDataFound()
end

function UI:draw()
	love.graphics.clear(Settings.theme.main.background)
	UI.super.draw(self)
end

function UI:verifyDataFound()
	if not NFS.getInfo(LH_MISC.getDataPath(),"directory") then
		self:displayMessage("Could not find Levelhead data at "..LH_MISC.getDataPath())
	end
end

return UI
