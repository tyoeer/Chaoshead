local L = Class("CampaignLevel")

function L:initialize(id)
	self.id = id
	-- self.campaign
end

function L:getPath()
	return self.campaign.path..self.campaign.SUBPATHS.levels..self.id..".lhs"
end

return L