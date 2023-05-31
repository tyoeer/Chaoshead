--- Represents a node that the player can travel to as a destination
---@class CampaignVisitableNode : CampaignNode
---@field super CampaignNode
---@field title string
---@field mainPath boolean?
---@field secret boolean
---@field secretPrevPaths boolean
---@field secretNextPaths boolean
---@field requiresBugs boolean
---@field requiresAllLevels boolean
---@field requiresJems boolean
---@field requiresGr17 boolean
local V = Class("CampaignVisitableNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	title = "n",
	mainPath = V.mapBool("main", true),
	
	secret = V.mapBool("sc"),
	secretPrevPaths = V.mapBool("scpre"),
	secretNextPaths = V.mapBool("scpost"),
	
	requiresBugs = V.mapBool("pre_gr18"),
	requiresAllLevels = V.mapBool("pre_all"), --TODO investigate how this interacts with requiring just Jems or bugs (when it's false)
	requiresJems = V.mapBool("pre_coin"),
	requiresGr17 = V.mapBool("pre_chall"),
}

function V:getLabel()
	if self.title~="" then
		return self.title
	else
		return V.super.getLabel(self)
	end
end

function V:initialize(id)
	V.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

return V