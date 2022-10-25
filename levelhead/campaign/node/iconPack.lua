local I = Class("CampaignIconPackNode",require("levelhead.campaign.node.visitable"))

local MAPPINGS = {
	unlocks = "dat" -- TODO reverse engineer all the subfields
}

function I:initialize(id)
	I.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end


return I