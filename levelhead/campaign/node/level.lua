local N = Class("CampaignLevelNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	-- TODO requirements
	scale = "scale",
}

function N:initialize(id)
	N.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
	
end

return N