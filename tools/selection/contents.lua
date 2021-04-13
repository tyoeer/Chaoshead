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
	
	self.properties = {}
	self.unknownProperties = EP:new()
end

local plurals = {
	foreground = "nForeground",
	background = "nBackground",
	pathNodes = "nPathNodes",
}
function C:clearLayer(layer)
	self[layer] = EP:new()
	self[plurals[layer]] = 0
end

-- Layer-related Adding/Removing

function C:addForeground(obj)
	self.foreground:add(obj)
	self:addObjectWithProperties(obj)
	self.nForeground = self.nForeground + 1
end
function C:removeForeground(obj)
	self.foreground:remove(obj)
	self:removeObjectWithProperties(obj)
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
	self.nPathNodes = self.nPathNodes + 1
end
function C:removePathNode(node)
	self.pathNodes:remove(node)
	self.nPathNodes = self.nPathNodes - 1
end

-- Property stuff

function C:addObjectToPropertyList(obj,prop)
	if not self.properties[prop] then
		self.properties[prop] = PL:new(prop)
	end
	self.properties[prop]:add(obj)
end

function C:addObjectWithProperties(obj)
	if obj:hasProperties() then
		for prop in obj:iterateProperties() do
			self:addObjectToPropertyList(obj,prop)
		end
	end
	--keep track of the ones with missing data
	if E:hasProperties(obj.id)=="$UnknownProperties" then
		self.unknownProperties:add(obj)
	end
end

function C:removeObjectFromPropertyList(obj,prop)
	self.properties[prop]:remove(obj)
	--check if the pool is empty
	if self.properties[prop]:isEmpty() then
		self.properties[prop] = nil
	end
end

function C:removeObjectWithProperties(obj)
	if obj:hasProperties() then
		for prop in obj:iterateProperties() do
			self:removeObjectFromPropertyList(obj,prop)
		end
	end
	--keep track of the ones with missing data
	if E:hasProperties(obj.id)=="$UnknownProperties" then
		self.unknownProperties:remove(obj)
	end
end

return C
