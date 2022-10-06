local N = Class("CampaignPathNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	-- TODO to
	prevLevel = "pre_actual",
	nextLevel = "post_actual"
}

function N:initialize(id)
	N.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function N:getRadius()
	return 16 -- TODO magic number
end

return N