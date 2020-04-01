local BaseUI = require("ui.base")

--LevelBytesUI
local UI = Class(BaseUI)

function UI:initialize(w,h,child)
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	self.zoomSpeed = math.sqrt(2)
	self.child = child
	child.parent = self
	self.class.super.initialize(self,w,h)
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
		self.child[index](self.activeChild, ...)
	end
end

relay("update")

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

relay("keypressed")
relay("textinput")

relay("mousepressed")
relay("mousereleased")
function UI:mousemoved(x,y,dx,dy)
	if love.mouse.isDown(1) or love.mouse.isDown(3) then
		self.x = self.x + dx/self.zoomFactor
		self.y = self.y + dy/self.zoomFactor
	else
		self.child:mousemoved(x,y,dx,dy)
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
