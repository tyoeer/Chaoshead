local TABS = require("ui.tools.tabs")
local SELECTOR = require("campaignEditor.overview.selector")
local CAMPAIGN_ROOT = require("campaignEditor.campaignRoot")

local UI = Class("CampaignSelectorUI",require("ui.base.proxy"))

function UI:initialize()
	-- self.clipboard = nil
	
	local tabs = TABS:new()
	
	self.selector = SELECTOR:new(self)
	tabs:addTab(self.selector)
	
	--TabsUI needs buttons before getting resized (which always happens when added)
	UI.super.initialize(self,tabs)
	self.title = "Campaigns (WIP)"
end


function UI:openEditor(subpath)
	--open the editor
	local success, editor = xpcall(
		function()
			return CAMPAIGN_ROOT:new(subpath, self)
		end,
		require("levelEditor.levelRoot").loadErrorHandler
	)
	if success then
		self.child:addTab(editor)
		self.child:setActiveTab(editor)
		--remember we opened this one
		Storage.lastCampaignOpened = {
			when = os.time(),
			subpath = subpath,
		}
		Storage:save()
	end
end

function UI:closeEditor(campaignEditor)
	if campaignEditor==self.child:getActiveTab() then
		self.child:setActiveTab(self.selector)
	end
	self.child:removeTab(campaignEditor)
end

function UI:onVisible(visible)
	if visible and not Storage.campaignWarningAt then
		MainUI:popup("WARNING: the default ids used to save campaign progress given to new stuff are random, and might cause interference in the future.\nBe careful when not using a guest account.")
		Storage.campaignWarningAt = os.time()
		Storage:save()
	end
end

return UI
