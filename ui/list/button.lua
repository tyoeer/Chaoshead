local UI = Class(require("ui.structure.base"))

function UI:initialize(text,onClick,padding)
	self.text = text
	self.onClick = onClick
	self.padding = padding or 5
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
	love.graphics.printf(self.text, self.padding,self.padding, self.width-2*self.padding, "left")
	love.graphics.rectangle("line",0.5,0.5,self.width-1,self.height-1)
end

function UI:inputActivated(name,group,isCursorBound)
	if name=="click" and group=="main" then
		self.onClick()
	end
end

return UI
