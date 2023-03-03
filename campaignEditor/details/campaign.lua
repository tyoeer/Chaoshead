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
		"Pack campaign",
		function()
			CampaignMisc.pack(self.editor.root.path)
		end
	)
	list:addButtonEntry(
		"Pack campaign and mod levelhead to use it",
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
					campaignName = self.editor.campaign:getName(),
					version = self.editor.campaign.campaignVersion,
					mapNodes = {},
				}
				
				local function getId(node)
					if node.type=="level" then
						if type(node.level)=="table" then
							return node.level.rumpusCode or node.id
						else
							return node.id
						end
					else
						return node.id
					end
				end
				for node in self.editor.campaign.nodes:iterate() do
					local outNode = node:toMapped()
					outNode.levelID = getId(node)
					-- outNode.dat = nil -- not used
					for i,nodeId in ipairs(outNode.pre) do
						outNode.pre[i] = getId(self.editor.campaign:getNode(nodeId))
					end
					
					table.insert(out.mapNodes, outNode)
				end
				
				local json = JSON.encode(out)
				
				local url = "https://level-kit.netlify.app/customcampaigns/?userCampaign="..json
				love.system.setClipboardText(json)
				local success = love.system.openURL(url:gsub("\"","\\\"")) -- Least amount of URL encoding that still works
				
				MainUI:popup("Copied JSON to clipboard + ".. (success and "opened" or "failed to open") .." URL in browser")
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
