local UI = Class(require("ui.worldViewer"))


function UI:initialize(level,editor)
	self.editor = editor
	--camera stuff
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	self.zoomSpeed = math.sqrt(2)
	--state stuff
	self.draggedCamera = false
	
	--UI stuff
	UI.super.initialize(self,level)
	self.title = "World Editor"
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
	if input.isActive("drag","camera") then
		self.draggedCamera = true
		self.x = self.x + dx/self.zoomFactor
		self.y = self.y + dy/self.zoomFactor
	end
end

function UI:inputDeactivated(name,group, isCursorBound)
	if name=="select" and group=="editor" then
		if not self.draggedCamera then
			self.editor:selectObject(self:getMouseTile(x,y))
		end
	end
	if name=="drag" and group=="camera" then
		self.draggedCamera = false
	end
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
