local UI = Class(require("ui.structure.base"))

function UI:initialize(text,indent)
	self.text = text
	self.font = love.graphics.getFont()
	self.indent = indent or 0
	UI.super.initialize(self)
end

function UI:getMinimumHeight(width)
	local w, text = self.font:getWrap(self.text, width-self.indent)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h
end

function UI:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(settings.col.list.text)
	love.graphics.printf(self.text, self.indent,0, self.width-self.indent, "left")
end

return UI
