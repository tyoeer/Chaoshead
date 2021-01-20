local PN = require("levelhead.pathNodes")

local P = Class("Path")

function P:initialize()
	--self.tail = nil
	--self.head = nil
	--self.world = nil
end

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

return P
