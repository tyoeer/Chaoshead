local EP = require("libs.tyoeerUtils.entityPool")
local JSON = require("libs.json")
local Node = require("levelhead.campaign.node")
local LevelNode = require("levelhead.campaign.node.level")

local C = Class("Campaign")

function C:initialize(path)
	if path then
		if path:sub(-1)~="/" then
			path = path.."/"
		end
		self.path = path
	end
	
	-- self.nodes
	-- self.nodesById
	self:clearNodes()
	
	self.campaignVersion = 0
	self.contentVersion = "0"
end

function C:getNode(id)
	return self.nodesById[id]
end

--- Returns a single node at
function C:getNodeAt(x,y)
	for node in self.nodes:iterate() do
		local distSq = (node.x-x)^2 + (node.y-y)^2
		if distSq < node:getRadius()^2 then
			return node
		end
	end
end

function C:nodeRectangeOverlap(node, rectCenterX,rectCenterY, halfWidth,halfHeight)
	-- rectangle <-> circle collision based on https://stackoverflow.com/a/402010
	local r = node:getRadius()
	local dx, dy = math.abs(node.x - rectCenterX), math.abs(node.y - rectCenterY)
	
	--check too far away
	if dx > halfWidth + r then return false end
	if dy > halfHeight + r then return false end
	
	--far enough from corner that it's easy to know
	if dx <= halfWidth then return true end
	if dy <= halfHeight then return true end
	
	-- check distance to corner
	local cornerDistSq = (dx-halfWidth)^2 + (dy-halfHeight)^2
	return cornerDistSq <= r^2
end

function C:getNodesIn(startX, startY, endX, endY)
	local out = {}
	
	--rectangle center
	local rectCenterX, rectCenterY = (endX+startX)/2, (endY+startY)/2
	--half width/height
	local halfWidth, halfHeight = (endX-startX)/2, (endY-startY)/2
	
	for node in self.nodes:iterate() do
		if self:nodeRectangeOverlap(node, rectCenterX,rectCenterY, halfWidth,halfHeight) then
			table.insert(out, node)
		end
	end
	
	return out
end

function C:addNode(node)
	self.nodes:add(node)
	self.nodesById[node.id] = node
end

function C:newNode(id)
	id = id or "CH_$WhatHaveYouDone"
	local n = Node:new(id)
	self:addNode(n)
	return n
end

function C:newLevelNode(id)
	id = id or "CH_$WhatHaveYouDone"
	local n = LevelNode:new(id)
	self:addNode(n)
	return n
end

function C:clearNodes()
	self.nodes = EP:new()
	self.nodesById = {}
end

-- LOADING

function C:loadData(name)
	local path = self.path.."data/"..name..".json"
	local data, err = love.filesystem.read(path)
	if not data then
		error(string.format("Error reading %s data at %s:\n%s", name,path, err), 3)
	end
	return JSON.decode(data)
end

function C:reloadNodes()
	local rawData = self:loadData("nodes")
	
	self:clearNodes()
	
	-- load nodes
	for id,data in pairs(rawData) do
		local n = Node:newFromMapped(id, data)
		self:addNode(n)
	end
	
	-- fix connections
	for node in self.nodes:iterate() do
		for i,preId in ipairs(node.prev) do
			local prevNode = self:getNode(preId)
			node.prev[i] = prevNode
			table.insert(prevNode.next, node)
		end
		if node.type=="path" then
			node.prevLevel = self:getNode(node.prevLevel)
			node.nextLevel = self:getNode(node.nextLevel)
		end
	end
end

function C:reloadVersions()
	local raw = self:loadData("versions")
	
	self.campaignVersion = raw.campaign_version
	self.contentVersion = raw.content_version
end

function C:reload(path)
	if path then
		if path:sub(-1)~="/" then
			path = path.."/"
		end
		self.path = path
	end
	
	self:reloadVersions()
	self:reloadNodes()
end

-- SAVING

function C:saveData(name, data)
	local path = self.path.."data/"..name..".json"
	local data, err = love.filesystem.write(path, JSON.encode(data))
	if not data then
		error(string.format("Error writing %s data at %s:\n%s", name,path, err), 3)
	end
end

function C:saveNodes()
	local data = {}
	for node in self.nodes:iterate() do
		data[node.id] = node:toMapped()
	end
	
	self:saveData("nodes", data)
end

function C:saveVersions()
	self:saveData("versions", {
		campaign_version = self.campaignVersion,
		content_version = self.contentVersion,
	})
end

function C:save(path)
	if path then
		if path:sub(-1)~="/" then
			path = path.."/"
		end
		self.path = path
	end
	
	self:saveVersions()
	self:saveNodes()
end

return C