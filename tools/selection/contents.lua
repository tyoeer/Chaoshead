local EP = require("libs.tyoeerUtils.entitypool")

local C = Class()

function C:initialize()
	self.foreground = EP:new()
	self.background = EP:new()
	self.pathNodes = EP:new()
	--EntityPools don't track their size because they're too minimalist
	self.nForeground = 0
	self.nBackground = 0
	self.nPathNodes = 0
end

local plurals = {
	foreground = "nForeground",
	background = "nBackground",
	pathNodes = "nPathNodes",
}
function C:removeLayer(layer)
	self[layer] = nil
	self[plurals[layer]] = 0
end


function C:addForeground(obj)
	self.foreground:add(obj)
	self.nForeground = self.nForeground + 1
end

function C:addBackground(obj)
	self.background:add(obj)
	self.nBackground = self.nBackground + 1
end

function C:addPathNode(node)
	self.pathNodes:add(node)
	self.nPathNodes = self.nPathNodes + 1
end

return C
