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
			MainUI:getString("Enter [name] % [code] +[modifier] (there're defaults for quick testing)", function(str)
				local exportPaths = false
				local subStr = str
				local mod
				while subStr do
					subStr, mod = str:match("(.*)%+([^+]-)$")
					if subStr and mod then
						str = subStr
						if mod=="path" or mod=="paths" then
							exportPaths = true
						end
					end
				end
				local name, code = str:match("(.+) ?%% ?(.+)$")
				local cam = self.editor.campaign
				local out = {
					creatorName = string.trim(name or "$Nameless"),
					creatorCode = string.trim(code or "$Codeless"),
					campaignName = cam:getName(),
					version = cam.campaignVersion,
					mapNodes = {},
					landmarks = {},
				}
				
				for _,v in pairs(cam:loadData("landmarks")) do
					table.insert(out.landmarks, v)
				end
				
				---@param node CampaignNode
				local function getId(node)
					if node.type=="level" then
						---@cast node CampaignLevelNode
						if type(node.level)=="table" then
							return node.level.rumpusCode or node.id
						else
							return node.id
						end
					elseif not exportPaths and node.type=="path" then
						---@cast node CampaignPathNode
						return getId(node.prevLevel)
					else
						return node.id
					end
				end
				for node in cam.nodes:iterate() do
					---@cast node CampaignNode
					if node.type=="level" or exportPaths and node.type=="path" then
						local outNode = node:toMapped()
						outNode.levelID = getId(node)
						outNode.dat = nil -- not used
						for i,nodeId in ipairs(outNode.pre) do
							outNode.pre[i] = getId(cam:getNode(nodeId))
						end
						
						table.insert(out.mapNodes, outNode)
					end
				end
				
				local json = JSON.encode(out)
				
				local url = "https://level-kit.netlify.app/customcampaigns/#"..json
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
