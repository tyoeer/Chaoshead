local P = Class("CampaignPathNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	prevLevel = {
		"pre_actual",
		from = function(str)
			if str=="" then
				return nil
			else
				-- associating with the proper node gets handled in campaign loading logic
				return str
			end
		end,
		to = function(node)
			return node.id
		end
	},
	nextLevel = {
		"post_actual",
		from = function(str)
			if str=="" then
				return nil
			else
				-- associating with the proper node gets handled in campaign loading logic
				return str
			end
		end,
		to = function(node)
			return node.id
		end
	},
}

function P:initialize(id)
	P.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end


return P