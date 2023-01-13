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


function UI:selectLevel(level)
	self:setDetailsUI(Details:new(self.root, level))
end


function UI:levelChanged(level)
	if not level or level==self.details.level then
		self.details:reload()
	end
end

function UI:reload()
	-- self.details starts out as a placeholder BaseUI, if it has a level it is the proper details UI
	if self.details.level then
		-- Can't use campaign:getLevel(), it errors if it doesn't find the level
		local level = self.root.campaign.levelsById[self.details.level.id]
		if level then
			self.details:reload(level)
		else
			self:resetDetails()
		end
	end
	UI.super.reload(self)
end

return UI
