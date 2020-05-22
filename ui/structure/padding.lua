local BaseUI = require("ui.base")
local Pool = require("utils.entitypool")

local UI = Class(BaseUI)

function UI:initialize(child,padding)
	self.child = child
	self.paddingLeft = padding or 10
	self.paddingRight = padding or 10
	self.paddingUp = padding or 10
	self.paddingDown = padding or 10
	UI.super.initialize(self)
	self.title = child.title
end

function UI:getPropagatedMouseX(child)
	return self:getMouseY() - self.paddingLeft
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
			else
				return
			end
		end
		self.child[index](self.child, name,group, isCursorBound)
	end
end
relayInput("inputActivated")
relayInput("inputDeactivated")

relay("textinput")

function UI:mousemoved(x,y, ...)
	if x < self.width - self.paddingRight and x > self.paddingLeft
	and y < self.height - self.paddingDown and y > self.paddingUp then
		self.child:mousemoved(x - self.paddingLeft, y - self.paddingUp, ...)
	end
end
function UI:wheelmoved(x,y)
	local mx, my = self:getMousePos()
	if mx < self.width - self.paddingRight and mx > self.paddingLeft
	and my < self.height - self.paddingDown and my > self.paddingUp then
		self.child:wheelmoved(x,y)
	end
end


return UI
