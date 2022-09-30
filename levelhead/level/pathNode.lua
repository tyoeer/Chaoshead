
local PN = Class("PathNode")


function PN:initialize(x,y)
	self.x = x
	self.y = y
	--self.prev = nil
	--self.next = nil
	--self.path = nil
end

-- Adding nodes

function PN:append(x,y)
	if not self.path then
		error("Can't append a node to a node without a path!",2)
	end
	local new = self.class:new(x,y)
	self.path:addNodeAfter(new, self)
	return new
end

function PN:prepend(x,y)
	if not self.path then
		error("Can't append a node to a node without a path!",2)
	end
	local new = self.class:new(x,y)
	self.path:addNodeBefore(new, self)
	return new
end

-- Misc manip

function PN:splitAfter()
	if (not self.next) or self.next==self or self==self.path.tail then
		error("No nodes to split off!",2)
	end
	
	local new = self.path:cloneWithoutNodes()
	local node = self.next
	while node and (node ~= self.path.head) do
		new:append(node.x, node.y)
		local old = node
		node = node.next
		self.path:removeNode(old) --cant use node.prev cause node might have become nil
	end
	if self.path.world then
		self.path.world:addPath(new)
	end
	
	return new
end

function PN:makeHead()
	local closed = self.path:getClosed()
	self.path:setClosed("Yes")
	self.path.head = self
	self.path.tail = self.prev
	self.path:setClosed(closed)
end

function PN:disconnectAfter()
	if self.path:getClosed()=="Yes" then
		self.next:makeHead()
		self.path:setClosed("No")
	else
		return self:splitAfter()
	end
end

-- DRAWING

function PN:getDrawCoords()
	return self.x*TILE_SIZE, self.y*TILE_SIZE
end

PN.shape = {
	35.5, 0.5,
	70.5, 35.5,
	35.5, 70.5,
	0.5,  35.5
}

local colors = Settings.theme.editor.level.pathNode

function PN:drawShape()
	local x, y = self:getDrawCoords()
	love.graphics.setColor(colors.shape)
	
	love.graphics.translate(x,y)
	love.graphics.polygon("fill",self.shape)
	love.graphics.translate(-x,-y)
end

function PN:drawOutline()
	local x, y = self:getDrawCoords()
	love.graphics.setColor(colors.outline)
	love.graphics.setLineWidth(math.sqrt(2)/2)
	
	love.graphics.translate(x,y)
	love.graphics.polygon("line",self.shape)
	love.graphics.translate(-x,-y)
end

function PN:drawConnection()
	local drawX = (self.x+0.5)*TILE_SIZE
	local drawY = (self.y+0.5)*TILE_SIZE
	local toX = (self.next.x+0.5)*TILE_SIZE
	local toY = (self.next.y+0.5)*TILE_SIZE
	love.graphics.setColor(colors.connection)
	love.graphics.setLineWidth(5)
	love.graphics.line(drawX,drawY, toX,toY)
end



return PN
