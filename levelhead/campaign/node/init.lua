local N = Class("CampaignNode",require("levelhead.campaign.mapped"))

local MAPPINGS = {
	x = "x",
	y = "y",
	prev = {
		"pre",
		-- strings get replaced with references in campaign loading logic
	},
	type = {
		"t",
		from = function(raw)
			return ({
				[0] = "level",
				"icon pack",
				"path",
				"presentation"
			})[raw] or "$UnknownNodeType"
		end,
		--TODO to
	},
}

function N:initialize(id)
	self.id = id
	
	self.prev = {}
	self.next = {}
	
	self.x = 0
	self.y = 0
	N.super.initialize(self, MAPPINGS)
end

function N:newFromMapped(id, data)
	if data.t==0 then
		local n = require("levelhead.campaign.node.level"):new(id)
		n:fromMapped(data)
		return n
	elseif data.t==2 then
		local n = require("levelhead.campaign.node.path"):new(id)
		n:fromMapped(data)
		return n
	else
		local n = self:new(id)
		n:fromMapped(data)
		return n
	end
end

return N