local OBJ = require("levelhead.level.object")
local Bitplane = require("tools.bitplane")
local P = require("levelhead.data.properties")

---@class AllocatorSettings
---@field immediate boolean?
---@field objectMask boolean?
---@field channelMask boolean?
---@field riftIdMask boolean?
---@field preScan boolean?
---@field scanBgObjects boolean?
---@field size { [1]:integer, [2]:integer}?

---@class Allocator : Class
---@field new fun(self, level: World, settings: AllocatorSettings): self
local A = Class("Allocator")

---@param level World
---@param settings AllocatorSettings
function A:initialize(level,settings)
	self.settings = settings
	self.level = level
	
	if self.settings.immediate==nil then
		self.settings.immediate=false
	end
	if self.settings.objectMask==nil then
		self.settings.objectMask = false
	end
	if self.settings.channelMask==nil then
		self.settings.channelMask = false
	end
	if self.settings.riftIdMask==nil then
		self.settings.riftIdMask = false
	end
	if self.settings.preScan==nil then
		self.settings.preScan = false
	end
	if self.settings.scanBgObjects==nil then
		self.settings.scanBgObjects = true
	end
	
	if self.settings.size then
		self.width = self.settings.size[1]
		self.height = self.settings.size[2]
	else
		self.width = self.level:getWidth()
		self.height = self.level:getHeight()
	end
	
	if not self.settings.immediate then
		self.objectQueue = {}
		self.areaQueue = {}
	end
	if self.settings.objectMask then
		self.objectMask = Bitplane.new(self.width, self.height, true)
	end
	if self.settings.channelMask then
		self.channelMask = {}
		for i=0,P:getMax("Sending Channel"),1 do
			self.channelMask[i] = true
		end
	end
	if self.settings.riftIdMask then
		self.riftIdMask = {}
		for i=0,P:getMax("Rift ID"),1 do
			self.riftIdMask[i] = true
		end
	end
	if self.settings.preScan then
		self:scan()
	end
	
	
	self:setTopLeftCorner(level.left,level.top)
	--[[
	self.minX
	self.minY
	self.freeX
	self.freeY
	self.maxX
	self.maxY
	]]--
	-- they get incremented before returning a channel
	self.channelCounter = -1
	self.riftIdCounter = -1
end

-- Fills in the mask by scanning the level
function A:scan()
	for obj in level.objects:iterate() do
		---@cast obj Object
		if self.settings.scanBgObjects or obj.layer=="foreground" then
			if self.objectMask then
				self.objectMask:setRect(
					obj:getMinX(), obj:getMinY(),
					obj:getWidth(), obj:getHeight(),
					false
				)
				-- self.objectMask:set(obj.x, obj.y, false)
			end

			-- {Sending Channel, Receiving Channel, Receving Channel (optional variant), Sending Channel (optional variant)}
			local channelProperties = {0, 1, 49, 90}
			
			if self.channelMask then
				for _,propId in ipairs(channelProperties) do
					local p = obj:getPropertyRaw(propId)
					if p ~= nil then
						self.channelMask[p] = false
					end
				end
			end
			
			-- {Rift ID, Destination Rift ID}
			local riftIdProperties = {30, 31}
			
			if self.riftIdMask then
				for _,propId in ipairs(riftIdProperties) do
					local p = obj:getPropertyRaw(propId)
					if p ~= nil then
						self.riftIdMask[p] = false
					end
				end
			end
		end
	end
end

-- OBJECTS & AREAS


function A:allocateObject(element)
	local obj = OBJ:orNew(element)
	if self.settings.immediate then
		self:placeObject(obj)
	else
		table.insert(self.objectQueue,obj)
	end
	return obj
end

function A:allocateArea(w,h)
	if not self.objectMask then
		error("Can't allocate area without an object mask!",2)
	end
	if w > self.width or h > self.height then
		error("Can't allocate an area bigger than the allocator!",2)
	end
	local sub_settings = {}
	for k,v in pairs(self.settings) do
		sub_settings[k] = v
	end
	sub_settings.size = {w, h}

	local sub = A:new(self.level, sub_settings)
	if self.settings.immediate then
		self:placeArea(sub)
	else
		table.insert(self.areaQueue,sub)
	end
	return sub
