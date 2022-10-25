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