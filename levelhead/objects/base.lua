local E = require("levelhead.data.elements")

local Base = Class("Object")

function Base:initialize(id)
	self.id = E:getID(id)
	--self.x = nil
	--self.y = nil
	--self.world = nil
	--self.layer = nil
end

function Base:drawAsForeground()
	local drawX = (self.x-1)*TILE_SIZE
	local drawY = (self.y-1)*TILE_SIZE
	
	love.graphics.setColor(0,1,0,0.4)
	love.graphics.rectangle("fill",drawX,drawY,TILE_SIZE,TILE_SIZE)
	love.graphics.setColor(0,0,0,1)
	
	love.graphics.print(self.id,drawX+2,drawY+2)
	
	love.graphics.setColor(0,1,0,1)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line",drawX+0.5,drawY+0.5,TILE_SIZE-1,TILE_SIZE-1)
end

function Base:drawAsBackground()
	local x = (self.x-1)*TILE_SIZE
	local y = (self.y-1)*TILE_SIZE
	
	love.graphics.setColor(1,0,0,0.4)
	love.graphics.polygon("fill",
		x+ 20.5, y+ 0.5,
		x+ 50.5, y+ 0.5,
		x+ 70.5, y+ 20.5,
		x+ 70.5, y+ 50.5,
		
		x+ 50.5, y+ 70.5,
		x+ 20.5, y+ 70.5,
		x+ 0.5,  y+ 50.5,
		x+ 0.5,  y+ 20.5
	)
	love.graphics.setColor(0,0,0,1)
	
	love.graphics.print(self.id, x+20,y+51)
	
	love.graphics.setColor(1,0,0,1)
	love.graphics.setLineWidth(1)
	love.graphics.polygon("line",
		x+ 20.5, y+ 0.5,
		x+ 50.5, y+ 0.5,
		x+ 70.5, y+ 20.5,
		x+ 70.5, y+ 50.5,
		
		x+ 50.5, y+ 70.5,
		x+ 20.5, y+ 70.5,
		x+ 0.5,  y+ 50.5,
		x+ 0.5,  y+ 20.5
	)
end


return Base
