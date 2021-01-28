
local PN = Class("PathNode")


function PN:initialize(x,y)
	self.x = x
	self.y = y
	--self.prev = nil
	--self.next = nil
	--self.path = nil
end

function PN:draw()
	local x = (self.x-1)*TILE_SIZE
	local y = (self.y-1)*TILE_SIZE
	love.graphics.setColor(0,0,1,0.4)
	--it might have been useful to express this using TILE_SIZE
	-- but the shape has been tweaked to be pixel-perfect, upon changing the tile size
	-- it should be re-tweaked anyway
	love.graphics.polygon("fill",
		x+ 35.5, y+ 0.5,
		x+ 70.5, y+ 35.5,
		x+ 35.5, y+ 70.5,
		x+ 0.5,  y+ 35.5
	)
	love.graphics.setColor(0,0,1,1)
	love.graphics.setLineWidth(math.sqrt(2)/2)
	love.graphics.polygon("line",
		x+ 35.5, y+ 0.5,
		x+ 70.5, y+ 35.5,
		x+ 35.5, y+ 70.5,
		x+ 0.5,  y+ 35.5
	)
end
function PN:drawConnection()
	local drawX = (self.x-0.5)*TILE_SIZE
	local drawY = (self.y-0.5)*TILE_SIZE
	local toX = (self.next.x-0.5)*TILE_SIZE
	local toY = (self.next.y-0.5)*TILE_SIZE
	love.graphics.setColor(0,0,1,0.6)
	love.graphics.setLineWidth(5)
	love.graphics.line(drawX,drawY, toX,toY)
end



return PN
