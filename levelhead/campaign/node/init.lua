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
	local n
	if data.t==0 then
		n = require("levelhead.campaign.node.level"):new(id)
	elseif data.t==1 then
		n = require("levelhead.campaign.node.iconPack"):new(id)
	elseif data.t==2 then
		n = require("levelhead.campaign.node.path"):new(id)
	elseif data.t==3 then
		n = require("levelhead.campaign.node.presentation"):new(id)
	else
		n = self:new(id)
	end
	n:fromMapped(data)
	return n
end

function N:getRadius()
	return 32 -- TODO magic number
end


return N