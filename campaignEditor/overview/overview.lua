local TABS = require("ui.tools.tabs")
local SELECTOR = require("campaignEditor.overview.selector")
--local CAMPAIGN_EDITOR = require("campaignEditor.campaignEditor")

local UI = Class("CampaignSelectorUI",require("ui.base.proxy"))

UI.FOLDER = "campaigns/"

function UI:initialize()
	local tabs = TABS:new()
	
	self.selector = SELECTOR:new(self)
	tabs:addTab(self.selector)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,tabs)
	self.title = "Campaigns"
end


function UI:openEditor(subpath)
	--open the editor
	local success, editor = xpcall(
		function()
			return CAMPAIGN_EDITOR:new(subpath,self)
		end,
		CAMPAIGN_EDITOR.loadErrorHandler
	)
	if success then
		self.child:addTab(editor)
		self.child:setActiveTab(editor)
		--remember we opened this one
		Storage.lastCampaignOpened = {
			when = os.time(),
			subpath = subpath,
		}
		Storage.save()
	end
end

function UI:closeEditor(campaignEditor)
	if campaignEditor==self.child:getActiveTab() then
		self.child:setActiveTab(self.levelSelector)
	end
	self.child:removeTab(campaignEditor)
end


return UI