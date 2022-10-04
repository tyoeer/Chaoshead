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

function C:reloadNodes()
	local nodes, err = love.filesystem.read(self.path.."data/nodes.json")
	if not nodes then
		error("Error reading nodes: "..err, 2)
	end
	local rawData = JSON.decode(nodes)
	
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
			node.prevActual = self:getNode(node.prevActual)
			node.nextActual = self:getNode(node.nextActual)
		end
	end
end

function C:reload(path)
	if path then
		if path:sub(-1)~="/" then
			path = path.."/"
		end
		self.path = path
	end
	
	self:reloadNodes()
end


return C