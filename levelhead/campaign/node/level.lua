local ZoneData = require("levelhead.data.zones")

---@class CampaignLevelNode : CampaignVisitableNode
---@field super CampaignVisitableNode
---@field level CampaignLevel|string|nil
---@field onTimeDelivery number?
---@field scale number?
---@field weather boolean?
---@field zoneId number?
---@field hasGr17 boolean?
---@field hasBugs boolean?
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
			if type(level)=="table" then
				return level.id
			elseif type(level)=="string" then
				return level
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
		self.level--[[@as CampaignLevel]]:removeNodeRaw(self)
	end
	self.level = level
	level:addNodeRaw(self)
end

function L:setLevelMetadata()
	if not self.level or type(self.level)=="string" then
		return
	end
	
	local meta = self.level--[[@as CampaignLevel]]:getMetadata()
	if not meta then
		return
	end
	
	self.title = meta.title
	self.weather = meta.weather
	self.zoneId = meta.zone
	-- scale
	local max = math.max(meta.width, meta.height)
	local f = 86 + 2/3
	self.scale = (max+f)/(255+f)
	
	--has GR-17 and/or bugs
	self.hasBugs = meta.bugs
	self.hasGr17 = meta.gr17
end

function L:getZone()
	return ZoneData:getName(self.zoneId)
end

function L:getRadius()
	return L.super.getRadius(self) * (self.scale or 1)
end

return L