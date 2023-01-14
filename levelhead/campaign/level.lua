local LHS = require("levelhead.lhs")
local EP = require("libs.tyoeerUtils.entitypool")

---@class Campaignlevel : Mapped
---@field super Mapped
---@field campaign Campaign?
---@field new fun(self, id: string): self
local L = Class("CampaignLevel", require("levelhead.campaign.mapped"))

local MAPPINGS = {
	id = "id",
	file = "file",
}

function L:initialize(id, path)
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

function L:getHeaders()
	local lhs = self:getLHS()
	lhs:readHeaders()
	return lhs:parseHeaders()
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

return L