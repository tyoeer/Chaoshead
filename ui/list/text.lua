local UI = Class(require("ui.base"))

function UI:initialize(w,h,text,padding)
	self.text = text
	self.font = love.graphics.getFont()
	self.padding = padding or 5
	UI.super.initialize(self, w,h)
end

function UI:getMinimumHeight(width)
	local w, text = self.font:getWrap(self.text, width)
	local h = #text * self.font:getLineHeight() * self.font:getHeight()
	return h + self.padding
end

function UI:draw()
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, 0,0, self.width, "left")
end

return UI
