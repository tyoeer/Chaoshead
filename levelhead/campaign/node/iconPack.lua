local I = Class("CampaignIconPackNode",require("levelhead.campaign.node.visitable"))

local MAPPINGS = {
	-- TODO dat
}

function I:initialize(id)
	I.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function I:getRadius()
	return 32 -- TODO magic number
end

return I