---@class CampaignPresentationNode : CampaignVisitableNode
---@field super CampaignVisitableNode
---@field presentation string
local P = Class("CampaignPresentationNode",require("levelhead.campaign.node.visitable"))

local MAPPINGS = {
	presentation = "dat",
}

function P:initialize(id)
	P.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end


return P