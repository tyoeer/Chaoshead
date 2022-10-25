local ZoneData = require("levelhead.data.zones")

local L = Class("CampaignLevelNode",require("levelhead.campaign.node.visitable"))

local MAPPINGS = {
	level = "dat",
	
	onTimeDelivery = "b_time",
	
	scale = "scale", -- TODO other nodes with this
	weather = L.mapBool("weather"),
	zoneId = "bm",
	
	hasGr17 = L.mapBool("ch"),
	hasBugs = L.mapBool("gr18"),
}

function L:initialize(id)
	L.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function L:getZone()
	return ZoneData:getName(self.zoneId)
end

function L:getRadius()
	return L.super.getRadius(self) * self.scale
end

return L