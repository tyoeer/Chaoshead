local CampaignMisc = require("campaignEditor.misc")

local UI = Class("CampaignDetailsUI",require("ui.tools.details"))

function UI:initialize(campaign,editor)
	self.editor = editor
	self.campaign = campaign
	UI.super.initialize(self)
	self.title = "Campaign Info"
end

function UI:onReload(list,campaign)
	if campaign then
		self.campaign = campaign
	else
		campaign = self.campaign
	end
	list:resetList()
	
	list:addButtonEntry(
		"Save Campaign",
		function()
			self.editor.root:save()
		end
	)
	list:addButtonEntry(
		"Reload Campaign",
		function()
			self.editor.root:reload()
		end
	)
	list:addButtonEntry(
		"Close campaign (without saving)",
		function()
			self.editor.root:close()
		end
	)
	
	list:addSeparator(true)
	
	list:addButtonEntry(
		"Pack campign",
		function()
			CampaignMisc.pack(self.editor.root.path)
		end
	)
	list:addButtonEntry(
		"Pack campign and mod levelhead to use it",
		function()
			CampaignMisc.packAndMove(self.editor.root.path)
		end
	)
	
	list:addSeparator(true)
	
	-- list:addButtonEntry( -- TODO limits check
	-- 	"Check level limits",
	-- 	function()
	-- 		if self.editor.root:checkLimits() then
	-- 			MainUI:displayMessage("Level doesn't break any limits!")
	-- 		end
	-- 	end
	-- )
	
	list:addButtonEntry(
		"Replace map with map from in-game editor",
		function()
			self.editor:importGameMap()
		end
	)

	-- versions
	list:addTextEntry("Campaign version: "..campaign.campaignVersion)
	list:addTextEntry("Content version: "..campaign.contentVersion)
end

return UI
