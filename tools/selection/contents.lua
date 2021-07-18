local EP = require("libs.tyoeerUtils.entitypool")
local E = require("levelhead.data.elements")

--PropertyLists
local PL = Class()
do
	function PL:initialize(propertyId)
		self.pool = EP:new()
		self.propId = propertyId
		self.max = -math.huge
		self.min = math.huge
	end
	
	function PL:findBounds()
		local max = -math.huge
		local min = math.huge
		for obj in self.pool:iterate() do
			local val = obj:getPropertyRaw(self.propId)
			if val < min then min = val end
			if val > max then max = val end
		end
		self.max = max
		self.min = min
	end
	
	function PL:isEmpty()
		return self.pool:getTop()==nil
	end
	
	function PL:add(obj)
		self.pool:add(obj)
		local val = obj:getPropertyRaw(self.propId)
		if val < self.min then self.min = val end
		if val > self.max then self.max = val end
	end
	
	function PL:remove(obj)
		self.pool:remove(obj)
		local val = obj:getPropertyRaw(self.propId)
		if val == self.min or val == self.max then
			self:findBounds()
		end
	end
end


local C = Class()

function C:initialize()
	self.foreground = EP:new()
	self.background = EP:new()
	self.pathNodes = EP:new()
	--EntityPools currently don't track their size
	self.nForeground = 0
	self.nBackground = 0
	self.nPathNodes = 0
	
	--how many nodes of a given path we have
	--used to keep track of when to add/remove the paths properties
	self.pathNodeAmountMap = {}
	
	self.properties = {}
	self.unknownProperties = EP:new()
end

function C:removeLayer(layer)
	if layer=="foreground" then
		for obj in self.foreground:iterate() do
			self:removeObjectWithProperties(obj)
		end
		self.nForeground = 0
		self.foreground = nil
	elseif layer=="background" then
		self.nBackground = 0
		self.background = nil
	elseif layer=="pathNodes" then
		self.nPathNodes = 0
		self.pathNodes = nil
	else
		error(string.format("Invalid layer: %q",layer))
	end
end

-- Layer-related Adding/Removing

function C:addForeground(obj)
	self.foreground:add(obj)
	self:addObjectProperties(obj)
	self.nForeground = self.nForeground + 1
end
function C:removeForeground(obj)
	self.foreground:remove(obj)
	self:removeObjectProperties(obj)
	self.nForeground = self.nForeground - 1
end

function C:addBackground(obj)
	self.background:add(obj)
	self.nBackground = self.nBackground + 1
end
function C:removeBackground(obj)
	self.background:remove(obj)
	self.nBackground = self.nBackground - 1
end

function C:addPathNode(node)
	self.pathNodes:add(node)
	self:addPathNodeProperties(node)
	self.nPathNodes = self.nPathNodes + 1
end
function C:removePathNode(node)
	self.pathNodes:remove(node)
	self:removePathNodeProperties(node)
	self.nPathNodes = self.nPathNodes - 1
end

-- Property stuff

function C:addThingProperties(thing)
	for prop in thing:iterateProperties() do
		if not self.properties[prop] then
			self.properties[prop] = PL:new(prop)
		end
		self.properties[prop]:add(thing)
	end
end

function C:addObjectProperties(obj)
	if obj:hasProperties() then
		self:addThingProperties(obj)
	end
	--keep track of the ones with missing data
	if E:hasProperties(obj.id)=="$UnknownProperties" then
		self.unknownProperties:add(obj)
	end
end

function C:addPathNodeProperties(node)
	local path = node.path
	if self.pathNodeAmountMap[path] then
		self.pathNodeAmountMap[path] = self.pathNodeAmountMap[path] + 1
	else
		self.pathNodeAmountMap[path] = 1
		self:addThingProperties(path)
	end
end


function C:removeThingProperties(thing)
	for prop in thing:iterateProperties() do
		self.properties[prop]:remove(thing)
		if self.properties[prop]:isEmpty() then
			self.properties[prop] = nil
		end
	end
end

function C:removeObjectProperties(obj)
	if obj:hasProperties() then
		self:removeThingProperties(obj)
	end
	--keep track of the ones with missing data
	if E:hasProperties(obj.id)=="$UnknownProperties" then
		self.unknownProperties:remove(obj)
	end
end

function C:removePathNodeProperties(node)
	local path = node.path
	if self.pathNodeAmountMap[path]==1 then
		self:removeThingProperties(path)
		self.pathNodeAmountMap[path] = nil
	else
		self.pathNodeAmountMap[path] = self.pathNodeAmountMap[path] - 1
	end
end

return C
