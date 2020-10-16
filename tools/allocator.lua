local P = require("levelhead.objects.propertiesBase")

local A = Class()

function A:initialize(level,settings)
	self.settings = settings
	self.level = level
	
	if self.settings.immediate==nil then
		self.settings.immediate=false
	end
	if self.settings.mask==nil then
		self.settings.mask = false
	end
	
	if self.settings.size then
		self.width = self.settings.size[1]
		self.height = self.settings.size[2]
	else
		self.width = self.level.width
		self.height = self.level.height
	end
	
	if not self.settings.immediate then
		self.objectQueue = {}
		self.areaQueue = {}
	end
	if self.settings.mask then
		self.mask = require("tools.bitplane").new(self.width, self.height, true)
	end
	
	self:setTopLeftCorner(1,1)
	--[[
	self.minX
	self.minY
	self.freeX
	self.freeY
	self.maxX
	self.maxY
	]]--
	self.channelCounter = -1 -- it gets incremented before returning a channel
end


-- OBJECTS & AREAS


function A:allocateObject(element)
	local obj = P:new(element)
	if self.settings.immediate then
		self:placeObject(obj)
	else
		table.insert(self.objectQueue,obj)
	end
	return obj
end

function A:allocateArea(w,h)
	local sub = A:new(self.level,{
		size={w,h},
		immediate = self.settings.immediate,
	})
	if self.settings.immediate then
		self:placeArea(sub)
	else
		table.insert(self.areaQueue,sub)
	end
	return sub
end

function A:allocateRelay(cin,cond,cout)
	local r = self:allocateObject("Relay")
	r:setReceivingChannel(cin)
	r:setSwitchRequirements(cond)
	r:setSendingChannel(cout)
end

function A:nextPos(x,y)
	if y > self.maxY then
		error("Allocation Error: level/area too small!",3)
	end
	x = x+1
	if x > self.maxX then
		x = self.minX
		y = y + 1
	end
	return x,y
end

function A:nextFree(x,y)
	x, y = self:nextPos(x, y)
	if self.mask then
		while not self.mask:get(x,y) do
			x, y = self:nextPos(x, y)
		end
	end
	return x, y
end

function A:placeObject(obj)
	self.level:addObject(obj, self.freeX, self.freeY)
	if self.mask then
		self.mask:set(self.freeX, self.freeY, false)
	end
	self.freeX, self.freeY = self:nextFree(self.freeX, self.freeY)
end

function A:placeArea(area)
	local first = true
	local x = self.freeX
	local y = self.freeY
	while true do
		--check if the area can be placed
		if not self.mask:rectContains(x,y, area.width, area.height, false) then
			area:setTopLeftCorner(x,y)
			self.mask:setRect(x,y, area.width, area.height, false)
			if not area.settings.immediate then
				area:finalize()
			end
			if first then
				self.freeX, self.freeY = self:nextFree(self.freeX, self.freeY)
			end
			break
		else
			x, y = self:nextFree(x, y)
			first = false
		end
	end
end

function A:finalize()
	if self.settings.immediate then
		error("Trying to finalize an immediate allocator!",2)
	end
	for _,area in ipairs(self.areaQueue) do
		self:placeArea(area)
	end
	for _,obj in ipairs(self.objectQueue) do
		self:placeObject(obj)
	end
	self.objectQueue = {}
	self.areaQueue = {}
end


-- CHANNELS


function A:allocateChannel()
	self.channelCounter = self.channelCounter + 1
	return self.channelCounter
end


-- MISC


function A:getMask()
	if self.mask then
		return self.mask
	else
		error("Trying to get the mask of a mask-less allocator!",2)
	end
end

function A:setTopLeftCorner(x,y)
	self.minX = x
	self.minY = y
	self.freeX = x
	self.freeY = y
	self.maxX = x + self.width - 1
	self.maxY = y + self.height - 1
end

function A:getShortcuts()
	return function(...)
		self:allocateRelay(...)
	end, function()
		return self:allocateChannel()
	end
end


return A
