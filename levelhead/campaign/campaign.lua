local EP = require("libs.tyoeerUtils.entityPool")
local JSON = require("libs.json")
local Node = require("levelhead.campaign.node")

local C = Class("Campaign")

function C:initialize()
	self.nodes = EP:new()
	self.nodesById = {}
end

function C:getNode(id)
	return self.nodesById[id]
end

function C:newNode(id)
	id = id or "CH_$WhatHaveYouDone"
	local n = Node:new(id)
	self.nodes:add(n)
	self.nodesById[id] = n
	return n
end



function C:loadNodes(rawData)
	-- load nodes
	for id,data in pairs(rawData) do
		local n = self:newNode(id)
		n:fromMapped(data)
	end
	
	-- fix connections
	for node in self.nodes:iterate() do
		for i,preId in ipairs(node.prev) do
			local prevNode = self:getNode(preId)
			node.prev[i] = prevNode
			table.insert(prevNode.next, node)
		end
	end
end

function C:load(path)
	if path:sub(-1)~="/" then
		path = path.."/"
	end
	local nodes, err = love.filesystem.read(path.."data/nodes.json")
	if not nodes then
		error("Error reading nodes: "..err,2)
	end
	self:loadNodes(JSON.decode(nodes))
end


return C