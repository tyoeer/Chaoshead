local World = require("levelhead.level.world")
local EntityPool = require("libs.tyoeerUtils.entitypool")

local Clipboard = Class()

function Clipboard:initialize(world,mask)
	local startX, startY
	self.mask, startX, startY = mask:getBitplane()
	--layers
	self.foreground = mask.layers.foreground
	self.background = mask.layers.background
	self.pathNodes = mask.layers.pathNodes
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
	local nodes = {}
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
			if self.pathNodes then
				if srcWorld.pathNodes[srcX][srcY] then
					table.insert(nodes,srcWorld.pathNodes[srcX][srcY])
				end
				--remove it so air is copied over, the right nodes will be added later
				dstWorld:removePathNodeAt(dstX,dstY)
			end
		end
	end)
	
	--copy over the pathnodes
	local done = {}
	for _, startNode in ipairs(nodes) do
		if not done[startNode] then
			--find the first node still in the selection
			local node = startNode
			local closed = false
			while node.prev and self.mask:get(node.prev.x - srcOffsetX, node.prev.y - srcOffsetY) do
				node = node.prev
				if node==startNode then
					--this is a closed path entirely inside the mask
					closed = true
					break
				end
			end
			--init path
			local path = node.path:cloneWithoutNodes()
			path:setClosed(closed and "Yes" or "No")
			dstWorld:addPath(path)
			--copy nodes
			startNode = node
			while self.mask:get(node.x - srcOffsetX, node.y - srcOffsetY) do
				path:append(node.x - srcOffsetX + dstOffsetX, node.y - srcOffsetY + dstOffsetY)
				done[node] = true
				if node.next then
					node = node.next
					if startNode==node then
						--we've made a loop
						break
					end
				else
					break
				end
			end
		end
	end
end

function Clipboard:getWidth()
	return self.mask.width
end

function Clipboard:getHeight()
	return self.mask.height
end

return Clipboard
