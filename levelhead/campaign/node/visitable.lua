-- Represents a node that the player can travel to as a destination
local V = Class("CampaignVisitableNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	title = "n",
	mainPath = V.mapBool("main", true),
	
	secret = V.mapBool("sc"),
	secretPrevPaths = V.mapBool("scpre"),
	secretNextPaths = V.mapBool("scpost"),
	
	requiresBugs = V.mapBool("pre_gr18"),
	requiresAll = V.mapBool("pre_all"), --TODO investigate how this interacts with requiring all Jems (when it's false)
	requiresJems = V.mapBool("pre_coin"),
	requiresGr17 = V.mapBool("pre_chall"),
}

function V:initialize(id)
	V.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

return V