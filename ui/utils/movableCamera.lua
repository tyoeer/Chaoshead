local BaseUI = require("ui.structure.base")

local UI = Class(BaseUI)

function UI:initialize(child)
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	--copy settings from the editor
	self.zoomSpeed = settings.misc.editor.zoomSpeed
	self.moveSpeed = settings.misc.editor.cameraMoveSpeed
	self.child = child
	child.parent = self
	UI.super.initialize(self)
	self.title = child.title
end


function UI:getPropagatedMouseX(child)
	local x = self:getMouseX(self)
	x = x - self.width/2
	x = x / self.zoomFactor
	x = x - self.x
	return x
end

function UI:getPropagatedMouseY(child)
	local y = self:getMouseY(self)
	y = y - self.height/2
	y = y / self.zoomFactor
	y = y - self.y
	return y
end

--events

local relay = function(index)
	UI[index] = function(self, ...)
		self.child[index](self.child, ...)
	end
end

function UI:update()
	if input.isActive("up","camera") then
		self.y = self.y + self.moveSpeed/self.zoomFactor
	end
	if input.isActive("down","camera") then
		self.y = self.y - self.moveSpeed/self.zoomFactor
	end
	if input.isActive("left","camera") then
		self.x = self.x + self.moveSpeed/self.zoomFactor
	end
	if input.isActive("right","camera") then
		self.x = self.x - self.moveSpeed/self.zoomFactor
	end
end

function UI:draw()
	love.graphics.push()
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.x, self.y)
		self.child:draw()
	love.graphics.pop()
end

relay("focus")
relay("visible")
function UI:resize(w,h)
	self.width = w
	self.height = h
	self.child:resize(w,h)
end

relay("inputActivated")
relay("inputDeactivated")

relay("textInput")

function UI:mouseMoved(x,y,dx,dy)
	if input.isActive("drag","camera") then
		self.x = self.x + dx/self.zoomFactor
		self.y = self.y + dy/self.zoomFactor
	else
		--transform coördinates
		x = x - self.width/2
		x = x / self.zoomFactor
		x = x - self.x
		
		y = y - self.height/2
		y = y / self.zoomFactor
		y = y - self.y
		
		dx = dx / self.zoomFactor
		dy = dy / self.zoomFactor
		self.child:mouseMoved(x,y,dx,dy)
	end
end
function UI:wheelMoved(x,y)
	if y>0 then
		self.zoomFactor = self.zoomFactor * self.zoomSpeed
	elseif y<0 then
		self.zoomFactor = self.zoomFactor / self.zoomSpeed
	end
	self.x = math.roundPrecision(self.x,self.zoomFactor)
	self.y = math.roundPrecision(self.y,self.zoomFactor)
end


return UI
