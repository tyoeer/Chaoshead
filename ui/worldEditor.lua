local UI = Class(require("ui.worldViewer"))
local DET_OBJ = require("ui.details.object")

function UI:initialize(w,h,level,editor)
	--camera stuff
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	self.zoomSpeed = math.sqrt(2)
	--state stuff
	self.movedCamera = false
	--selection stuff
	--self.selectedObject = nil
	--self.selectionDetails = nil
	UI.super.initialize(self,w,h,level)
	self.title = "World Editor"
	self.editor = editor
end


function UI:selectObject(tileX,tileY)
	if self.selectedObject then
		self.selectedObject = nil
		self.editor:removeTab(self.selectionDetails)
		self.selectionDetails = nil
	end
	local obj = level.foreground:get(tileX,tileY)
	if obj then
		self.selectedObject = obj
		self.selectionDetails = DET_OBJ:new(-1,-1,obj)
		self.editor:addTab(self.selectionDetails)
	end
end

function UI:getMouseTile(x,y)
	x = self:toWorldX(x or self:getMouseX())
	y = self:toWorldY(y or self:getMouseY())
	return math.ceil(x/TILE_SIZE), math.ceil(y/TILE_SIZE)
end

function UI:toWorldX(x)
	x = x - self.width/2
	x = x / self.zoomFactor
	x = x - self.x
	return x
end
function UI:toWorldY(y)
	y = y - self.height/2
	y = y / self.zoomFactor
	y = y - self.y
	return y
end


function UI:draw()
	love.graphics.push()
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.x, self.y)
		UI.super.draw(self)
	love.graphics.pop()
end

function UI:mousemoved(x,y,dx,dy)
	if love.mouse.isDown(1) or love.mouse.isDown(3) then
		self.movedCamera = true
		self.x = self.x + dx/self.zoomFactor
		self.y = self.y + dy/self.zoomFactor
	end
end

function UI:mousereleased(x,y, button,isTouch)
	if not self.movedCamera then
		self:selectObject(self:getMouseTile(x,y))
	end
	self.movedCamera = false
end

function UI:wheelmoved(x,y)
	if y>0 then
		self.zoomFactor = self.zoomFactor * self.zoomSpeed
	elseif y<0 then
		self.zoomFactor = self.zoomFactor / self.zoomSpeed
	end
	self.x = math.roundPrecision(self.x,self.zoomFactor)
	self.y = math.roundPrecision(self.y,self.zoomFactor)
end

return UI