end

function A:allocateRelay(cin, cond, cout)
	local r = self:allocateObject("Relay")
	r:setReceivingChannel(cin)
	r:setSwitchRequirements(cond)
	r:setSendingChannel(cout)
	return r
end

function A:allocateRift(id_in, cin, cond, id_out)
	local r = self:allocateObject("Rift")
	r:setRiftId(id_in)
	r:setReceivingChannel(cin)
	r:setSwitchRequirements(cond)
	r:setDestinationRiftId(id_out)
	return r
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
	if self.objectMask then
		while not self.objectMask:get(x,y) do
			x, y = self:nextPos(x, y)
		end
	end
	return x, y
end

function A:placeObject(obj)
	self.level:addObject(obj, self.freeX, self.freeY)
	if self.objectMask then
		self.objectMask:set(self.freeX, self.freeY, false)
	end
	self.freeX, self.freeY = self:nextFree(self.freeX, self.freeY)
end

function A:placeArea(area)
	local first = true
	local x = self.freeX
	local y = self.freeY
	while true do
		--check if the area can be placed
		if y+area.height-1 > self.maxY then
			error("Allocation Error: level/area too small!",3)
		end
		if x+area.width-1 <= self.maxX and not self.objectMask:rectContains(x,y, area.width, area.height, false) then
			area:setTopLeftCorner(x,y)
			self.objectMask:setRect(x,y, area.width, area.height, false)
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
	if self.objectMask then
		for _,area in ipairs(self.areaQueue) do
			self:placeArea(area)
		end
	end
	for _,obj in ipairs(self.objectQueue) do
		self:placeObject(obj)
	end
	self.objectQueue = {}
	self.areaQueue = {}
end


-- CHANNELS

function A:allocateChannel()
	if self.channelMask then
		while not self.channelMask[self.channelCounter] do
			self.channelCounter = self.channelCounter + 1
			if self.channelCounter>P:getMax("Sending Channel") then
				error("Can't allocate more channels: used all available",2)
			end
		end
	else
		self.channelCounter = self.channelCounter + 1
		if self.channelCounter>P:getMax("Sending Channel") then
			error("Can't allocate more channels: used all available",2)
		end
	end
	return self.channelCounter
end

function A:allocateChannels(count)
	local result = {}
	for i=1,count do
		result[i] = self:allocateChannel()
	end
	return result
end

-- RIFT IDS

function A:allocateRiftId()
	if self.riftIdMask then
		while not self.riftIdMask[self.riftIdCounter] do
			self.riftIdCounter = self.riftIdCounter + 1
			if self.riftIdCounter>P:getMax("Rift ID") then
				error("Can't allocate more rift IDs: used all available",2)
			end
		end
	else
		self.riftIdCounter = self.riftIdCounter + 1
		if self.riftIdCounter>P:getMax("Rift ID") then
			error("Can't allocate more rift IDs: used all available",2)
		end
	end
	return self.riftIdCounter
end

function A:allocateRiftIds(count)
	local result = {}
	for i=1,count do
		result[i] = self:allocateRiftId()
	end
	return result
end

-- MISC

function A:getObjectMask()
	if self.objectMask then
		return self.objectMask
	else
		error("Trying to get the object mask of an allocator that doesn't have it!",2)
	end
end

function A:getChannelMask()
	if self.channelMask then
		return self.channelMask
	else
		error("Trying to get the channel mask of an allocator that doesn't have it!",2)
	end
end

function A:getRiftIdMask()
	if self.riftIdMask then
		return self.riftIdMask
	else
		error("Trying to get the rift ID mask of an allocator that doesn't have it!",2)
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

---@return integer x, integer ys
function A:getTopLeftCorner()
	return self.minX, self.minY
end

---@return integer width, integer height
function A:getSize()
	return self.width, self.height
end

function A:getShortcuts()
	return function(...)
		self:allocateRelay(...)
	end, function()
		return self:allocateChannel()
	end, function()
		return self:allocateRiftId()
	end
end


return A
