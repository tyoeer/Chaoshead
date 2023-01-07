local Details = require("campaignEditor.levelDetails")

local UI = Class("CampaignLevelSelectorUI", require("ui.tools.treeViewer"))

function UI:initialize(root)
	self.root = root
	UI.super.initialize(self)
	self.title = "Levels"
end

function UI:getRootEntries()
	local out = {}
	
	for level in self.root.campaign.levels:iterate() do
		table.insert(out,{
			level = level,
			title = level.id
		})
	end
	
	table.sort(out, function(a,b)
		return a.title < b.title
	end)
	
	return out
end

function UI:getDetailsUI(data)
	return Details:new(self.root, data.level)
end

return UI
