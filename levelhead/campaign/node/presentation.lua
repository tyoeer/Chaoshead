local P = Class("CampaignPresentationNode",require("levelhead.campaign.node.visitable"))

local MAPPINGS = {
	presentation = "dat",
}

function P:initialize(id)
	P.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function P:getRadius()
	return 32 -- TODO magic number
end

return P