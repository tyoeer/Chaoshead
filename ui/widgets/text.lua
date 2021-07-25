local UI = Class(require("ui.base.node"))

function UI:initialize(text,indention)
	self.text = text
	self.font = love.graphics.getFont()
	self.indention = indention or 0
	UI.super.initialize(self)
end

function UI:getMinimumHeight(width)
	local w, text = self.font:getWrap(self.text, width-self.indention)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h
end

function UI:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(settings.col.list.text)
	love.graphics.printf(self.text, self.indention,0, self.width-self.indention, "left")
end

return UI
