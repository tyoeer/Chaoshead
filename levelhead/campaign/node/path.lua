local P = Class("CampaignPathNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	prevLevel = {
		"pre_actual",
		-- from gets handled in campaign loading logic
		to = function(node)
			return node.id
		end
	},
	nextLevel = {
		"post_actual",
		-- from gets handled in campaign loading logic
		to = function(node)
			return node.id
		end
	},
}

function P:initialize(id)
	P.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function P:getRadius()
	return 16 -- TODO magic number
end

return P