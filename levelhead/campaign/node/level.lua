local ZoneData = require("levelhead.data.zones")
local Level = require("levelhead.level.level")

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
	self:setLevelRaw(level)
	self:setLevelMetadata()
end

function L:setLevelRaw(level)
	-- on init level gets set to a string containing the id until the campaign loading gives us the proper level
	-- so make sure the level has actually been properly loaded before using it
	if self.level and type(self.level)=="table" then
		self.level:removeNodeRaw(self)
	end
	self.level = level
	level:addNodeRaw(self)
end

function L:setLevelMetadata()
	if not self.level then
		return
	end
	local lhs = self.level:getLHS()
	
	lhs:readHeaders()
	local settings, width, height = lhs:parseHeaders()
	
	self.title = settings:getTitle()
	self.weather = settings.weather
	self.zoneId = settings.zone
	-- scale
	local max = math.max(width, height)
	local f = 86 + 2/3
	self.scale = (max+f)/(255+f)
	
	-- has GR17
	-- has bugs
	
end

function L:getZone()
	return ZoneData:getName(self.zoneId)
end

function L:getRadius()
	return L.super.getRadius(self) * (self.scale or 1)
end

return L