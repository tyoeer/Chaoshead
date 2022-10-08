local L = Class("CampaignLevelNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	-- TODO requirements
	scale = "scale",
}

function L:initialize(id)
	L.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function L:getRadius()
	return self.scale * 64 -- TODO magic number
end

return L