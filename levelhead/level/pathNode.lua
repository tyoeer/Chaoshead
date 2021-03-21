
local PN = Class("PathNode")


function PN:initialize(x,y)
	self.x = x
	self.y = y
	--self.prev = nil
	--self.next = nil
	--self.path = nil
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

function PN:drawShape()
	local x, y = self:getDrawCoords()
	love.graphics.setColor(settings.col.editor.pathNodes.shape)
	
	love.graphics.translate(x,y)
	love.graphics.polygon("fill",self.shape)
	love.graphics.translate(-x,-y)
end

function PN:drawOutline()
	local x, y = self:getDrawCoords()
	love.graphics.setColor(settings.col.editor.pathNodes.outline)
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
	love.graphics.setColor(settings.col.editor.pathNodes.outline)
	love.graphics.setLineWidth(5)
	love.graphics.line(drawX,drawY, toX,toY)
end



return PN
