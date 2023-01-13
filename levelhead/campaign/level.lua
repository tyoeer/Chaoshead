local LHS = require("levelhead.lhs")
local EP = require("libs.tyoeerUtils.entitypool")

---@class Campaignlevel
---@field campaign Campaign?
---@field new fun(self, id: string): self
local L = Class("CampaignLevel")

function L:initialize(id)
	self.id = id
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
	return self.campaign.path..self.campaign.SUBPATHS.levels..self.id..".lhs"
end

function L:getLHS()
	return LHS:new(love.filesystem.getSaveDirectory().."/"..self:getPath())
end

function L:getHeaders()
	local lhs = self:getLHS()
	lhs:readHeaders()
	return lhs:parseHeaders()
end

--- Changes the id of this level
--- Works directly with files
---@return boolean success, string? errorMessage
function L:changeId(name)
	local oldPath = self:getPath()
	local oldId = self.id
	self.id = name
	local newPath = self:getPath()
	local _success, err = os.rename(love.filesystem.getSaveDirectory().."/"..oldPath, love.filesystem.getSaveDirectory().."/"..newPath)
	if err then
		self.id = oldId
		return false, err
	else
		self.campaign.levelsById[oldId] = nil
		self.campaign.levelsById[self.id] = self
		return true
	end
end

return L