local P = Class("CampaignPathNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	-- TODO to
	prevLevel = "pre_actual",
	nextLevel = "post_actual"
}

function P:initialize(id)
	P.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function P:getRadius()
	return 16 -- TODO magic number
end

return P