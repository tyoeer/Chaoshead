local EP = require("libs.tyoeerUtils.entitypool")

local PN = Class()

function PN:initialize(x,y)
	self.x = x
	self.y = y
	--self.prev = nil
	--self.next = nil
	--self.path = nil
end

function PN:draw()
	local drawX = (self.x-1)*TILE_SIZE
	local drawY = (self.y-1)*TILE_SIZE
	love.graphics.setColor(0,0,1,0.4)
	love.graphics.rectangle("fill",drawX,drawY,TILE_SIZE,TILE_SIZE)
	--love.graphics.setColor(0,0,0,1)
	--love.graphics.print(self.id,drawX+2,drawY+2)
	love.graphics.setColor(0,0,1,1)
	love.graphics.rectangle("line",drawX+0.5,drawY+0.5,TILE_SIZE-1,TILE_SIZE-1)
end
function PN:drawConnection()
	local drawX = (self.x-0.5)*TILE_SIZE
	local drawY = (self.y-0.5)*TILE_SIZE
	local toX = (self.next.x-0.5)*TILE_SIZE
	local toY = (self.next.y-0.5)*TILE_SIZE
	love.graphics.setColor(0,0,1,0.6)
	love.graphics.setLineWidth(5)
	love.graphics.line(drawX,drawY, toX,toY)
	love.graphics.setLineWidth(1)
end

local P = Class()

function P:initialize()
	--self.tail = nil
	--self.world = nil
end

function P:append(x,y)
	local n = PN:new(x,y)
	if self.tail then
		self:addNodeAfter(n,self.tail)
		self.tail = n
	else
		--no nodes yet
		self:addNode(n)
		self.tail = n
	end
end

function P:addNodeAfter(n,t)
	self:addNodeBetween(n,t,t.next)
end
function P:addNodeBefore(n,t)
	self:addNodeBetween(n,t.prev,t)
end
function P:addNodeBetween(n,prev,next)
	self:addNode(n)
	n.next = next
	n.prev = prev
	if prev then
		prev.next = n
	end
	if next then
		next.prev = n
	end
end

function P:removeNode(n)
	local prev = n.prev
	local next = n.next
	self.nodes:remove(n)
	if next then
		next.prev = prev
	end
	if prev then
		prev.next = next
	end
end

--doesn't properly connect, private use only
function P:addNode(n)
	n.path = self
	if self.world then
		self.world:addPathNode(n)
	end
end

return P
