local BaseUI = require("ui.structure.base")

local UI = Class(BaseUI)

function UI:initialize(child,padding)
	self.child = child
	child.parent = self
	if not padding then
		error("Padding not specified!")
	end
	self.paddingLeft = padding
	self.paddingRight = padding
	self.paddingUp = padding
	self.paddingDown = padding
	UI.super.initialize(self)
	self.title = child.title
end

function UI:getPropagatedMouseX(child)
	return self:getMouseX() - self.paddingLeft
end

function UI:getPropagatedMouseY(child)
	return self:getMouseY() - self.paddingUp
end

-- events

local relay = function(index)
	UI[index] = function(self, ...)
		self.child[index](self.child, ...)
	end
end


relay("update")

function UI:draw()
	--draw activeChild
	love.graphics.push("all")
		love.graphics.translate(self.paddingLeft,self.paddingUp)
		local x,y = love.graphics.transformPoint(0,0)
		local endX,endY = love.graphics.transformPoint(self.width - self.paddingRight, self.height - self.paddingDown)
		love.graphics.intersectScissor(x, y, endX-x, endY-y)
		self.child:draw()
	love.graphics.pop("all")
end

relay("focus")
relay("visible")
function UI:resize(w,h)
	self.width = w
	self.height = h
	
	self.child:resize(w - self.paddingLeft - self.paddingRight, h - self.paddingUp - self.paddingDown)
end

local relayInput = function(index)
	UI[index] = function(self, name,group, isCursorBound)
		if isCursorBound then
			local x,y = self:getMousePos()
			if x < self.width - self.paddingRight and x > self.paddingLeft
			and y < self.height - self.paddingDown and y > self.paddingUp then
				self.child[index](self.child, name,group, isCursorBound)
			end
			return
		end
		self.child[index](self.child, name,group, isCursorBound)
	end
end
relayInput("inputActivated")
relayInput("inputDeactivated")

relay("textInput")

function UI:mouseMoved(x,y, ...)
	if x < self.width - self.paddingRight and x > self.paddingLeft
	and y < self.height - self.paddingDown and y > self.paddingUp then
		self.child:mouseMoved(x - self.paddingLeft, y - self.paddingUp, ...)
	end
end
function UI:wheelMoved(x,y)
	local mx, my = self:getMousePos()
	if mx < self.width - self.paddingRight and mx > self.paddingLeft
	and my < self.height - self.paddingDown and my > self.paddingUp then
		self.child:wheelMoved(x,y)
	end
end


return UI
