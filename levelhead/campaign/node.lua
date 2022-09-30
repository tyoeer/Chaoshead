local N = Class("CampaignNode",require("levelhead.campaign.mapped"))

local MAPPINGS = {
	x = "x",
	y = "y",
}

function N:initialize(id)
	self.id = id
	
	self.prev = {}
	self.next = {}
	
	self.x = 0
	self.y = 0
	N.super.initialize(self, MAPPINGS)
end

return N