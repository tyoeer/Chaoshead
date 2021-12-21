local PROP = require("levelhead.data.properties")
local PN = require("levelhead.level.pathNode")

local P = Class("Path")

local CLOSED_PROPERTY_ID = 38
--to revise these, change all properties from their default and get their hex ids from the hex-inspector
local PATH_PROPERTIES = {37,38,39,49,60,61,71}
local PROPERTIES_LOOKUP = {}

function P:initialize()
	--self.tail = nil
	--self.head = nil
	--self.world = nil
	self.properties = {}
end

function P:cloneWithoutNodes()
	local p = P:new()
	for prop, val in pairs(self.properties) do
		p.properties[prop] = val
	end
	return p
end

function P:iterateNodes()
	return function(path,node)
		if node then
			if node~=path.tail then
				return node.next
			end
		else
			return path.head
		end
	end, self, nil
end

-- nodes editing

function P:append(x,y)
	local n = PN:new(x,y)
	if self.tail then
		return self:addNodeAfter(n,self.tail)
	else
		--no nodes yet
		return self:addNodeBetween(n,nil,nil)
	end
end

function P:addNodeAfter(n,t)
	return self:addNodeBetween(n,t,t.next)
end
function P:addNodeBefore(n,t)
	return self:addNodeBetween(n,t.prev,t)
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
	-- if this node was added to a closed path, the head and/or tail won't have updated properly
	-- first check if we've been added before the head so the new node will be the tail/appended
	-- if there's only one other node
	if next==self.head then
		self.tail = n
	end
	if prev==self.tail then
		self.head = n
	end
	--close if the closed property (38) is set to Yes(1)
	--a single node connected to itself doesn't make sense,
	--but it allows new nodes to be connected while maintaining a closed loop
	if prev==nil and next==nil and self.properties[CLOSED_PROPERTY_ID]==1 then
		n.next = n
		n.prev = n
	end
	return self
end

function P:removeNode(n)
	self:removeNodeRaw(n)
	if self.world then
		self.world:removePathNodeRaw(n)
	end
	return self
end
--doesn't properly update world, use Path:removeNode(), private use only
function P:removeNodeRaw(n)
	local prev = n.prev
	local next = n.next
	if next then
		next.prev = prev
	end
	if prev then
		prev.next = next
	end
	if n==self.head then
		--in a closed path, the last node is connected to itself
		--(which is a bit weird, but it makes it easy to add nodes again)
		if next==n then
			self.head = nil
		else
			self.head = next
		end
	end
	if n==self.tail then
		--in a closed path, the last node is connected to itself
		--(which is a bit weird, but it makes it easy to add nodes again)
		if prev==n then
			self.tail = nil
		else
			self.tail = prev
		end
	end
end

--doesn't properly connect, private use only
function P:addNode(n)
	n.path = self
	if self.world then
		self.world:addPathNodeRaw(n)
	end
end

-- open & closed

function P:closeEnds()
	if self.head then
		self.head.prev = self.tail
		self.tail.next = self.head
	end
end

function P:openEnds()
	if self.head then
		self.head.prev = nil
		self.tail.next = nil
	end
end

-- properties
-- similiar to object properties, but objects have more code to deal with unknown properties data

--build lookup table
do
	for _,property in ipairs(PATH_PROPERTIES) do
		PROPERTIES_LOOKUP[ PROP:reduceSelector(PROP:getName(property)) ] = property
	end
end

local function processSelector(selector)
	if type(selector)=="string" then
		local nId = PROPERTIES_LOOKUP[ PROP:reduceSelector(selector) ]
		if nId then
			return nId
		else
			error(string.format("Paths don't have property %q!",selector),3)
		end
	else
		return selector
	end
end

function P:iterateProperties()
	local i = 0
	return function(path)
		i = i + 1
		return PATH_PROPERTIES[i]
	end, self, nil
end

function P:hasProperty(prop)
	for prop2 in self:iterateProperties() do
		if prop == prop2 then
			return true
		end
	end
	return false
end


function P:setPropertyRaw(id, value)
	self.properties[id] = value
	if id==CLOSED_PROPERTY_ID then --closed property
		if value==1 then --Yes
			self:closeEnds()
		else --value==0 --No
			self:openEnds()
		end
	end
	return self
end

function P:getPropertyRaw(id)
	return self.properties[id] or PROP:getDefault(id)
end

function P:setProperty(id, value)
	if value==nil then
		error(string.format("Can't set property %q to nil!",id),2)
	end
	id2 = processSelector(id)
	if not self:hasProperty(id2) then
		error(string.format("Paths don't have a property %q (%i) to set!",PROP:getName(id2),id2),2)
	end
	self:setPropertyRaw(id2, PROP:mappingToValue(id2,value))
	return self
end

function P:getProperty(id)
	id2 = processSelector(id)
	if not self:hasProperty(id2) then
		error(string.format("Paths don't have a property %q (%i) to get!",PROP:getName(id2),id2),2)
	end
	return PROP:valueToMapping(id2, self:getPropertyRaw(id2))
end

function P:__index(key)
	if key:match("set") then
		local prop = key:match("set(.+)")
		--prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self,mapping)
			return self:setProperty(prop,mapping)
		end
	elseif key:match("get") then
		local prop = key:match("get(.+)")
		--prop = prop:gsub("([A-Z])"," %1"):trim()
		return function(self)
			return self:getProperty(prop)
		end
	end
end


return P
