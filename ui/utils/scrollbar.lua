local B = require("ui.list.button")

local UI = Class(require("ui.structure.proxy"))

function UI:initialize(child)
	self.scrollbarWidth = settings.dim.misc.scrollbar.width
	self.buttonHeight = settings.dim.misc.scrollbar.buttonHeight
	self.scrollButtonHeight = -1
	self.scrollAreaHeight = -1
	self.scrollButtonY = 0
	self.downButtonY = -1
	self.childOffset = 0
	
	self.upButton = B:new("Λ", function()
		self:scrollToOffset(self.childOffset - settings.dim.misc.scrollbar.buttonScrollSpeed)
	end, 7,true)
	self.upButton.parent = self
	self.upButton:resize(self.scrollbarWidth, self.buttonHeight)
	
	self.downButton = B:new("V", function()
		self:scrollToOffset(self.childOffset + settings.dim.misc.scrollbar.buttonScrollSpeed)
	end, 7,true)
	self.downButton.parent = self
	self.downButton:resize(self.scrollbarWidth, self.buttonHeight)
	
	self.scrollButton = B:new("", function()
		self.dragging = true
	end, 5,true)
	self.scrollButton.parent = self
	self.scrollButton:resize(self.scrollbarWidth, self.scrollButtonHeight)
	
	UI.super.initialize(self,child)
end

function UI:updateScroll()
	self.scrollButtonHeight = math.min(1, self.height / self.child:getMinimumHeight() ) * self.scrollAreaHeight
	self.scrollButton:resize(self.scrollbarWidth, self.scrollButtonHeight)
	self:scrollToOffset(math.min(self.childOffset,self.child:getMinimumHeight()))
end
function UI:scroll(scrollY)
	if self.scrollButtonHeight == self.scrollAreaHeight then
		self.childOffset = 0
		self.scrollButtonY = 0
	else
		self.scrollButtonY = scrollY
		if self.scrollButtonY < 0 then
			self.scrollButtonY = 0
		elseif self.scrollButtonY > self.scrollAreaHeight-self.scrollButtonHeight then
			self.scrollButtonY = self.scrollAreaHeight-self.scrollButtonHeight
		end
		self.childOffset = math.floor(
			self.scrollButtonY/(self.scrollAreaHeight-self.scrollButtonHeight)
			* (self.child:getMinimumHeight()-self.height)
		)
	end
end
function UI:scrollToOffset(offset)
	self:scroll(offset / (self.child:getMinimumHeight()-self.height) * (self.scrollAreaHeight-self.scrollButtonHeight))
end

function UI:getPropagatedMouseX(child)
	if child == self.child then
		return self:getMouseX()
	else
		return self:getMouseX() - self.child.width
	end
end
function UI:getPropagatedMouseY(child)
	if child == self.downButton then
		return self:getMouseY() - self.downButtonY
	elseif child == self.scrollButton then
		return self:getMouseY() - self.scrollButtonY - self.buttonHeight
	elseif child == self.child then
		return self:getMouseY() + self.childOffset
	else
		return self:getMouseY()
	end
end

-- events

-- UI:update

function UI:draw()
	--child
	love.graphics.push("all")
		local x,y = love.graphics.transformPoint(0,0)
		local endX,endY = love.graphics.transformPoint(self.child.width, self.height)
		love.graphics.intersectScissor(x, y, endX-x, endY-y)
		love.graphics.translate(0, -self.childOffset)
		self.child:draw()
	love.graphics.pop("all")
	--buttons
	love.graphics.push("all")
		love.graphics.translate(self.child.width,0)
		self.upButton:draw()
		love.graphics.translate(0,self.buttonHeight + self.scrollButtonY)
		self.scrollButton:draw()
	love.graphics.pop("all")
	love.graphics.push("all")
		love.graphics.translate(self.child.width, self.downButtonY)
		self.downButton:draw()
	love.graphics.pop("all")
end

--UI:focus
--UI:visible
function UI:resize(w,h)
	self.width = w
	self.height = h
	self.child:resize(w-self.scrollbarWidth, h)
	self.downButtonY = self.height - self.buttonHeight
	self.scrollAreaHeight = self.height - 2*self.buttonHeight
	self:updateScroll()
end

function UI:inputActivated(name, group, isCursorBound)
	if isCursorBound then
		local x = self:getMouseX()
		if x < self.width-self.scrollbarWidth then
			self.child:inputActivated(name,group,isCursorBound)
			self:updateScroll()
		else
			local y = self:getMouseY()
			if y < self.buttonHeight then
				self.upButton:inputActivated(name,group,isCursorBound)
			elseif y > self.scrollButtonY + self.buttonHeight and y < self.scrollButtonY + self.buttonHeight + self.scrollButtonHeight then
				self.scrollButton:inputActivated(name,group,isCursorBound)
			elseif y > self.downButtonY then
				self.downButton:inputActivated(name,group,isCursorBound)
			end
		end
	else
		self.child:inputActivated(name,group,isCursorBound)
		self:updateScroll()
	end
end
function UI:inputDeactivated(name, group, isCursorBound)
	if isCursorBound then
		if name=="click" and group=="main" then
			self.dragging = false
		end
		local x = self:getMouseX()
		if x < self.width-self.scrollbarWidth then
			self.child:inputDeactivated(name,group,isCursorBound)
			self:updateScroll()
		else
			local y = self:getMouseY()
			if y < self.buttonHeight then
				self.upButton:inputDeactivated(name,group,isCursorBound)
			elseif y > self.scrollButtonY + self.buttonHeight and y < self.scrollButtonY + self.buttonHeight + self.scrollButtonHeight then
				self.scrollButton:inputDeactivated(name,group,isCursorBound)
			elseif y > self.downButtonY then
				self.downButton:inputDeactivated(name,group,isCursorBound)
			end
		end
	else
		self.child:inputDeactivated(name,group,isCursorBound)
		self:updateScroll()
	end
end

--UI:textInput

function UI:mouseMoved(x,y,dx,dy)
	if self.dragging then
		self:scroll(self.scrollButtonY + dy)
	end
end

function UI:wheelMoved(dx,dy)
	self:scrollToOffset(self.childOffset + -dy*settings.dim.misc.scrollbar.mouseWheelScrollSpeed)
end

return UI
