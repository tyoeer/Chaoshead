---@class CampaignPathNode : CampaignNode
---@field super CampaignNode
---@field prevLevel CampaignNode?
---@field nextLevel CampaignNode?
local P = Class("CampaignPathNode",require("levelhead.campaign.node"))

local MAPPINGS = {
	--TODO: Is this always a level?
	prevLevel = {
		"pre_actual",
		optional = true,
		from = function(str)
			if str=="" then
				return nil
			else
				-- associating with the proper node gets handled in campaign loading logic
				return str
			end
		end,
		to = function(node)
			if node then
				return node.id
			else
				return ""
			end
		end
	},
	nextLevel = {
		"post_actual",
		optional = true,
		from = function(str)
			if str=="" then
				return nil
			else
				-- associating with the proper node gets handled in campaign loading logic
				return str
			end
		end,
		to = function(node)
			if node then
				return node.id
			else
				return ""
			end
		end
	},
}

function P:initialize(id)
	P.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end


return P