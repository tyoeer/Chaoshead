local DS = require("libs.tyoeerUtils.datastructures")
local OBJ = require("levelhead.level.object")
local PN = require("levelhead.level.pathNode")


local S = Class()

function S:initialize()
	self.mask = DS.grid()
	self.layers = {
		foreground = true,
		background = true,
		pathNodes = true,
	}
	self.nTiles = 0
end


-- EDITING


function S:setLayerEnabled(layer,enabled)
	self.layers[layer] = enabled
end

function S:getLayerEnabled(layer)
	return self.layers[layer]
end

--add & remove fail quietly when the tile is already in/out the selection

function S:add(x,y)
	if not self.mask[x][y] then
		self.mask[x][y] = true
		self.nTiles = self.nTiles + 1
	end
end

function S:remove(x,y)
	if self.mask[x][y] then
		self.mask[x][y] = false
		self.nTiles = self.nTiles - 1
	end
end


-- DRAWING


function S:draw(startX,startY, endX,endY)
	for x = startX, endX, 1 do
		for y = startY, endY, 1 do
			if self.mask[x][y] then
				local xx, yy = x*TILE_SIZE, y*TILE_SIZE
				if self.layers.background then
					love.graphics.setColor(settings.col.editor.objects.background.selected)
					love.graphics.setLineWidth(1)
					
					love.graphics.translate(xx,yy)
					love.graphics.polygon("line",OBJ.backgroundShape)
					love.graphics.translate(-xx,-yy)
				end
				if self.layers.pathNodes then
					love.graphics.setColor(settings.col.editor.pathNodes.selected)
					love.graphics.setLineWidth(math.sqrt(2)/2)
					
					love.graphics.translate(xx,yy)
					love.graphics.polygon("line",PN.shape)
					love.graphics.translate(-xx,-yy)
				end
				if self.layers.foreground then
					love.graphics.setColor(settings.col.editor.objects.foreground.selected)
					love.graphics.setLineWidth(1)
					love.graphics.rectangle("line",xx+0.5,yy+0.5,TILE_SIZE-1,TILE_SIZE-1)
				end
			end
		end
	end
end


return S
