local CampaignMisc = require("campaignEditor.misc")
local JSON = require("libs.json")

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
	list:addButtonEntry(
		"Open in level-kit",
		function()
			MainUI:getString("Enter [name] % [code]", function(str)
				local name, code = str:match("(.+) %% (.+)$")
				local out = {
					creatorName = name,
					creatorCode = code,
					campaignName = self.editor.campaign.path:match("([^/\\]+)/?$"),
					version = self.editor.campaign.campaignVersion,
					mapNodes = {},
				}
				for node in self.editor.campaign.nodes:iterate() do
					local outNode = node:toMapped()
					outNode.levelID = node.id
					-- outNode.dat = nil -- not used
					table.insert(out.mapNodes, outNode)
				end
				
				local url = "https://level-kit.netlify.app/customcampaigns/?userCampaign="..JSON.encode(out)
				love.system.setClipboardText(url)
				local success = love.system.openURL(url:gsub("\"","\\\"")) -- Least amount of URL encoding that still works
				
				MainUI:popup("Copied to clipboard + ".. (success and "oepend" or "failed to open") .." in browser")
			end)
		end
	)
	
	list:addSeparator(true)
	
	list:addButtonEntry(
		"Replace map with map from in-game editor",
		function()
			self.editor:importGameMap()
		end
	)
	
	list:addSeparator(true)
	
	list:addButtonEntry(
		"Run campaign checks",
		function()
			if self.editor.root:runChecks() then
				MainUI:popup("Campaign passes all checks")
			end
		end
	)

	-- versions
	list:addTextEntry("Campaign version: "..campaign.campaignVersion)
	list:addTextEntry("Content version: "..campaign.contentVersion)
end

return UI
