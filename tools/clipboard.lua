local World = require("levelhead.level.world")

local Clipboard = Class()

function Clipboard:initialize(world,mask)
	local startX, startY
	self.mask, startX, startY = mask:getBitplane()
	--layers
	self.foreground = mask.layers.foreground
	self.background = mask.layers.background
	self.paths = mask.layers.pathNodes
	self.world = World:new()
	self.world.left, self.world.top = 1, 1
	self.world.right, self.world.bottom = self.mask.width, self.mask.height
	--offset are from (1,1), so offsets should be 1 lower than the start position
	--(the start psoition of (1,1) need offset (0,0))
	self:copy(world, self.world, startX-1,startY-1, 0,0)
end

--offset are from (1,1), so offsets should be 1 lower than the start position
--(the start psoition of (1,1) need offset (0,0))
function Clipboard:copy(srcWorld, dstWorld, srcOffsetX,srcOffsetY, dstOffsetX,dstOffsetY)
	self.mask:forEach(function(x,y,value)
		if value then
			local srcX, srcY = x + srcOffsetX, y + srcOffsetY
			local dstX, dstY = x + dstOffsetX, y + dstOffsetY
			if self.foreground then
				if srcWorld.foreground[srcX][srcY] then
					dstWorld:addForegroundObject(srcWorld.foreground[srcX][srcY]:clone(), dstX,dstY)
				--also copy air
				elseif dstWorld.foreground[dstX][dstY] then
					dstWorld:removeForegroundAt(dstX,dstY)
				end
			end
			if self.background then
				if srcWorld.background[srcX][srcY] then
					dstWorld:addBackgroundObject(srcWorld.background[srcX][srcY]:clone(), dstX,dstY)
				--also copy air
				elseif dstWorld.background[dstX][dstY] then
					dstWorld:removeBackgroundAt(dstX,dstY)
				end
			end
		end
	end)
end

function Clipboard:getWidth()
	return self.mask.width
end

function Clipboard:getHeight()
	return self.mask.height
end

return Clipboard
