local P = require("levelhead.objects.propertiesBase")

local A = Class()

function A:initialize(level,settings)
	if settings.immediate==nil then settings.immediate=false end
	self.settings = settings
	if not self.settings.immediate then
		self.queue = {}
	end
	self.level = level
	
	self.objX=1
	self.objY=1
	
	self.channelCounter = -1 -- it gets incremented before returning a channel
end


-- OBJECTS


function A:allocateObject(element)
	local obj = P:new(element)
	if self.settings.immediate then
		self:placeObject(obj)
	else
		table.insert(self.queue,obj)
	end
	return obj
end

function A:placeObject(obj)
	self.level:addObject(obj, self.objX, self.objY)
	self.objX = self.objX+1
	if self.objX > self.level.width then
		self.objX = 1
		self.objY = self.objY + 1
		if self.objY > self.level.height then
			error("Can't add object: level too small!")
		end
	end
end

function A:allocateRelay(cin,cond,cout)
	local r = self:allocateObject("Relay")
	r:setReceivingChannel(cin)
	r:setSwitchRequirements(cond)
	r:setSendingChannel(cout)
end

function A:finalize()
	if self.settings.immediate then
		error("Trying to finalize an immediate allocator!",2)
	end
	for _,obj in ipairs(self.queue) do
		self:placeObject(obj)
	end
	self.queue = {}
end


-- CHANNELS


function A:allocateChannel()
	self.channelCounter = self.channelCounter + 1
	return self.channelCounter
end


-- MISC


function A:getShortcuts()
	return function(...)
		self:allocateRelay(...)
	end, function()
		return self:allocateChannel()
	end
end
return A
