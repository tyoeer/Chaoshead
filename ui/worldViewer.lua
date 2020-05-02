local BaseUI = require("ui.base")

local UI = Class(BaseUI)

function UI:initialize()
	UI.super.initialize(self)
	self.title = "World Viewer"
end

function UI:getMouseTile()
	return math.ceil(self:getMouseX()/TILE_SIZE), math.ceil(self:getMouseY()/TILE_SIZE)
end

function UI:draw()
	--bg
	love.graphics.setColor(0,0.5,1,1)
	love.graphics.rectangle(
		"fill",
		0, 0,
		level.width*TILE_SIZE, level.height*TILE_SIZE
	)
	--objects
	for obj in level.allObjects:iterate() do
		obj:draw()
	end
	--hover
	local x,y = self:getMouseTile()
	love.graphics.setColor(1,1,1,0.5)
	love.graphics.rectangle(
		"fill",
		(x-1)*TILE_SIZE, (y-1)*TILE_SIZE,
		TILE_SIZE, TILE_SIZE
	)
end

return UI
