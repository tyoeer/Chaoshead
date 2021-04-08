local EP = require("libs.tyoeerUtils.entitypool")
local E = require("levelhead.data.elements")

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
		self.properties[prop] = EP:new()
	end
	self.properties[prop]:add(obj)
end

function C:addObjectWithProperties(obj)
	local has = E:hasProperties(obj.id)
	if has=="$UnknownProperties" then
		for _,prop in pairs(obj.properties) do
			self:addObjectToPropertyList(obj,prop)
		end
	elseif has then
		for prop in E:iterateProperties(obj.id) do
			self:addObjectToPropertyList(obj,tonumber(prop))
		end
	end
end

function C:removeObjectFromPropertyList(obj,prop)
	self.properties[prop]:remove(obj)
	--check if the pool is empty
	if self.properties[prop]:getTop()==nil then
		self.properties[prop] = nil
	end
end

function C:removeObjectWithProperties(obj)
	local has = E:hasProperties(obj.id)
	if has=="$UnknownProperties" then
		for _,prop in pairs(obj.properties) do
			self:removeObjectFromPropertyList(obj,prop)
		end
	elseif has then
		for prop in E:iterateProperties(obj.id) do
			self:removeObjectFromPropertyList(obj,tonumber(prop))
		end
	end
end

return C
