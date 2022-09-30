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
	for id,data in pairs(rawData) do
		local n = self:newNode(id)
		n:fromMapped(data)
	end
	
	for id,data in pairs(rawData) do
		local node = self:getNode(id)
		for _,preId in ipairs(data.pre) do
			local prev = self:getNode(preId)
			table.insert(node.prev, prev)
			table.insert(prev.next, node)
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