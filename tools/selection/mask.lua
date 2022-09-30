local DS = require("libs.tyoeerUtils.datastructures")
local EntityPool = require("libs.tyoeerUtils.entitypool")
local Bitplane = require("tools.bitplane")
local OBJ = require("levelhead.level.object")
local PN = require("levelhead.level.pathNode")


local S = Class()

function S:initialize()
	self.mask = DS.grid()
	self.tiles = EntityPool:new()
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

function S:has(x,y)
	return self.mask[x][y]
end

--add & remove are quiet when the tile is already in/out the selection

function S:add(x,y)
	if not self.mask[x][y] then
		local tile = {
			x = x,
			y = y,
		}
		self.mask[x][y] = tile
		self.nTiles = self.nTiles + 1
		self.tiles:add(tile)
	end
end

function S:remove(x,y)
	if self.mask[x][y] then
		self.tiles:remove(self.mask[x][y])
		self.mask[x][y] = false
		self.nTiles = self.nTiles - 1
	end
end

-- RETRIEVING

function S:getBounds()
	local xMin, yMin = math.huge, math.huge
	local xMax, yMax = -math.huge, -math.huge
	for tile in self.tiles:iterate() do
		if tile.x < xMin then xMin = tile.x end
		if tile.x > xMax then xMax = tile.x end
		if tile.y < yMin then yMin = tile.y end
		if tile.y > yMax then yMax = tile.y end
	end
	return xMin, yMin, xMax, yMax
end

function S:getBitplane()
	local xMin, yMin, xMax, yMax = self:getBounds()
	
	local plane = Bitplane.new(xMax-xMin+1, yMax-yMin+1)
	for tile in self.tiles:iterate() do
		-- +1 because the Bitplane starts at (1,1)
		plane:set(tile.x-xMin+1, tile.y-yMin+1, true)
	end
	
	return plane, xMin, yMin
end

-- DRAWING

local colors = Settings.theme.editor.level

function S:drawTile(x,y)
	local xx, yy = x*TILE_SIZE, y*TILE_SIZE
	if self.layers.background then
		love.graphics.setColor(colors.backgroundObject.selected)
		love.graphics.setLineWidth(1)
		
		love.graphics.translate(xx,yy)
		love.graphics.polygon("line",OBJ.backgroundShape)
		love.graphics.translate(-xx,-yy)
	end
	if self.layers.pathNodes then
		love.graphics.setColor(colors.pathNode.selected)
		love.graphics.setLineWidth(math.sqrt(2)/2)
		
		love.graphics.translate(xx,yy)
		love.graphics.polygon("line",PN.shape)
		love.graphics.translate(-xx,-yy)
	end
	if self.layers.foreground then
		love.graphics.setColor(colors.foregroundObject.selected)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle("line",xx+0.5,yy+0.5,TILE_SIZE-1,TILE_SIZE-1)
	end
end

function S:draw(startX,startY, endX,endY, zoomFactor)
	local draw
	if zoomFactor < 6/TILE_SIZE then
		if self.layers.foreground then
			love.graphics.setColor(colors.foregroundObject.selected)
		elseif self.layers.pathNodes then
			love.graphics.setColor(colors.pathNode.selected)
		else
			love.graphics.setColor(colors.backgroundObject.selected)
		end
		if zoomFactor < 3/TILE_SIZE then
			love.graphics.setPointSize(TILE_SIZE*zoomFactor)
			draw = function(_, x, y)
				local xx, yy = x*TILE_SIZE, y*TILE_SIZE
				love.graphics.points(xx+TILE_SIZE/2,yy+TILE_SIZE/2)
			end
		else
			love.graphics.setLineWidth(1)
			draw = function(_, x, y)
				local xx, yy = x*TILE_SIZE, y*TILE_SIZE
				love.graphics.rectangle("line",xx+0.5,yy+0.5,TILE_SIZE-1,TILE_SIZE-1)
			end
		end
	else
		draw = self.drawTile
	end
	local drawArea = math.abs( (startX-endX+1) * (startY-endY+1) )
	
	if drawArea >= self.nTiles then
		for tile in self.tiles:iterate() do
			draw(self,tile.x, tile.y)
		end
	else
		for x = startX, endX, 1 do
			for y = startY, endY, 1 do
				if self.mask[x][y] then
					draw(self,x,y)
				end
			end
		end
	end
end


return S
