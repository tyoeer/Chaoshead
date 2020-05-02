local UI = Class(require("ui.base"))

function UI:initialize(text,padding,indent)
	self.text = text
	self.font = love.graphics.getFont()
	self.padding = padding or 0
	self.indent = indent or 0
	UI.super.initialize(self)
end

function UI:getMinimumHeight(width)
	local w, text = self.font:getWrap(self.text, width)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h + self.padding
end

function UI:draw()
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, self.indent,0, self.width, "left")
end

return UI
