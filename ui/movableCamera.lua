local BaseUI = require("ui.base")

--LevelBytesUI
local UI = Class(BaseUI)

function UI:initialize(w,h,child)
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	self.child = child
	child.parent = self
	self.class.super.initialize(self,w,h)
	self.title = child.title
end

function UI:resize(w,h)
	self.width = w
	self.height = h
	self.child:resize(w,h)
end

function UI:mousemoved(x,y,dx,dy)
	if love.mouse.isDown(1) or love.mouse.isDown(3) then
		self.x = self.x + dx/self.zoomFactor
		self.y = self.y + dy/self.zoomFactor
	end
end

local zoomSpeed = math.sqrt(2)
function UI:wheelmoved(x,y)
	if y>0 then
		self.zoomFactor = self.zoomFactor * zoomSpeed
	elseif y<0 then
		self.zoomFactor = self.zoomFactor / zoomSpeed
	end
	self.x = math.roundPrecision(self.x,self.zoomFactor)
	self.y = math.roundPrecision(self.y,self.zoomFactor)
end

function UI:draw()
	love.graphics.push()
		love.graphics.translate(self.width/2, self.height/2)
		love.graphics.scale(self.zoomFactor)
		love.graphics.translate(self.x, self.y)
		self.child:draw()
	love.graphics.pop()
end

function UI:keypressed(...)
	self.child:keypressed(...)
end

return UI
