local LHS = require("levelhead.lhs")
local EP = require("libs.tyoeerUtils.entitypool")
local ElemData = require("levelhead.data.elements")

--- Maps from an element id to to which field in the metadata indiciates its presence
local COLLECTABLE_ID_MAP = {
	[ElemData:getID("Stranded GR17")] = "gr17",
	[ElemData:getID("Bug Head")] = "bugs",
	[ElemData:getID("Bug Body Right")] = "bugs",
	[ElemData:getID("Bug Body Left")] = "bugs",
	[ElemData:getID("Bug Abdomen")] = "bugs",
}

---@class CampaignLevelMetadata Information about the actual level file
---@field title string
---@field width number
---@field height number
---@field weather boolean If this level has weather effects enabled
---@field zone number Id of the zone this level uses
---@field bugs boolean If this levels has collectable bugs
---@field gr17 boolean If this levels has a collectable GR-17
---@field campaignMarker boolean If the CampaigMarker has been set on this level

---@class Campaignlevel : Mapped
---@field super Mapped
---@field campaign Campaign?
---@field metadata CampaignLevelMetadata?
---@field file string
---@field id string
---@field nodes unknown
---@field new fun(self, id: string): self
local L = Class("CampaignLevel", require("levelhead.campaign.mapped"))

local MAPPINGS = {
	id = "id",
	file = "file",
	metadata = {
		"cachedMetadata",
		optional = true,
	}
}

function L:initialize(id)
	L.super.initialize(self, MAPPINGS)
	self.id = id
	self.file = id..".lhs"
	self.nodes = EP:new()
	-- self.campaign
end

function L:addNodeRaw(node)
	self.nodes:add(node)
end
function L:removeNodeRaw(node)
	self.nodes:remove(node)
end

function L:getPath()
	return self.campaign.path..self.campaign.SUBPATHS.levels..self.file
end

function L:getLHS()
	return LHS:new(love.filesystem.getSaveDirectory().."/"..self:getPath())
end

function L:getLabel()
	if self.metadata then
		return self.metadata.title
	else
		return self.id
	end
end


function L:setId(id)
	self.campaign.levelsById[self.id] = nil
	self.campaign.levelsById[id] = self
	self.id = id
end

--- The file will be renamed directly on disk, though the change in data still has to be saved
---@return boolean success, string? errorMessage
function L:renameFile(name)
	local oldPath = self:getPath()
	local oldFile = self.file
	self.file = name
	local newPath = self:getPath()
	local _success, err = os.rename(love.filesystem.getSaveDirectory().."/"..oldPath, love.filesystem.getSaveDirectory().."/"..newPath)
	if err then
		self.id = oldFile
		return false, err
	else
		return true
	end
end


function L:loadMetadata()
	local lhs = self:getLHS()
	
	lhs:readHeaders()
	local settings, width, height = lhs:parseHeaders()
	
	local metadata = {
		title = settings:getTitle(),
		weather = settings.weather,
		zone = settings.zone,
		
		width = width,
		height = height,
		
		bugs = false,
		gr17 = false,
		
		campaignMarker = settings.campaignMarker==1
	}
	
	--Directly read raw content entries to save time parsing
	lhs:readSingle("singleForeground")
	for _, entry in ipairs(lhs.rawContentEntries.singleForeground.entries) do
		local prop = COLLECTABLE_ID_MAP[entry.id]
		if prop then
			metadata[prop] = true
		end
	end
	
	--Only set at the end in case of errors reading the file
	self.metadata = metadata
end

---@return CampaignLevelMetadata?
function L:getMetadata()
	return self.metadata
end


return L