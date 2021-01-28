local PROP = require("levelhead.data.properties")
local PN = require("levelhead.level.pathNode")

local P = Class("Path")

function P:initialize()
	--self.tail = nil
	--self.head = nil
	--self.world = nil
	self.properties = {}
end

-- nodes editing

function P:append(x,y)
	local n = PN:new(x,y)
	if self.tail then
		self:addNodeAfter(n,self.tail)
	else
		--no nodes yet
		self:addNode(n)
		self.tail = n
		self.head = n
	end
end

function P:addNodeAfter(n,t)
	self:addNodeBetween(n,t,t.next)
end
function P:addNodeBefore(n,t)
	self:addNodeBetween(n,t.prev,t)
end
-- internal use only, use P:addNodeAfter/Before
function P:addNodeBetween(n,prev,next)
	self:addNode(n)
	n.next = next
	n.prev = prev
	if prev then
		prev.next = n
	else
		--no prev means this is the head
		self.head = n
	end
	if next then
		next.prev = n
	else
		--no next means this is the tail
		self.tail = n
	end
end

function P:removeNode(n)
	self:removeNodeRaw(n)
	if self.world then
		self.world:removePathNodeRaw(n)
	end
end
--doesn't properly update world, use Level:removePathNode(x,y)
function P:removeNodeRaw(n)
	local prev = n.prev
	local next = n.next
	if next then
		next.prev = prev
	else
		--no next means this was the tail
		self.tail = prev
	end
	if prev then
		prev.next = next
	else
		--no prev means this was the head
		self.head = next
	end
end

--doesn't properly connect, private use only
function P:addNode(n)
	n.path = self
	if self.world then
		self.world:addPathNodeRaw(n)
	end
end

-- properties

function P:setPropertyRaw(id, value)
	self.properties[id] = value
end

function P:getPropertyRaw(id)
	return self.properties[id]
end

function P:setProperty(id, value)
	if value==nil then
		error(string.format("Can't set property %q to nil!",id),2)
	end
	id = PROP:getID(id)
	self:setPropertyRaw(id,PROP:mappingToValue(id,value))
end

function P:getProperty(id)
	--LH doesn't set all the properties, so this is currently a bit brokens
	id = PROP:getID(id)
	return PROP:valueToMapping(id,self:getPropertyRaw(id))
end

function P:__index(key)
	if key:match("set") then
		local prop = key:match("set(.+)")
		--prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,mapping)
			local exists = false
			local set = false
			for _,id in ipairs(PROP:getAllIDs(prop)) do
				exists = true
				if PROP:isValidMapping(id,mapping) then
					set = true
					self:setProperty(id, mapping)
				end
			end
			if not set then
				if exists then
					error("Mapping "..mapping.." is invalid for property "..prop)
				else
					error("Property "..prop.." doesn't exist")
				end
			end
		end
	elseif key:match("get") then
		local prop = key:match("get(.+)")
		prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self)
			return self:getProperty(prop)
		end
	end
end


return P
