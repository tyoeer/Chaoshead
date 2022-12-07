local LHS = require("levelhead.lhs")
local EP = require("libs.tyoeerUtils.entityPool")

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

return L