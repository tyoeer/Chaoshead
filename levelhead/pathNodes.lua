
local PN = Class("PathNode")


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



return PN
