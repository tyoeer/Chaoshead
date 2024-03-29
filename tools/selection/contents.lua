local Set = require("utils.orderedSet")
local E = require("levelhead.data.elements")
local P = require("levelhead.data.properties")

---@class PropertyList : Class
---@field new fun(self, propertyId: integer): self
local PL = Class("PropertyList")
do
	---@param propertyId integer
	function PL:initialize(propertyId)
		self.pool = Set:new()
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
	
	function PL:isRangeProperty()
		local mapping = P:getMappingType(self.propId)
		return mapping=="Hybrid" or mapping=="None"
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
	--- Skips property bounds recalculation
	function PL:removeBatch(obj)
		self.pool:remove(obj)
	end
end

---@class SelectionContents : Class
local C = Class("SelectionContents")

function C:initialize()
	self.foreground = Set:new()
	self.background = Set:new()
	self.pathNodes = Set:new()
	--DEPRECATED: OrderedSets used to not track their count/size
	self.nForeground = 0
	self.nBackground = 0
	self.nPathNodes = 0
	
	--how many nodes of a given path we have
	--used to keep track of when to add/remove the paths properties
	self.pathNodeAmountMap = {}
	
	self.properties = {}
	self.unknownProperties = Set:new()
end

function C:endBatchRemove()
	for prop,pl in pairs(self.properties) do
		if pl:isEmpty() then
			self.properties[prop] = nil
		else
			pl:findBounds()
		end
	end
end

function C:removeLayer(layer)
	if layer=="foreground" then
		for obj in self.foreground:iterate() do
			self:removeObjectPropertiesBatch(obj)
		end
		self:endBatchRemove()
		self.nForeground = 0
		self.foreground = Set:new()
	elseif layer=="background" then
		self.nBackground = 0
		self.background = Set:new()
	elseif layer=="pathNodes" then
		for node in self.pathNodes:iterate() do
			self:removePathNodePropertiesBatch(node)
		end
		self:endBatchRemove()
		self.nPathNodes = 0
		self.pathNodes = Set:new()
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
--- Skips property bounds recalculation
function C:removeForegroundBatch(obj)
	self.foreground:remove(obj)
	self:removeObjectPropertiesBatch(obj)
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
--- Skips property bounds recalculation
function C:removePathNodeBatch(node)
	self.pathNodes:remove(node)
	self:removePathNodePropertiesBatch(node)
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
--- Skips property bounds recalculation
function C:removeThingPropertiesBatch(thing)
	for prop in thing:iterateProperties() do
		self.properties[prop]:removeBatch(thing)
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
--- Skips property bounds recalculation
function C:removeObjectPropertiesBatch(obj)
	if obj:hasProperties() then
		self:removeThingPropertiesBatch(obj)
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
--- Skips property bounds recalculation
function C:removePathNodePropertiesBatch(node)
	local path = node.path
	if self.pathNodeAmountMap[path]==1 then
		self:removeThingPropertiesBatch(path)
		self.pathNodeAmountMap[path] = nil
	else
		self.pathNodeAmountMap[path] = self.pathNodeAmountMap[path] - 1
	end
end

return C
