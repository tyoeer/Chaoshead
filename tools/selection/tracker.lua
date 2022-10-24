local Mask = require("tools.selection.mask")
local Contents = require("tools.selection.contents")

local T = Class()

function T:initialize(level,mask)
	self.level = level
	self.contents = Contents:new()
	if mask then
		self.mask = mask
		self:fillContentsFromMask()
	else
		self.mask = Mask:new()
	end
end

function T:fillContentsFromMask()
	if self:hasLayer("pathNodes") then
		for path in self.level.paths:iterate() do
			for node in path:iterateNodes() do
				if self.mask:has(node.x, node.y) then
					self.contents:addPathNode(node)
				end
			end
		end
	end
	for obj in self.level.objects:iterate() do
		if self.mask:has(obj.x, obj.y) then
			if self:hasLayer(obj.layer) and self.mask:has(obj.x, obj.y) then
				if obj.layer=="foreground" then
					self.contents:addForeground(obj)
				else
					--object is in the background layer
					self.contents:addBackground(obj)
				end
			end
		end
	end
end

function T:draw(sx,sy,ex,ey,zf)
	self.mask:draw(sx,sy,ex,ey,zf)
end


function T:hasLayer(layer)
	return self.mask:getLayerEnabled(layer)
end

function T:removeLayer(layer)
	self.mask:setLayerEnabled(layer,false)
	self.contents:removeLayer(layer)
end


function T:add(x,y)
	if not self.mask:has(x,y) then
		self.mask:add(x,y)
		if self:hasLayer("foreground") then
			local obj = self.level.foreground[x][y]
			if obj then self.contents:addForeground(obj) end
		end
		if self:hasLayer("background") then
			local obj = self.level.background[x][y]
			if obj then self.contents:addBackground(obj) end
		end
		if self:hasLayer("pathNodes") then
			local obj = self.level.pathNodes[x][y]
			if obj then self.contents:addPathNode(obj) end
		end
	end
end

function T:remove(x,y)
	if self.mask:has(x,y) then
		self.mask:remove(x,y)
		if self:hasLayer("foreground") then
			local obj = self.level.foreground[x][y]
			if obj then self.contents:removeForeground(obj) end
		end
		if self:hasLayer("background") then
			local obj = self.level.background[x][y]
			if obj then self.contents:removeBackground(obj) end
		end
		if self:hasLayer("pathNodes") then
			local obj = self.level.pathNodes[x][y]
			if obj then self.contents:removePathNode(obj) end
		end
	end
end
--- Does not recalculate property bounds. call endBatchRemove() afterwards
function T:removeBatch(x,y)
	if self.mask:has(x,y) then
		self.mask:remove(x,y)
		if self:hasLayer("foreground") then
			local obj = self.level.foreground[x][y]
			if obj then self.contents:removeForegroundBatch(obj) end
		end
		if self:hasLayer("background") then
			local obj = self.level.background[x][y]
			if obj then self.contents:removeBackground(obj) end
		end
		if self:hasLayer("pathNodes") then
			local obj = self.level.pathNodes[x][y]
			if obj then self.contents:removePathNodeBatch(obj) end
		end
	end
end

function T:endBatchRemove()
	self.contents:endBatchRemove()
end

return T
