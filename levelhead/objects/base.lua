local E = require("levelhead.data.elements"):new()

local Base = Class()

function Base:initialize(id)
	self.id = E:getID(id)
	--self.x = nil
	--self.y = nil
end

function Base:draw()
	local drawX = (self.x-1)*TILE_SIZE
	local drawY = (self.y-1)*TILE_SIZE
	love.graphics.setColor(0,1,0,0.5)
	love.graphics.rectangle("fill",drawX,drawY,TILE_SIZE,TILE_SIZE)
	love.graphics.setColor(0,0,0,1)
	love.graphics.print(self.id,drawX+2,drawY+2)
	love.graphics.setColor(0,1,0,1)
	love.graphics.rectangle("line",drawX,drawY,TILE_SIZE,TILE_SIZE)
end

return Base
