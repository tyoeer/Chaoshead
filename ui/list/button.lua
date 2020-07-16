local UI = Class(require("ui.structure.base"))

function UI:initialize(text,onClick,padding,drawBorder)
	self.text = text
	self.onClick = onClick
	self.padding = padding or 5
	-- ==false because it should be true if it's nil, not when it's false
	self.drawBorder = (drawBorder==nil) and true or false
	self.font = love.graphics.getFont()
	UI.super.initialize(self)
end

function UI:getMinimumHeight(width)
	local w, text = self.font:getWrap(self.text, width-2*self.padding)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h + 2*self.padding
end

function UI:draw()
	love.graphics.setFont(self.font)
	local x,y = self:getMousePos()
	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.rectangle("fill",0.5,0.5,self.width-1,self.height-1)
		love.graphics.setColor(1, 1, 1, 1)
	end
	love.graphics.printf(self.text, self.padding,self.padding, self.width-2*self.padding, "left")
	if self.drawBorder then
		love.graphics.rectangle("line",0.5,0.5,self.width-1,self.height-1)
	end
end

function UI:inputActivated(name,group,isCursorBound)
	if name=="click" and group=="main" then
		self.onClick()
	end
end

return UI
