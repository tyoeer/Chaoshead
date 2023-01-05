local ZoneData = require("levelhead.data.zones")

local L = Class("CampaignLevelNode",require("levelhead.campaign.node.visitable"))

local MAPPINGS = {
	level = {
		"dat",
		optional = true,
		from = function(str)
			if str=="" then
				return nil
			else
				-- associating with the proper level gets handled in campaign loading logic
				return str
			end
		end,
		to = function(level)
			if level then
				return level.id
			else
				return ""
			end
		end
	},
	
	onTimeDelivery = {
		"b_time",
		optional = true,
	},
	
	scale = {
		"scale", -- TODO other nodes with this
		optional = true,
	},
	weather = L.mapBool("weather", true),
	zoneId = {
		"bm",
		optional = true,
	},
	
	hasGr17 = L.mapBool("ch", true),
	hasBugs = L.mapBool("gr18", true),
}

function L:initialize(id)
	L.super.initialize(self, id)
	self:extendMappings(MAPPINGS)
end

function L:setLevel(level)
	if self.level and type(self.level)=="table" then
		self.level:removeNodeRaw(self)
	end
	self.level = level
	level:addNodeRaw(self)
end

function L:getZone()
	return ZoneData:getName(self.zoneId)
end

function L:getRadius()
	return L.super.getRadius(self) * (self.scale or 1)
end

return L